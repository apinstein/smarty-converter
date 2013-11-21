# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'smarty/converter/version'

Gem::Specification.new do |spec|
  spec.name          = "smarty-converter"
  spec.version       = Smarty::Converter::VERSION
  spec.authors       = ["Scott Davis"]
  spec.email         = ["me@sdavis.info"]
  spec.description   = %q{Convert html files to smarty templates}
  spec.summary       = %q{html to smarty template converter}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "nokogiri", "~>1.6.0"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
