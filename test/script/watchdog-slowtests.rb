require 'bundler/setup'
require 'test/unit'

set_test_paths(__FILE__)

require 'test/script/util'
load "#{PACKAGE_ROOT}/scripts/watchdog"

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
      as_script_test('.watchdog.yml') do
        actual_string = `ruby watchdog ruby ../test/util/silly-little-test-program.rb 1 2`
        assert_match(/Program silly-little-test-program.rb finished/, actual_string)
        assert_match(/Duration: /, actual_string)
        assert_match(%r{Command: ruby ../test/util/silly-little-test-program.rb 1 2}, actual_string)

        assert_match(/I mostly write to standard output./, actual_string)
        assert_match(/I also write to standard error./, actual_string)
      end
    end
  end
end
