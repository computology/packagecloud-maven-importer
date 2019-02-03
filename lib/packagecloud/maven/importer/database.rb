require 'sqlite3'

module Packagecloud
  module Maven
    module Importer
      class Database
        attr_accessor :database

        def initialize(path:)
          self.database = SQLite3::Database.new(path)
          self.database.execute <<-SQL
          CREATE TABLE IF NOT EXISTS artifacts (full_path TEXT PRIMARY KEY, base_path TEXT, state TEXT);
          SQL
        end

        def clear!
          self.database.execute <<-SQL
          DELETE FROM artifacts;
          SQL
        end

        def push(full_path, base_path)
          self.database.execute <<-SQL
          INSERT OR IGNORE INTO artifacts VALUES('#{full_path}', '#{base_path}', 'queued');
          SQL
        end

        def finish!(full_path)
          self.database.execute <<-SQL
          UPDATE artifacts SET state='uploaded' WHERE (full_path='#{full_path}');
          SQL
        end

        def queued_count
          self.database.get_first_value "SELECT COUNT(*) FROM artifacts where state='queued';"
        end

        def total_count
          self.database.get_first_value "SELECT COUNT(*) FROM artifacts;"
        end

        def peek
          full_path, base_path = self.database.get_first_row("SELECT * from artifacts where state='queued';")
          if full_path
            [full_path, base_path]
          else
            nil
          end
        end

      end
    end
  end
end
