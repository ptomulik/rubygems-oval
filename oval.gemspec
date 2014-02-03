lib = File.expand_path(File.join(File.dirname(__FILE__),'lib'))
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |gem|
  gem.name          = 'oval'
  gem.version       = '0.0.5'
  gem.authors       = ["Pawel Tomulik"]
  gem.email         = ["ptomulik@meil.pw.edu.pl"]
  gem.description   = %q{Validate options when passed to methods}
  gem.summary       = %q{Using hashes to pass options to methods is a very common ruby practice. With **Oval** method authors may restrict callers to pass only declared options that meet requirements described in a hash declaration.}
  gem.homepage      = "https://github.com/ptomulik/rubygems-oval"
  gem.license       = "Apache 2.0"
  gem.files         = `git ls-files`.split($/)
  gem.executables   = []
  gem.test_files    = gem.files.grep(/^(test|spec|features)/)
  gem.require_paths = ["lib"]

  gem.add_development_dependency "rake"
  gem.add_development_dependency 'rspec-core'
  gem.add_development_dependency 'rspec-expectations'
  gem.add_development_dependency 'mocha'
  if RUBY_VERSION >= "1.9"
    gem.add_development_dependency 'coveralls'
    gem.add_development_dependency 'yard'
    gem.add_development_dependency 'redcarpet'
    gem.add_development_dependency 'github-markup'
  end
end
