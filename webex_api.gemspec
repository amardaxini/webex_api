# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'webex_api/version'

Gem::Specification.new do |spec|
  spec.name          = "webex_api"
  spec.version       = WebexApi::VERSION
  spec.authors       = ["amardaxini"]
  spec.email         = ["amardaxini@gmail.com"]

  spec.summary       = %q{Webex Api for meeting.}
  spec.description   = %q{Webex Api for managing meeting and event}
  spec.homepage      = "https://github.com/amardaxini/webex_api"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.


  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "nokogiri"
end
