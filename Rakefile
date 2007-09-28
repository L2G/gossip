#!/usr/bin/env ruby
#
#  Created by Brian Marick on 2007-07-03.
#  Copyright (c) 2007. All rights reserved.

require 'hoe'
require 'lib/gossip/version'

PROJECT='gossip'
THIS_RELEASE=Gossip::Version
ROOT = "svn+ssh://marick@rubyforge.org/var/svn/#{PROJECT}"
EXPORTS="#{ENV['HOME']}/tmp/exports"


Hoe.new(PROJECT, THIS_RELEASE) do |p|
  p.rubyforge_name = PROJECT
  p.changes = "See History.txt"
  p.author = "Brian Marick"
  p.description = "Library to broadcast messages to multiple destinations + scripts that use it"
  p.summary = p.description
  p.email = "marick@exampler.com"
  p.extra_deps = [['s4t-utils', '>= 1.0.3'],
                  ['xmpp4r', '>= 0.3.1'],
                  ['tinder', '>= 0.1.4'],
                  ['snitch', '>= 0.1.1'],
                  ['twitter', '>= 0.2.0'],
                  ['user-choices', '>= 1.1.4'],
                 ]
  p.test_globs = "test/**/*tests.rb"
  p.rdoc_pattern = %r{README.txt|History.txt|lib/gossip.rb|lib/gossip/.+\.rb}
  p.url = "http://gossip.rubyforge.org"
  p.remote_rdoc_dir = 'rdoc'
end

require 's4t-utils/rake-task-helpers'
desc "Run fast tests."
task 'fast' do
  S4tUtils.run_particular_tests('test', 'fast')
end

desc "Run slow tests."
task 'slow' do
  S4tUtils.run_particular_tests('test', 'slow')
end

desc "Upload all the web pages"
task 'upload_pages' => ['export'] do
  Dir.chdir("#{EXPORTS}/#{PROJECT}") do
    exec = "scp -r pages/* marick@rubyforge.org:/var/www/gforge-projects/#{PROJECT}/"
    puts exec
    system(exec)
  end
end

desc "Tag release with current version."
task 'tag_release' do
  from = "#{ROOT}/trunk"
  to = "#{ROOT}/tags/rel-#{THIS_RELEASE}"
  message = "Release #{THIS_RELEASE}"
  exec = "svn copy -m '#{message}' #{from} #{to}"
  puts exec
  system(exec)
end

desc "Export to ~/tmp/exports/#{PROJECT}"
task 'export' do 
  Dir.chdir(EXPORTS) do
    rm_rf PROJECT
    exec = "svn export #{ROOT}/trunk #{PROJECT}"
    puts exec
    system exec
  end
end

desc "Complete release of everything"
task 'release_everything' => ['test', 'check_manifest', 'export', 'tag_release']
  Dir.chdir("#{EXPORTS}/#{PROJECT}") do
    `rake release`
    `rake upload_pages`
    `rake publish_docs`
  end