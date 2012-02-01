#!/usr/bin/env ruby
#
#  Created by Brian Marick on 2007-09-15.
#  Copyright (c) 2007. All rights reserved.

require 'bundler/setup'
require 'xmpp4r'
require 'gossip/crony'

module Gossip
  class JabberCrony < Crony
    include Jabber

    def name; "jabber"; end
    def symbol; :jabber; end

    def command_line_description
        ['-j', "--jabber",
         "Control IM notification.",
         "Defaults to #{is_bff_by_default?}."]
    end

    def add_configuration_choices(builder)
      builder.add_choice(:jabber_to,
                         :default => checked(:default_to),
                         :type => [:string]) { | command_line |
        command_line.uses_option("--jabber-to RECIPIENTS",
                                 "Recipients of Jabber instant messages.",
                                 "This can be a comma-separated list.",
                                 df(:default_to)
                                 )
      }

      builder.add_choice(:jabber_account,
                         :default => checked(:default_account)) { | command_line |
        command_line.uses_option("--jabber-account SENDER", 
                                 "Your Jabber account.",
                                 "Note that this includes the Jabber server.",
                                 df(:default_account)
                                 )
      }

      builder.add_choice(:jabber_password,
                         :default => checked(:default_password)) { | command_line |
        command_line.uses_option("--jabber-password PASSWORD", 
                                 "Your Jabber password.",
                                 df(:default_password)
                                 )
      }
    end
    
    def hear(scandal, details)
      my_jid = JID.new(@user_choices[:jabber_account])
      cl = quiet_client(my_jid)
      cl.connect
      cl.auth(@user_choices[:jabber_password])
      details = [scandal, details].join("\n")
      @user_choices[:jabber_to].each do | recipient | 
        m = Message::new(recipient, details).
          set_type(:normal).set_id('1').set_subject(scandal)
        cl.send(m)
      end
      cl.close
    end
    
    # Current XMPP4R (0.3.1) prints warning message that's not important.
    def quiet_client(my_jid)
      cl = nil
      msg = capturing_stderr do
        cl = Client.new(my_jid, false)
      end
      $stderr.puts msg unless msg =~ /Non-threaded mode is currently broken/
      cl
    end

  end
end