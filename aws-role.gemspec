
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "aws/role/version"

Gem::Specification.new do |spec|
  spec.name          = "aws-role"
  spec.version       = AwsRole::VERSION
  spec.authors       = ["Michael Shea"]
  spec.email         = ["michael.shea@heroku.com"]

  spec.summary       = %q{CLI to assume AWS roles}
  spec.description   = %q{CLI to assume AWS roles}
  spec.homepage      = "https://github.com/sheax0r/aws-role"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "clamp", "~> 1.2.1"
  spec.add_dependency "aws-sdk-core", "~> 3.1"

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
