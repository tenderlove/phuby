ENV['RC_ARCHS'] = '' if RUBY_PLATFORM =~ /darwin/

# :stopdoc:

require 'mkmf'
require 'shellwords'

PREFIX = File.expand_path(File.dirname(__FILE__))
def build_php
  location = PREFIX

  require 'tmpdir'
  # This really only works on OS X, and I don't want to figure out other
  # operating systems.  If you're not on OS X, just install PHP youself.
  Dir.chdir Dir.tmpdir do

    unless File.file? 'php-5.6.21.tar.gz'
      system "curl -O http://php.net/distributions/php-5.6.21.tar.gz"
    end

    system "tar zxf php-5.6.21.tar.gz"
    Dir.chdir "php-5.6.21" do
      #system "curl https://raw.githubusercontent.com/tenderlove/phuby/ed41daece6a9191a0240dae9c9b610bb06d61177/configure.diff | patch"
      system "curl https://gist.githubusercontent.com/tenderlove/e3fd03049c687f86c2f3236f35dfb080/raw/68ada4c25188a57da120cadb0ee16d18967404f9/fuu.diff | patch"
      cmd = './configure --enable-debug --enable-embed --disable-cli --with-mysql=/usr/local --with-mysqli=/usr/local/bin/mysql_config --with-mysql-sock=/tmp/mysql.sock '
      cmd << " --prefix=#{Shellwords.escape(location)}"
      system cmd
      system "make"
      system "find . -path '*.libs*' -name *.o -execdir sh -c 'cp * ../' \\;"
      system "make"

      so_file = File.join location, 'lib', 'libphp5.so'

      require 'find'

      Find.find('.') do |f|
        if f =~ /libphp5.so$/
          system "install_name_tool -id #{so_file} #{f}"
        end
      end

      system "make install"
    end
  end
end

def find_config
  [
    "/usr/local/bin/php-config",
    "/opt/local/bin/php-config",
    File.join(PREFIX, 'bin', 'php-config')
  ].find { |f| File.exist? f }
end

config = find_config

if config
else
  build_php
  config = find_config
end

prefix = `#{config} --prefix`.chomp if config

if prefix
  php_inc, php_lib = dir_config("php5", "#{prefix}/include", "#{prefix}/lib")
else
  php_inc, php_lib = dir_config("php5")
end

$INCFLAGS = "-I#{File.join(php_inc, "php").quote} #{$INCFLAGS}"

%w{ Zend TSRM main }.each do |dir|
  $INCFLAGS = "-I#{File.join(php_inc, "php", dir).quote} #{$INCFLAGS}"
end

unless find_library("php5", "php_embed_init", php_lib)

  unless find_library("php5", "php_embed_init", php_lib)
    abort "php is missing!"
  end
end

create_makefile("phuby/phuby")

# :startdoc:
