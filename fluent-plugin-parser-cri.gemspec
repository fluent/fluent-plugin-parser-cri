lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name    = "fluent-plugin-parser-cri"
  spec.version = "0.1.0"
  spec.authors = ["Masahiro Nakagawa"]
  spec.email   = ["repeatedly@gmail.com"]

  spec.summary       = %q{CRI log format parser for Fluentd}
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/fluent/fluent-plugin-parser-cri"
  spec.license       = "Apache-2.0"

  test_files, files  = `git ls-files -z`.split("\x0").partition do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.files         = files
  spec.executables   = files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = test_files
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.1"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "test-unit", "~> 3.3"
  spec.add_runtime_dependency "fluentd", ">= 1"
end
