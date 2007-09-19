#! /opt/local/bin/ruby
#
#  Created by Brian Marick on 2007-09-15.
#  Copyright (c) 2007. All rights reserved.

require 'pathname'
$:.unshift((Pathname.new(__FILE__).parent.parent + 'lib').to_s)
require 's4t-utils/load-path-auto-adjuster'

require 's4t-utils'
include S4tUtils

require 'gossip'
include Gossip

# This file will teach you how to make a configuration file that supplies the
# same default values for all programs you use. (Users can still override the
# defaults for any given program in its configuration file.)
require 'gossip/../../examples/config-for-all-examples'

CONFIG_FILE = ".fanoutrc"           # Override site-wide defaults here.


class Fanout < GossipCommand
      
  def postprocess_user_choices
    super

    # This is checked here, instead of giving a range to uses_arglist,
    # so that the actual choices can be printed out with -c without
    # having to give an argument.
    if @user_choices.has_key?(:arglist) && @user_choices[:arglist].empty?
      raise "You need to give some sort of summary on the command line."
    end
  end
  
  def execute
    scandal = @user_choices[:arglist].join(' ')
    details = $stdin.read
    preteen.tell_bffs(scandal, details) 
  end

end    

if $0 == __FILE__
  without_pleasant_exceptions do
    Fanout.new(Preteen.new(CronyMaker, BFFS, ON_THE_OUTS)).execute  
  end
end
