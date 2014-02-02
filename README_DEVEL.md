# rubygems-oval

## Notes for developers

### Cloning the repository

    git clone git://github.com/ptomulik/rubygems-oval.git

### Installing required gems

    bundle install --path vendor

### Runing unit tests

    bundle exec rake spec

### Runing single test (e.g. **macro_spec.rb**)

    bundle exec rake spec_prep && \
    bundle exec rspec spec/unit/oval/base.rb

### Generating API documentation

    bundle exec rake yard

The generated documentation goes to `doc/` directory. Note that this works only
under ruby >= 1.9.
