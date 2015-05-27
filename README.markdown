# phuby

* http://github.com/tenderlove/phuby

## DESCRIPTION:

Phuby wraps PHP in a loving embrace.  Exposes a PHP runtime in ruby

## FEATURES/PROBLEMS:

* many

## SYNOPSIS:

```ruby
php = Phuby::Runtime.new
php.start

php.eval('$hello = "world"')
assert_equal "world", php['hello']

php.stop
```

## REQUIREMENTS:

* php

## BUILD INSTRUCTIONS:

I've only tested this gem on OS X.  It should work on other operating systems,
but you'll need to install php with the `--enable-embed` flag yourself.

On OS X:

**Make sure you have mysql installed before installing this gem**

```
$ gem install phuby
```

On other operating systems, install php first, then do the gem install.

## INSTALL:

* No.

## I can't even!

* Don't

## LICENSE:

(The MIT License)

Copyright (c) Aaron Patterson and Ryan Davis of Seattle.rb

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
