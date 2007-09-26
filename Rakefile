#!/usr/bin/env ruby
#
#  Created by Brian Marick on 2007-07-03.
#  Copyright (c) 2007. All rights reserved.

require 'hoe'
require 'gossip/version'


Hoe.new("gossip", Gossip::Version) do |p|
  p.rubyforge_name = "gossip"
  p.changes = "See History.txt"
  p.author = "Brian Marick"
  p.description = "Library to broadcast messages to multiple destinations + scripts that use it"
  p.summary = p.description
  p.email = "marick@exampler.com"
  p.extra_deps = [['s4t-utils', '>= 1.0.2'],
                  ['xmpp4r', '>= 0.3.1'],
                  ['tinder', '>= 0.1.4'],
                  ['snitch', '>= 0.1.1'],
                  ['twitter', '>= 0.2.0'],
                  ['user-choices', '>= 1.1.3'],
                 ]
  p.test_globs = "test/**/*-tests.rb"
  p.rdoc_pattern = %r{README.txt|History.txt|lib/gossip.rb|lib/gossip/.+\.rb}
  p.url = "http://gossip.rubyforge.org"
  p.remote_rdoc_dir = 'rdoc'
end

desc "Upload all the web pages"
task :upload_pages do
  stage = ENV['HOME'] + "/tmp/stage"
  rm_rf stage
  mkdir_p stage
  Dir.chdir(stage) do
    `svn export svn+ssh://marick@rubyforge.org/var/svn/gossip/trunk/pages pages`
    `scp -r pages/* marick@rubyforge.org:/var/www/gforge-projects/gossip/`
  end
  
end