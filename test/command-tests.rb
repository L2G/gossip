require "set-standalone-test-paths.rb" unless $started_from_rakefile
require 'test/unit'
require 's4t-utils'
include S4tUtils

require 'gossip'

class CommandTests < Test::Unit::TestCase
  include Gossip

  class SomeRandomCommand < GossipCommand    
    def add_sources(builder)
      builder.add_source(PosixCommandLineSource, :usage,
            "Usage: ruby #{$0} [options] program args...")
      builder.add_source(YamlConfigFileSource, :from_file, ".sophie.yml")  
      builder.add_source(XmlConfigFileSource, :from_file, ".sophie.xml")  
    end

    def execute
      preteen.tell_bffs("boyfriend!", "Joshua")
      preteen.cronies.collect { |crony| crony.value }
    end
  end
  
  def setup
    crony_maker = {
      :bff => proc {
        require PACKAGE_ROOT + '/test/bff'
        OneTestCrony.new(:default_format_string => "scandal: %s, details: %s")
      },
      :doghouse => proc {
        require PACKAGE_ROOT + '/test/doghouse'
        AnotherTestCrony.new(:default_format_string => "%s: %s")
      }
    }
    
    @sophie = Preteen.new(crony_maker, [:bff], [:doghouse])
  end
  
  def test_behavior_when_not_overridden_is_as_set
    SomeRandomCommand.new(@sophie).execute
    result = @sophie.cronies.collect { |crony|  crony.value }
    assert_equal(["scandal: boyfriend!, details: Joshua", "doghouse crony was not told!"], 
                  result)
  end


  def test_that_config_files_can_change_who_gets_told
    flip = %Q{
        <sophie>
          <bff>false</bff>
          <doghouse>true</doghouse>
        </sophie>
    }
    with_local_config_file('.sophie.xml', flip) {
      SomeRandomCommand.new(@sophie).execute
      result = @sophie.cronies.collect { |crony| crony.value }
      assert_equal(["bff was not told!", "boyfriend!: Joshua"], 
                  result)
    }
  end



  def test_that_both_switches_and_options_can_be_overridden
    reconcile = %Q{
      doghouse: true
    }
    
    with_command_args('--bff-format=%s/%s --doghouse-form %s+%s') {
      with_local_config_file('.sophie.yml', reconcile) {
        SomeRandomCommand.new(@sophie).execute
        result = @sophie.cronies.collect { |crony|  crony.value }
        assert_equal(["boyfriend!/Joshua", "boyfriend!+Joshua"], 
                      result)
      }
    }
  end
  
  
end
