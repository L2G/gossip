#!/usr/bin/env ruby
#
#  Created by Brian Marick on 2007-09-17.
#  Copyright (c) 2007. All rights reserved.

require "set-standalone-test-paths.rb" unless $started_from_rakefile
require 'test/unit'
require 's4t-utils'
include S4tUtils

require 'gossip'

class ChoicesTests < Test::Unit::TestCase
  include Gossip
  
  def test_that_crony_presence_sets_switch
    # Note that the cronymaker key and Crony name must be the same. 
    # That duplication is an artifact of trying to make the declarations
    # in the scripts (like watchdog.rb) look nice.
    crony_maker = { :winner => proc {@winner = Exhibitionist.named(:winner)},
                    :loser => proc {@loser = Exhibitionist.named(:loser)} }
                    
    sophie = Preteen.new(crony_maker, [:winner], [:loser])
    cmd = SomeRandomCommand.new(sophie)
    
    # Switch is initialized, with default value
    assert_equal(true, cmd.user_choices[:winner])
    assert_equal(false, cmd.user_choices[:loser])
    
    # Shorthand for the default value
    assert_true(@winner.is_bff_by_default?)
    assert_false(@loser.is_bff_by_default?)

    # Cronies share user choices with command.
    assert_equal(@winner.user_choices, cmd.user_choices)
    assert_equal(@loser.user_choices, cmd.user_choices)
  end

  def test_how_command_initializes_a_crony
    crony_maker = { :bff => proc {Exhibitionist.named(:bff)}}
    sophie = Preteen.new(crony_maker, [:bff], [])
    SomeRandomCommand.new(sophie).execute
    assert_equal(['command_line_description()', # This is the crony's only part in determining whether it's called by default
                  'add_configuration_choices()',
                  # Command line and config files are read here
                  'user_choices=()',   # Give crony access to user choices
                  'postprocess_user_choices()',
                  # Can now execute.
                  'hear("boyfriend!", "Joshua")'
                  ], sophie.cronies[0].logged)
  end
  
  
  class Exhibitionist < Crony
    attr_reader :logged, :user_choices, :symbol
    
    def name; symbol.to_s; end
    
    def self.named(sym); new(sym); end
    def initialize(sym)
      @symbol = sym
      @logged = []
      super
    end
    
    def user_choices=(value)
      log("user_choices=")
      @user_choices = value
    end

    def command_line_description()
      log("command_line_description")
      ['-e', "--exhibitionist", "Defaults to #{is_bff_by_default?}."]
    end
    
    def add_configuration_choices(builder)
      log("add_configuration_choices"); 
    end
    def postprocess_user_choices; 
      log("postprocess_user_choices") 
    end
    
    def hear(*args)
      log('hear', *args)
    end

    private 
    
    def log(message, *args); @logged << how_called(message, *args); end
    
    def how_called(message, *args)
      args = args.collect { |a| a.inspect }
      "#{message}(" + args.join(", ") + ")"
    end
    
  end
  

  class SomeRandomCommand < Gossip::GossipCommand    
    
    attr_reader :user_choices
    
    def add_sources(builder)
      # There must be at least a command line.
      builder.add_source(CommandLineSource, :usage,
            "Usage: ruby #{$0} [options] program args...")
    end

    def execute
      preteen.tell_bffs("boyfriend!", "Joshua")
    end
  end
  
  
end