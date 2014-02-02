require 'rubygems'
require 'bundler/setup'

Bundler.require :default

require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

if RUBY_VERSION >= "1.9"
  # Generating API documentation, run with 'rake yard'
  require 'yard'
  YARD::Rake::YardocTask.new do |t|
    t.options =  [
      '--title', 'Options Validator',
      '--markup-provider=redcarpet', 
      '--markup=markdown',
      'lib/**/*.rb'
      ]
  end
end

task :default do
  sh %{rake -T}
end
