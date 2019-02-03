require 'mustermann'
require 'json'
require 'excon'

module Packagecloud
  module Maven
    module Importer
      class Main
        attr_accessor :hostname, :port, :scheme, :username, :repository, :api_token, :maven_repository_path

        def initialize(username:,
                       repository:,
                       api_token:,
                       scheme:,
                       port:,
                       hostname:,
                       maven_repository_path:)

          self.username = username
          self.scheme = scheme
          self.port = port
          self.hostname = hostname
          self.repository = repository
          self.api_token = api_token
          self.maven_repository_path = maven_repository_path
        end

        def parse_artifact(full_path)
          base_path = full_path.gsub(maven_repository_path, '')

          sanitized_base_path = ::File.join('/', base_path.gsub(/\\+/, '/'))
          sanitized_full_path = ::File.join('/', base_path.gsub(/\\+/, '/'))
          result = nil
          PATTERNS.each do |pattern, artifact_type|
            result = pattern.params(sanitized_full_path)
            if result
              return result.merge!(
                full_path: full_path,
                sanitized_base_path: sanitized_base_path)
            end
          end
          nil
        end

        def get_group_class(splat)
          group_id = splat.first
          group_id.gsub("/", ".")
        end

        def connection
          @connection ||= Excon.new("#{scheme}://#{api_token}:@#{hostname}:#{port}", :persistent => true)
        end

        def run!
          found_artifacts = []
          unknown_files = []
          files_scanned = 0
          if !File.exists?(maven_repository_path)
            $stderr.puts "#{maven_repository_path} does not exist, aborting!"
            exit 1
          end

          Dir[File.join(maven_repository_path, "/**/*")].each do |possible_artifact|
            next if possible_artifact.end_with?('lastUpdated')
            next if possible_artifact.end_with?('repositories')
            if File.file?(possible_artifact)
              result = parse_artifact(possible_artifact)
              if result
                found_artifacts << result
              else
                unknown_files << possible_artifact
              end
              files_scanned += 1
            end
          end

          puts "Found #{found_artifacts.count} uploadable artifacts out of #{files_scanned} scanned files in #{maven_repository_path}"
          puts "Choose action:"
          puts "  (i)mport artifacts"
          puts "  (v)iew unknown files"
          print ":"
          answer = gets
          if answer.chomp == "v"
            puts "Unknown files:"
            unknown_files.each do |f|
              puts "  #{f}"
            end
          end
          if answer.chomp == "i"
            connection = Excon.new("#{scheme}://#{api_token}:@#{hostname}:#{port}", :persistent => true)
            if File.exists?('packagecloud-maven-importer.queue')
              # resuming from failed run
              queue = Packagecloud::Maven::Importer::FileQueue.new('packagecloud-maven-importer.queue')
            else
              # fresh run
              queue = Packagecloud::Maven::Importer::FileQueue.new('packagecloud-maven-importer.queue')
              found_artifacts.each do |artifact|
                queue.push(artifact.to_json)
              end
            end
            while item = queue.pop do
              artifact = JSON.parse(item.chomp)
              puts "Uploading #{artifact['sanitized_base_path']}"
              ## This will safely ignore any 422's for already existing artifacts and retry on errors (5xx)
              connection.put(path: "/api/v1/repos/#{username}/#{repository}/artifacts.json",
                             body: File.read(artifact["full_path"]),
                             expects: [201, 422],
                             idempotent: true,
                             retry_limit: 5,
                             retry_interval: 5,
                             query: { key: artifact["sanitized_base_path"] })
            end

          end
        end
      end
    end
  end
end
