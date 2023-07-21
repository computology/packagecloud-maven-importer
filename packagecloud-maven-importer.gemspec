
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "packagecloud/maven/importer/version"

Gem::Specification.new do |spec|
  spec.name          = "packagecloud-maven-importer"
  spec.version       = Packagecloud::Maven::Importer::VERSION
  spec.authors       = ["Julio Capote"]
  spec.email         = ["julio@packagecloud.io"]

  spec.summary       = %q{Imports/Mirrors a local Maven repository to packagecloud.io}
  spec.homepage      = "https://github.com/computology/packagecloud-maven-importer"
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "mustermann", "1.0.3"
  spec.add_runtime_dependency "sqlite3", "1.3.13"
  spec.add_runtime_dependency "excon", "0.100.0"

  spec.add_development_dependency "bundler", "~> 1.17"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
