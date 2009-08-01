# -*- ruby -*-

require 'rubygems'
require 'hoe'

HOE = Hoe.spec 'phuby' do
  developer('Aaron Patterson', 'aaronp@rubyforge.org')
  self.readme_file   = 'README.rdoc'
  self.history_file  = 'CHANGELOG.rdoc'
  self.extra_rdoc_files  = FileList['*.rdoc']

  self.spec_extras = { :extensions => ["ext/phuby/extconf.rb"] }
end

RET = Rake::ExtensionTask.new("nokogiri", HOE.spec) do |ext|
  ext.lib_dir = File.join('lib', 'phuby')
end

Rake::Task[:test].prerequisites << :compile

# vim: syntax=ruby
