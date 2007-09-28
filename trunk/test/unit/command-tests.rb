require 'test/unit'
require 's4t-utils'
include S4tUtils
set_test_paths(__FILE__)

require 'gossip'

class CommandTests < Test::Unit::TestCase
  include Gossip

  class SomeRandomCommand < GossipCommand    
    def script_config_file; ".localrc"; end
    def gossip_config_file; ".globalrc"; end
    
    def usage; "Usage: ruby #{$0} [options] program args..."; end
    def add_sources(builder)
      builder.add_source(PosixCommandLineSource, :usage, *describe_all_but_options)
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
        require PACKAGE_ROOT + '/test/util/bff'
        OneTestCrony.new(:default_format_string => "scandal: %s, details: %s")
      },
      :doghouse => proc {
        require PACKAGE_ROOT + '/test/util/doghouse'
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
  
  def test_typical_usage_lines
    with_command_args('--help') do
      output = capturing_stderr do
        assert_wants_to_exit do
          SomeRandomCommand.new(@sophie)
        end
      end
      lines = output.split("\n")
      assert_equal("Usage: ruby #{$0} [options] program args...", lines[0])
      assert_match(/Site-wide defaults/, lines[1])
      assert_match(/Override them in the '.localrc' or '.globalrc' files in your home folder./, lines[2])
    end
  end
  
  class LongerUsageCommand < SomeRandomCommand
    def usage; ['line 1', 'line 2']; end
  end
    
  def test_that_usage_lines_can_be_an_array
    with_command_args('--help') do
      output = capturing_stderr do
        assert_wants_to_exit do
          LongerUsageCommand.new(@sophie).execute
        end
      end
      lines = output.split("\n")
      assert_equal("line 1", lines[0])
      assert_equal("line 2", lines[1])
      assert_match(/Site-wide defaults/, lines[2])
    end
      
  end
  
  
  
  
end
