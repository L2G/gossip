#!/usr/bin/env ruby
#
#  Created by Brian Marick on 2007-09-15.
#  Copyright (c) 2007. All rights reserved.

require 'net/smtp'

module Gossip
  
  # This Crony sends email.
  class SmtpCrony < Crony

    def name; 'mail'; end
    def symbol; :mail; end
    
    def command_line_description
      ['-m', "--mail",
       "Control mail notification.",
       "Defaults to #{is_bff_by_default?}."]
    end
    
    def add_configuration_choices(builder)
      builder.add_choice(:mail_to,
                         :default => checked(:default_to),
                         :type => [:string]) { | command_line |
        command_line.uses_option("--mail-to RECIPIENTS",
                                 "Recipients of mail.",
                                 "This can be a comma-separated list.",
                                 df(:default_to)
                                 )
      }

      builder.add_choice(:mail_from,
                         :default => checked(:default_from)) { | command_line |
        command_line.uses_option("--mail-from SENDER", 
                                 "The sender of the mail (appears in From line).",
                                 df(:default_from)
                                 )
      }

      builder.add_choice(:mail_server,
                         :default => checked(:default_smtp_server)) { | command_line |
        command_line.uses_option("--mail-server HOSTNAME", 
                                 "SMTP server. #{df(:default_smtp_server)}"
                                 )
      }

      builder.add_choice(:mail_port,
                         :type => :integer,
                         :default => checked(:default_smtp_port)) { | command_line |
        command_line.uses_option("--mail-port NUMBER", 
                                 "Mail port on that server.",
                                 df(:default_smtp_port)
                                 )
      }

      builder.add_choice(:mail_account,
                         :default => checked(:default_smtp_account)) { | command_line |
        command_line.uses_option("--mail-account USERNAME", 
                                 "Your account name on the SMTP server.",
                                 df(:default_smtp_account)
                                 )
      }

      builder.add_choice(:mail_from_domain,
                         :default => checked(:default_from_domain)) { | command_line |
        command_line.uses_option("--mail-from-domain HOSTNAME", 
                                 "The server the mail supposedly comes from.",
                                 "(Not necessarily the SMTP server.)",
                                 df(:default_from_domain)
                                 )
      }

      builder.add_choice(:mail_password,
                         :default => checked(:default_smtp_password)) { | command_line |
        command_line.uses_option("--mail-password HOSTNAME", 
                                 "Your password on the SMTP server.",
                                 df(:default_smtp_password)
                                 )
      }

      auth_types = ['plain', 'login', 'cram_md5']
      builder.add_choice(:mail_authentication,
                         :type => auth_types,
                         :default => checked(:default_smtp_authentication)) { | command_line |
        command_line.uses_option("--mail-authentication TYPE",
                                 "The kind of authentication your SMTP server uses.",
                                 "One of #{friendly_list('or', auth_types)}.",
                                 df(:default_smtp_authentication)
                                 )
      }
    end
    
    def postprocess_user_choices
      @user_choices[:mail_authentication] =
        @user_choices[:mail_authentication].to_sym
    end
    
    def hear(scandal, details)
      from = @user_choices[:mail_from]
      to = @user_choices[:mail_to]
      Net::SMTP.start(@user_choices[:mail_server], @user_choices[:mail_port],
                      @user_choices[:mail_from_domain],
                      @user_choices[:mail_account],
                      @user_choices[:mail_password],
                      @user_choices[:mail_authentication]) { | smtp |
        mail = "
                . From: #{from}
                . To: #{to.join(', ')}
                . Subject: [watchdog] #{scandal}
                .
                . #{details}
               ".trim('.')
        smtp.send_message(mail, from, to)
      }
    end
  end

  
  
end