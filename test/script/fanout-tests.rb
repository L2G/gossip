#!/usr/bin/env ruby
#
#  Created by Brian Marick on 2007-09-25.
#  Copyright (c) 2007. All rights reserved.

require 'test/unit'
require 's4t-utils'
include S4tUtils
set_test_paths(__FILE__)

require 'test/script/util'

unless S4tUtils.on_windows?
  class TestFanoutCommandExecution < Test::Unit::TestCase
    def test_command_line_only
      as_script_test('.fanout.yml') do
        result = `echo "some details" | ruby fanout arg "another arg"`
        lines = result.split("\n")
        assert_match(/arg another arg/, lines.first)
        assert_match(/some details/, lines.last)
      end
    end
  end
end