#!/usr/bin/env ruby
#
#  Created by Brian Marick on 2007-07-03.
#  Copyright (c) 2007. All rights reserved.

require 'hoe'

Dir.chdir('lib') do
  # Hack: This prevents requires of the same file looking 
  # different in tests and causing annoying warnings.
  require 'gossip/version'
end

PROJECT='gossip'
THIS_RELEASE=Gossip::Version


Hoe.new(PROJECT, THIS_RELEASE) do |p|
  p.rubyforge_name = PROJECT
  p.changes = "See History.txt"
  p.author = "Brian Marick"
  p.description = "Library to broadcast messages to multiple destinations + scripts that use it"
  p.summary = p.description
  p.email = "marick@exampler.com"
  p.extra_deps = [['s4t-utils', '>= 1.0.4'],
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

require 's4t-utils/hoelike'
HoeLike.new(:project => PROJECT, :this_release => THIS_RELEASE,
            :login => "marick@rubyforge.org",
            :web_site_root => 'pages', 
            :export_root => "#{S4tUtils.find_home}/tmp/exports")


