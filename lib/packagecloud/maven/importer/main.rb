require 'mustermann'
require 'json'
require 'excon'

module Packagecloud
  module Maven
    module Importer
      class Main
        attr_accessor :database, :hostname, :port, :scheme, :username, :repository, :api_token, :maven_repository_path

        def initialize(username:,
                       repository:,
                       api_token:,
                       scheme:,
                       port:,
                       hostname:,
                       database_path:,
                       maven_repository_path:)

          self.username = username
          self.scheme = scheme
          self.port = port
          self.hostname = hostname
          self.repository = repository
          self.api_token = api_token
          self.maven_repository_path = maven_repository_path
          self.database = Packagecloud::Maven::Importer::Database.new(path: database_path)
        end

        def parse_artifact(full_path)
          base_path = full_path.gsub(maven_repository_path, '')

          sanitized_base_path = ::File.join('/', base_path.gsub(/\\+/, '/'))
          result = nil
          Packagecloud::Maven::Importer::PATTERNS.each do |pattern, artifact_type|
            result = pattern.params(sanitized_base_path)
            if result
              return { full_path: full_path, base_path: sanitized_base_path }
            end
          end
          nil
        end

        def connection
          @connection ||= Excon.new("#{scheme}://#{api_token}:@#{hostname}:#{port}", :persistent => true)
        end

        def run!(yes:false, force:false)
          puts "Starting packagecloud-maven-importer v#{Packagecloud::Maven::Importer::VERSION}"

          if force == true
            if yes == false
              print "Delete local artifact database and start over? [y/N]:"
              answer = gets
              if answer.chomp != "y"
                puts 'Aborting!'
                exit 1
              end
            end
            database.reset!
          end

          unknown_files = []
          files_scanned = 0
          artifacts_scanned = 0
          initial_database_count = database.queued_count

          if !File.exists?(maven_repository_path)
            $stderr.puts "#{maven_repository_path} does not exist, aborting!"
            exit 1
          end

          puts "Building database of uploadable artifacts in #{maven_repository_path}..."
          Dir[File.join(maven_repository_path, "/**/*")].each do |possible_artifact|
            next if possible_artifact.end_with?('lastUpdated')
            next if possible_artifact.end_with?('repositories')
            next if possible_artifact.include?('-SNAPSHOT')

            if File.file?(possible_artifact)
              result = parse_artifact(possible_artifact)
              if result
                database.push(result[:full_path], result[:base_path])
                artifacts_scanned += 1
              else
                unknown_files << possible_artifact
              end
              files_scanned += 1
            end
          end

          if initial_database_count == 0
            puts "Found #{artifacts_scanned} total uploadable artifacts out of #{files_scanned} scanned files in #{maven_repository_path}"
          else
            new_artifacts_scanned = initial_database_count - database.queued_count
            puts "Found #{artifacts_scanned} total uploadable artifacts (#{new_artifacts_scanned} previously unseen) out of #{files_scanned} scanned files in #{maven_repository_path}"
          end

          if database.queued_count == 0
            puts "Nothing left to upload"
          else
            puts "#{database.queued_count} artifacts left to upload..."
            if yes == false
              print "Continue? [y/N]:"
              answer = gets
              if answer.chomp != "y"
                puts 'Aborting!'
                exit 1
              end
            end
          end

          while path_pair = database.peek do
            full_path, base_path = path_pair
            print "Uploading #{base_path}..."

            # This will safely ignore any 422's for already existing artifacts and retry on errors (5xx)
            connection.put(path: "/api/v1/repos/#{username}/#{repository}/artifacts.json",
                           body: File.read(full_path),
                           expects: [201, 422],
                           idempotent: true,
                           retry_limit: 5,
                           retry_interval: 5,
                           headers: {'User-Agent' => "packagecloud-maven-importer v#{Packagecloud::Maven::Importer::VERSION} (#{RUBY_PLATFORM})"},
                           query: { key: base_path })

            puts "Done"
            database.finish!(full_path)
          end
          puts "Finished"

          exit 0
        end
      end
    end
  end
end
