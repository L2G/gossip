require "set-standalone-test-paths.rb" unless $started_from_rakefile
require 'test/unit'
require 's4t-utils'
include S4tUtils

require 'tempfile'
require 'gossip/../../examples/watchdog'

class TestWatchdogCommand < Test::Unit::TestCase
  include Gossip

  class RandomWatchdogCommand < Watchdog
    # Erase behaviors of no interest
    def initialize; end
  end
    

  def test_command_name_ignores_ruby
    dog = RandomWatchdogCommand.new
    assert_equal('echo', dog.command_name(['echo', 'foo']))
    assert_equal('echo.rb', dog.command_name(['ruby', 'echo.rb', 'foo']))
  end

  def test_command_name_is_just_basename
    dog = RandomWatchdogCommand.new
    assert_equal('echo.rb', dog.command_name(['ruby', '/usr/bin/echo.rb', 'foo']))
  end

  def test_timer
    duration, result = RandomWatchdogCommand.new.time {
      sleep 2
      5
    }
    # Rough check because time is inaccurate.
    assert_true(duration >= 1.5)
    assert_equal(5, result)
  end


end

unless S4tUtils.on_windows?
  class TestWatchdogCommandExecution < Test::Unit::TestCase
    def test_command_line_only
      yaml = %q{
        mail: false
        jabber: false
        standard-output: true
      }

      Dir.chdir(PACKAGE_ROOT + "/examples") do
        with_local_config_file('.watchdog.yml', yaml) do
          with_environment_vars("RUBYLIB" => "../lib:"+ (ENV["RUBYLIB"]||".")) do
            stdout = Tempfile.new('stdout')
            stderr = Tempfile.new('stderr')
            actual_string = `ruby watchdog.rb ruby silly-little-test-program.rb 1 2`
            assert_match(/Program silly-little-test-program.rb finished/, actual_string)
            assert_match(/Duration: /, actual_string)
            assert_match(/Command: ruby silly-little-test-program.rb 1 2/, actual_string)
            assert_match(/I mostly write to standard output./, actual_string)
            assert_match(/I also write to standard error./, actual_string)
          end
        end
      end
    end
  end
end