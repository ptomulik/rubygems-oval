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

Validate option hashes when passed to methods.

[[Table of Contents](#table-of-contents)]

##<a id="module-description"></a>Module Description

Using hashes to pass options to methods is a very common ruby practice. With
**Oval** method authors may restrict callers to pass only declared options that
meet requirements described in a hash declaration.

The shape of acceptable hashes is described by a simple grammar. The validation
is then carried out by a recursive-descent parser that matches the actual
values provided by caller against [declarators](#declarators) that comprise the
hash declaration.

A declaration consists of terminal and non-terminal declarators. Non-terminal
declarators are created by methods of `Oval` module which have names starting
with `ov_` prefix. All other values (such as `:symbol`, `'string'`, `nil`, or
`Class`) are terminals. Terminals use `==` operator to match the values
provided by caller. Non-terminal use its own logic introducing more elaborate
matching criteria (see for example [ov_collection](#ov_collection)).

**Oval** raises **Oval::DeclError** if the declaration is not well-formed, that
is if the description of options shape is erroneous. This is raised from the
point of declaration. Other, more common exception is the **Oval::ValueError**
which is raised each time the validation fails. This one is raised from within
a method which takes the options as an argument.

[[Table of Contents](#table-of-contents)]

##<a id="usage"></a>Usage

The usage is basically a two-step procedure. The first step is to declare
options shape. This would create a validator object. The second step is to
validate options within a method using the previously constructed validator.
For simple hashes the entire construction may fit to a single line. Let's start
with such a simple example.

###<a id="example-1-declaring-simple-options"></a>Example 1: Declaring Simple Options

The method `foo` in the following code accepts only `{}` and `{:foo => value}`
as `ops`, where `value` is arbitrary:

```ruby
# Options validator
require 'oval'
class C
  extend Oval
  def self.foo(ops = {})
    ov_options[ :foo => ov_anything ].validate(ops, 'ops')
  end
end
```

What does it do? Just try it out:

```ruby
C.foo # should pass
C.foo :foo => 10 # should pass
C.foo :foo => 10, :bar => 20 # Oval::ValueError "Invalid option :bar for ops. Allowed options are :foo"
```

Options are declared with [ov_xxx declarators](#declarators). The
[ov_options](#ov_options) method should always be at the top level. Then all
the allowed options should be listed inside of `[]` square brackets. Keys may
be any values convertible to strings (i.e. a key given in declaration must
`respond_to? :to_s`). Values are declared recursively using [ov_xxx
declarators](#declarators) or terminal declarators (any other ruby values).

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
    ov.validate(ops, 'ops')
  end
end
```

[[Table of Contents](#table-of-contents)]

##<a id="reference"></a>Reference

###<a id="declarators"></a>Declarators

A declaration of options consists entirely of what we call here
**declarators**. The [ov_options](#ov_options) should be used as a root of
every declaration (starting symbol in grammar terms). It accepts a Hash of the
form 

```
{optname1 => optdecl1, optname2 => optdecl2, ... }
```

as an argument. The **optname#** is an option name, and **optdecl#** is a
declarator restricting the option's value. Each option name (key) must be
convertible to a `String`. Option value declarators are non-terminal
declarators (defined later in this section) or terminals (any other ruby
values). The simple declaration

```ruby
ov_options[ :foo => :bar ]
```

uses only terminals inside of **ov_options** and literary permits only the
`{:foo => :bar}` or the empty hash `{}` as options (and nothing else). This is
how terminal declarators (`:foo` and `:bar` in this example) work. More freedom
may be introduced with non-terminal declarators, for example:

```ruby
ov_options[ :foo => ov_anything ]
```

defines an option `:foo` which accepts any value. In what follows, we'll
document all the core non-terminal declarators implemented in **Oval**.

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
  ov = ov_options[ :bar => ov_anything ]
  def foo(ops = {})
    ov.validate(ops, 'ops')
  end
  ```


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
  ov = ov_options[
    :bar => ov_collection[ Hash, { instance_of[Symbol] => anything } ],
    :geez => ov_collection [ Array, instance_of[String] ]
  ]
  def foo(ops = {})
    ov.validate(ops, 'ops')
  end
  ```

####<a id="ov\_instance\_of"></a>ov\_instance\_of

- Declaration

  ```ruby
  ov_instance_of[klass]
  ```
  
- Validation - permits only instances of a given class **klass**
- Allowed values for **klass** - only class names, for example `String`, `Hash`, etc.
- Example

  ```ruby
  ov = ov_options[ :bar => ov_instance_of[String] ]
  def foo(ops = {})
    ov.validate(ops,'ops')
  end
  ```

####<a id="ov\_kind\_of"></a>ov\_kind\_of                                       

- Declaration

  ```ruby
  ov_kind_of[klass]
  ```
  
- Validation - permits only values that are a kind of given class **klass**
- Allowed values for **klass** - only class names, for example `String`, `Hash`, etc.
- Example

  ```ruby
  ov = ov_options[ :bar => ov_kind_of[Numeric] ]
  def foo(ops = {})
    ov.validate(ops,'ops')
  end
  ```
  
####<a id="ov\_match"></a>ov\_match                                       

- Declaration

  ```ruby
  ov_match[re]
  ```
  
- Validation - permits only values matching regular expression **re**,
- Allowed values for **re** - must be a kind of `Regexp`.
- Example

  ```ruby
  # Only valid identifiers are allowed as :bar option
  ov = ov_options[ :bar => ov_match[/^[a-z_]\w+$/] ]
  def foo(ops = {})
    ov.validate(ops,'ops')
  end
  ```
  
####<a id="ov\_one\_of"></a>ov\_one\_of   

- Declaration

  ```ruby
  ov_one_of[decl1,decl2,...]
  ```
  
- Validation - permits only values matching one of declarations `decl`, `decl2`, ...
- Example

  ```ruby
  ov = ov_options[ 
    :bar => ov_one_of[ ov_instance_of[String], ov_kind_of[Numeric], nil ]
  ]
  def foo(ops = {})
    ov.validate(ops,'ops')
  end
  ```
  
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
    ov.validate(ops,'ops')
  end 
  ```
  
####<a id="ov\_subclass\_of"></a>ov\_subclass\_of                               

- Declaration

  ```ruby
  ov_subclass_of[klass]
  ```
  
- Validation - permits only subclasses of **klass**
- Allowed values for **klass** - only class names, for example `String`, `Hash`, etc.
- Example

  ```ruby
  ov = ov_options[ :bar => ov_subclass_of[Numeric] ]
  def foo(ops = {})
    ov.validate(ops,'ops')
  end
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
