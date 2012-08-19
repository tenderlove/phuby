ENV['RC_ARCHS'] = '' if RUBY_PLATFORM =~ /darwin/

# :stopdoc:

require 'mkmf'

config = Dir["/{usr,opt}/local/bin/php-config"].first
prefix = `#{config} --prefix`.chomp

php_inc, php_lib = dir_config("php5", "#{prefix}/include", "#{prefix}/lib")

$INCFLAGS = "-I#{File.join(php_inc, "php").quote} #{$INCFLAGS}"

%w{ Zend TSRM main }.each do |dir|
  $INCFLAGS = "-I#{File.join(php_inc, "php", dir).quote} #{$INCFLAGS}"
end

unless find_library("php5", "php_embed_init", php_lib)
  abort "php is missing!"
end

create_makefile("phuby/phuby")

# :startdoc:
