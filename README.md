#Oval - Options Validator

[![Build Status](https://travis-ci.org/ptomulik/rubygems-oval.png?branch=master)](https://travis-ci.org/ptomulik/rubygems-oval)
[![Coverage Status](https://coveralls.io/repos/ptomulik/rubygems-oval/badge.png?branch=master)](https://coveralls.io/r/ptomulik/rubygems-oval?branch=master)
[![Code Climate](https://codeclimate.com/github/ptomulik/rubygems-oval.png)](https://codeclimate.com/github/ptomulik/rubygems-oval)

####<a id="table-of-contents"></a>Table of Contents

1. [Overview](#overview)
2. [Module Description](#module-description)
3. [Usage](#usage)
   * [Example 1: Declaring simple options](#example-1-declaring-simple-options)
   * [Example 2: Separating declaration from validation](#example-2-separating-declaration-from-validation)
4. [Reference](#reference)
   * [Declarators](#declarators)
   * [API Reference](#api-reference)
5. [Limitations](#limitations)

##<a id="overview"></a>Overview

Validate arguments and option hashes when passed to methods.

[[Table of Contents](#table-of-contents)]

##<a id="module-description"></a>Module Description

This module implements simple to use data validators. It was initially thought
to validate option hashes (so the name *Oval* stands for Options' Validator),
but it appeared early that it's suitable to validate arbitrary parameters
(variables).

The shape of acceptable data is described by a simple grammar. The validation
is then carried out by a recursive-descent parser which matches actual values
provided by caller to [declarators](#declarators) that comprise the declaration
of acceptable values.

A declaration consists of terminal and non-terminal declarators. Most *Oval*
methods with **ov_xxx** names are non-terminal declarators. All other values
(such as `:symbol`, `'string'`, `nil`, or `Class`) are terminals. Terminals use
`==` operator to match the values provided by caller. Non-terminal use its own
logic introducing more elaborate matching criteria (see for example
[ov\_collection](#ov_collection)).

**Oval** raises **Oval::DeclError** if the declaration is not well-formed. This
is raised from the point of declaration. Other, more common exception is the
**Oval::ValueError** which is raised each time the validation fails. This one
is raised from within a method which validates its arguments.

[[Table of Contents](#table-of-contents)]

##<a id="usage"></a>Usage

The usage is basically a two-step procedure. The first step is to declare
data to be validated. This would create a validator object. The second step is
to validate data using the previously constructed validator. For simple cases
the entire construction may fit to a single line. Let's start with such a
simple example.

###<a id="example-1-declaring-simple-options"></a>Example 1: Declaring Simple Options

The method `foo` in the following code accepts only `{}` and `{:foo => value}`
as `ops` hash, and the `value` may be anything:

```ruby
# Options validator
require 'oval'
class C
  extend Oval
  def self.foo(ops = {})
    Oval.validate(ops, ov_options[ :foo => ov_anything ], 'ops')
  end
end
```

What does it do? Just try it out:

```ruby
C.foo # should pass
C.foo :foo => 10 # should pass
C.foo :foo => 10, :bar => 20 # Oval::ValueError "Invalid option :bar for ops. Allowed options are :foo"
```

Options are declared with [ov\_xxx declarators](#declarators). The
[ov\_options](#ov_options), for example, declares a hash of options. In
[ov\_options](#ov_options) all the allowed options should be listed inside of
`[]` square brackets. Keys may be any values convertible to strings (i.e. a key
given in declaration must `respond_to? :to_s`). Values are declared recursively
using [ov_xxx declarators](#declarators) or terminal declarators (any other
ruby values).

In [Example 1](#example-1-declaring-simple-options) we have declared options
inside of a method for simplicity. This isn't an optimal technique. Usually
options' declaration remains same for the entire lifetime of an application, so
it is unnecessary to recreate the declaration each time function is called. In
other words, we should move the declaration outside of the method, convert it
to a singleton and only validate options inside of a function. For that
purpose, the [Example 1](#example-1-declaring-simple-options) could be modified
to the following form

###<a id="example-2-separating-declaration-from-validation"></a>Example 2: Separating declaration from validation

In this example we separate options declaration from the validation to reduce
costs related to options declaration:

```ruby
# Options validator
require 'oval'
class C
  extend Oval
  # create a singleton declaration ov
  def self.ov
    @ov ||= ov_options[ :foo => ov_anything ]
  end
  # use ov to validate ops
  def self.foo(ops = {})
    Oval.validate(ops, ov, 'ops')
  end
end
```

[[Table of Contents](#table-of-contents)]

##<a id="reference"></a>Reference

###<a id="declarators"></a>Declarators

A declaration of data being validated consists entirely of what we call
**declarators**. The grammar for defining acceptable data uses non-terminal and
terminal declarators. Non-terminal declarators are most of the
[ov\_xxx](#declarators) methods of **Oval** module, for example
[ov\_options](#ov_options). General syntax for non-terminal declarator is
`ov_xxx[ args ]`, where `args` are declarator-specific arguments. 

Terminal declarators include all the other ruby values, for example `nil`. They
are matched exactly against data being validated, so if the data doesn't equal
the given value an exception is raised.

In what follows, we'll document all the core declarators implemented in
**Oval**.

###<a id="index-of-declarators"></a>Index of Declarators

- [ov\_anything](#ov_anything)
- [ov\_collection](#ov_collection)
- [ov\_instance\_of](#ov_instance_of)
- [ov\_kind\_of](#ov_kind_of)
- [ov\_match](#ov_match)
- [ov\_one\_of](#ov_one_of)
- [ov\_options](#ov_options)
- [ov\_subclass_of](#ov_subclass_of)

####<a id="ov\_anything"></a>ov\_anything

- Declaration

  ```ruby
  ov_anything
  ```

  or
  
  ```ruby
  ov_anything[]
  ```
  
- Validation - permits any value
- Example

  ```ruby
  require 'oval'
  class C
    extend Oval
    def self.ov
      @oc = ov_options[ :bar => ov_anything ]
    end
    def self.foo(ops = {})
      Oval.validate(ops, ov, 'ops')
    end
  end
  C.foo() # should pass
  C.foo :bar => 10 # should pass
  C.foo :bar => nil # should pass
  C.foo :bar => 'bar' # should pass
  C.foo :foo => 10, :bar => 20 # Oval::ValueError "Invalid option :foo for ops. Allowed options are :bar"
  ```

[[Table of Contents](#table-of-contents)|[Index of Declarators](#index-of-declarators)]


####<a id="ov\_collection"></a>ov\_collection

- Declaration

  ```ruby
  ov_collection[ class_decl, item_decl ]
  ```

- Validation - permits only collections of type **class_decl** with items
  matching **item_decl** declaration
- Allowed values for **class\_decl** are:
  - `Hash` or `Array` or any subclass of `Hash` or `Array`,
  - `ov_subclass_of[klass]` where **klass** is `Hash` or `Array` or a subclass
    of any of them.
- Allowed values for **item_decl**:
  - if **class\_decl** is `Array`-like, then any value is allowed as
    **item\_decl**,
  - if **class\_decl** is `Hash`-like, then **item\_decl** should be a
    one-element Hash in form **{ key\_decl => val\_decl }**.
- Example

  ```ruby
  require 'oval'
  class C
    extend Oval
    def self.ov_h
      ov_collection[ Hash, { ov_instance_of[Symbol] => ov_anything } ]
    end
    def self.ov_a
      ov_collection[ Array, ov_instance_of[String] ]
    end
    def self.foo(h, a)
      Oval.validate(h, ov_h, 'h')
      Oval.validate(a, ov_a, 'a')
    end
  end
  C.foo({:x => 10}, ['xxx']) # Should bass
  C.foo({:x => 10, :y => nil}, ['xxx', 'zzz']) # Should pass
  C.foo(10,['xxx']) # Oval::ValueError, "Invalid value Fixnum for h.class. Should be equal Hash"
  C.foo({:x => 10, 'y' => 20}, [ 'xxx' ]) # Oval::ValueError, 'Invalid object "y" of type String for h key. Should be an instance of Symbol'
  C.foo({:x => 10}, 20) # Invalid value Fixnum for a.class. Should be equal Array
  C.coo({:x => 10}, [ 'ten', 20 ]) # Oval::ValueError, "Invalid object 20 of type Fixnum for a[1]. Should be an instance of String"
  ```

[[Table of Contents](#table-of-contents)|[Index of Declarators](#index-of-declarators)]

####<a id="ov\_instance\_of"></a>ov\_instance\_of

- Declaration

  ```ruby
  ov_instance_of[klass]
  ```
  
- Validation - permits only instances of a given class **klass**
- Allowed values for **klass** - only class names, for example `String`, `Hash`, etc.
- Example

  ```ruby
  require 'oval'
  class C
    extend Oval
    def self.ov
      ov_instance_of[String]
    end
    def self.foo(s)
      Oval.validate(s, ov, 's')
    end
  end
  C.foo('bar') # Should pass
  C.foo(10) # Oval::ValueError, "Invalid object 10 for s. Should be an instance of String"
  ```

[[Table of Contents](#table-of-contents)|[Index of Declarators](#index-of-declarators)]

####<a id="ov\_kind\_of"></a>ov\_kind\_of                                       

- Declaration

  ```ruby
  ov_kind_of[klass]
  ```
  
- Validation - permits only values that are a kind of given class **klass**
- Allowed values for **klass** - only class names, for example `String`, `Hash`, etc.
- Example

  ```ruby
  require 'oval'
  class C
    extend Oval
    def self.ov
      ov_kind_of[Numeric]
    end
    def self.foo(n)
      Oval.validate(n, ov, 'n')
    end
  end
  C.foo(10) # Should pass
  C.foo(10.0) # Should pass
  C.foo('10') # Oval::ValueError, 'Invalid object "10" of type String for n. Should be a kind of Numeric'
  ```
  
[[Table of Contents](#table-of-contents)|[Index of Declarators](#index-of-declarators)]

####<a id="ov\_match"></a>ov\_match                                       

- Declaration

  ```ruby
  ov_match[re]
  ```
  
- Validation - permits only values matching regular expression **re**,
- Allowed values for **re** - must be a kind of `Regexp`.
- Example

  ```ruby
  require 'oval'
  class C
    extend Oval
    def self.ov
      # Only valid identifiers are allowed as :bar option
      ov_match[/^[a-z_]\w+$/]
    end
    def self.foo(name)
      Oval.validate(name, ov, 'name')
    end
  end
  C.foo('var_23') # Should pass
  C.foo(10) # Oval::ValueError, "Invalid value 10 for name. Should match /^[a-z_]\\w+$/ but it's not even convertible to String"
  C.foo('10abc_') # Oval::ValueError, 'Invalid value "10abc_" for name. Should match /^[a-z_]\\w+$/'
  ```
  
[[Table of Contents](#table-of-contents)|[Index of Declarators](#index-of-declarators)]

####<a id="ov\_one\_of"></a>ov\_one\_of   

- Declaration

  ```ruby
  ov_one_of[decl1,decl2,...]
  ```
  
- Validation - permits only values matching one of declarations `decl`, `decl2`, ...
- Example

  ```ruby
  require 'oval'
  class C
    extend Oval
    def self.ov
      ov_one_of[ ov_instance_of[String], ov_kind_of[Numeric], nil ]
    end
    def self.foo(x)
      Oval.validate(x, ov, 'x')
    end
  end
  C.foo('str')  # Should pass
  C.foo(10)     # Should pass
  C.foo(10.0)   # Should pass
  C.foo(nil)    # Should pass
  C.foo([])     # Oval::ValueError, "Invalid value [] for x. Should be an instance of String, be a kind of Numeric or be equal nil"
  ```
  
[[Table of Contents](#table-of-contents)|[Index of Declarators](#index-of-declarators)]

####<a id="ov\_options"></a>ov\_options       

- Declaration

  ```ruby
  ov_options[ optkey_decl1 => optval_decl1, ... ]
  ```
  
- Validation - permits only declared options and their values.
- Allowed values for `optkey_declN` - anything that is convertible to string
  (namely, anything that responds to `to_s` method).
- Example:

  ```ruby
  ov = ov_options[ 
    :bar => ov_anything,
    :geez => ov_instance_of[String],
    # ...
  ]
  def foo(ops = {})
    Oval.validate(ops, ov, 'ops')
  end 
  ```
  
[[Table of Contents](#table-of-contents)|[Index of Declarators](#index-of-declarators)]

####<a id="ov\_subclass\_of"></a>ov\_subclass\_of                               

- Declaration

  ```ruby
  ov_subclass_of[klass]
  ```
  
- Validation - permits only subclasses of **klass**
- Allowed values for **klass** - only class names, for example `String`, `Hash`, etc.
- Example

  ```ruby
  require 'oval'
  class C
    extend Oval
    def self.ov
      ov_options[ :bar => ov_subclass_of[Numeric] ]
    end
    def self.foo(ops = {})
      Oval.validate(ops, ov, 'ops')
    end
  end
  C.foo :bar => Integer   # Should pass
  C.foo :bar => Fixnum    # Should pass
  C.foo([])               # Oval::ValueError, "Invalid options [] of type Array. Should be a Hash
  C.foo :foo => Fixnum    # Oval::ValueError, "Invalid option :foo for ops. Allowed options are :bar"
  C.foo :bar => 10        # Oval::ValueError, "Invalid class 10 for ops[:bar]. Should be subclass of Numeric"
  ```
  
###<a id="api-reference"></a>API Reference

API reference may be generated with

```console
bundle exec rake yard
```

The generated documentation goes to `doc/` directory. Note that this works only
under ruby >= 1.9.

The API documentation is also available
[online](http://rdoc.info/github/ptomulik/rubygems-oval/).

[[Table of Contents](#table-of-contents)]

##Limitations

- API documentation is currently very poor,

[[Table of Contents](#table-of-contents)]
