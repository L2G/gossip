#! /opt/local/bin/ruby
#
#  Created by Brian Marick on 2007-09-15.
#  Copyright (c) 2007. All rights reserved.

require 'bundler/setup'
require 's4t-utils'
require 'active_support'  # because it includes its own copy of a gem
                          # that user-choices would otherwise include.

require 'gossip/social-universe'
require 'gossip/preteen'
require 'gossip/crony'
require 'gossip/command'
require 'gossip/multi-exceptions'
require 'gossip/version'

# Gossip is a library used to write scripts that collect useful information
# and send it to various places (like jabber, email, trac, etc.). The 
# guiding metaphor is of a Preteen who has Cronies. A Crony is someone who
# might conceivably hear gossip from the Preteen. However, some cronies are
# Best Friends Forever, and others are (temporarily) not speaking to the 
# Preteen. Only the former hear the gossip.
#
# There's also a whole bunch of people who are not Cronies. We won't speak
# of them. All we need know of them is that they can never ever receive
# gossip because they can never ever become a Best Friend Forever.
#
# Most of the code in the script will be in a subclass of GossipCommand.
# The execute method of that command gathers the information and passes
# it to the Preteen.
module Gossip
end
