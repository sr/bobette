Gem::Specification.new do |s|
  s.name    = "bobette"
  s.version = "0.0.4"
  s.date    = "2009-07-17"

  s.summary     = "Bob's sister"
  s.description = "Bob's sister"

  s.homepage    = "http://integrityapp.com"

  s.authors = ["Nicolás Sanguinetti", "Simon Rozet"]
  s.email   = "info@integrityapp.com"

  s.require_paths     = ["lib"]
  s.rubyforge_project = "integrity"
  s.has_rdoc          = false
  s.rubygems_version  = "1.3.1"

  s.add_dependency "rack"

  s.files = %w[
LICENSE
README.md
Rakefile
bobette.gemspec
lib/bobette.rb
lib/bobette/github.rb
test/bobette_github_test.rb
test/bobette_test.rb
test/deps.rip
test/helper.rb
test/helper/builder_stub.rb
test/helper/github_payload.js
]
end
