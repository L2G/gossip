#!/usr/bin/env ruby
#
#  Created by Brian Marick on 2007-07-03.
#  Copyright (c) 2007 Brian Marick. All rights reserved.
#  Copyright (c) 2012 Lawrence Leonard Gilbert. All rights reserved.

require 'bundler/setup'
require 'hoe'

# Hack: This prevents requires of the same file looking 
# different in tests and causing annoying warnings.
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__)), 'lib')
require 'gossip/version'

PROJECT='gossip'
THIS_RELEASE=Gossip::Version


Hoe.spec(PROJECT) do |p|
  p.rubyforge_name = PROJECT
  p.version = THIS_RELEASE
  p.changes = "See History.txt"
  p.author = ["Brian Marick", "Larry Gilbert"]
  p.description = "Library to broadcast messages to multiple destinations + scripts that use it"
  p.summary = p.description
  p.email = ["marick@exampler.com", "larry@l2g.to"]
  p.extra_deps = [['s4t-utils', '>= 1.0.4'],
                  ['xmpp4r', '>= 0.3.1'],
                  ['tinder', '>= 0.1.4'],
                  ['snitch', '>= 0.1.1'],
                  ['twitter', '>= 0.2.0'],
                  ['user-choices', '>= 1.1.4'],
                 ]
  p.test_globs = ["test/**/*tests.rb"]
  p.readme_file = "README.txt"
  p.history_file = "History.txt"
  p.url = "http://gossip.rubyforge.org"
  p.remote_rdoc_dir = 'rdoc'
end
