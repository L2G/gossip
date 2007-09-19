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

CONFIG_FILE = ".svntellrc"           # Override site-wide defaults here.
require 'snitch'

pi ARGV, '-----------'

class SvnTell < GossipCommand
  
  def add_choices(builder)    
    builder.add_choice(:svn_repository) { | command_line |
      command_line.uses_option("--repository REP",
                               "Absolute path of subversion repository.")
    }

    builder.add_choice(:svn_revision) { | command_line |
      command_line.uses_option("--revision REV",
                               "Revision number of interest.")
    }

    svnlook_default = "/usr/bin/svnlook"
    builder.add_choice(:svnlook_path,
                       :default => svnlook_default) { | command_line |
      command_line.uses_option("--svnlook-path PATH",
                               "Absolute path of svnlook(1).",
                               "Default is #{svnlook_default}.")
    }
    super
  end
  
  def required(choice)
    raise StandardError, "#{choice} is required." if @user_choices[choice].nil?
  end
      
  def postprocess_user_choices
    super
    pp @user_choices
    [:svn_repository, :svn_revision].each {|e| required(e)}
  end
  
  def execute
    svntext = Snitch::SvnLook.new(@user_choices[:svn_repository], 
                                  @user_choices[:svn_revision],
                                  @user_choices[:svnlook_path])
    preteen.tell_bffs('commit', svntext) 
  end

end    

if $0 == __FILE__
  without_pleasant_exceptions do
    SvnTell.new(Preteen.new(CronyMaker, BFFS, ON_THE_OUTS)).execute  
  end
end
