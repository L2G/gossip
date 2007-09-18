#! /opt/local/bin/ruby
#
#  Created by Brian Marick on 2007-09-15.
#  Copyright (c) 2007. All rights reserved.

require 's4t-utils'
require 'active_support'  # because it includes its own copy of a gem
                          # that user-choices would otherwise include.

require 'gossip/social-universe'
require 'gossip/preteen'
require 'gossip/crony'
require 'gossip/command'
require 'gossip/multi-exceptions'
require 'gossip/version'

module Gossip
end
