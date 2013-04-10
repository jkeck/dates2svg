# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dates2svg/version'

Gem::Specification.new do |spec|
  spec.name          = "dates2svg"
  spec.version       = Dates2SVG::VERSION
  spec.authors       = ["Jessie Keck"]
  spec.email         = ["jessie.keck@gmail.com"]
  spec.description   = %q{Generate a SVG month grid w/ heatmap based on array of dates.}
  spec.summary       = %q{Turn an array of objects that have a #value method w/ YYYY-MM-DD Date and a #hits method w/ the number of items in that month into an SVG month grid with heatmap.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
