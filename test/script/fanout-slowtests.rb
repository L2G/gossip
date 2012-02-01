#!/usr/bin/env ruby
#
#  Created by Brian Marick on 2007-09-25.
#  Copyright (c) 2007. All rights reserved.

require 'bundler/setup'
require 'test/unit'
require 's4t-utils'
S4tUtils.set_test_paths(__FILE__)

require 'test/script/util'

unless S4tUtils.on_windows?
  class TestFanoutCommandExecution < Test::Unit::TestCase
    def test_scandal_and_details
      as_script_test('.fanout.yml') do
        result = `echo "some details" | ruby fanout --details arg "another arg"`
        lines = result.split("\n")
        assert_match(/arg another arg/, lines.first)
        assert_match(/some details/, lines.last)
      end
    end
    
    def test_scandal_alone
      as_script_test('.fanout.yml') do
        result = `ruby fanout --no-det arg "another arg"`
        lines = result.split("\n")
        assert_equal(1, lines.length)
        assert_match(/arg another arg/, lines.first)
      end
    end

    def test_details_are_default
      as_script_test('.fanout.yml') do
        results = `echo sloop | ruby fanout arg "another arg"`
        assert_match(/sloop/, results)
      end
    end

  end
end
