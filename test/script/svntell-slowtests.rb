#!/usr/bin/env ruby
#
#  Created by Brian Marick on 2007-09-27.
#  Copyright (c) 2007. All rights reserved.

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
    def test_revision_is_required
      as_script_test('.svntell.yml') do
        result = `ruby svntell --repository /svn 2>&1`
        assert_match(/must choose a revision/, result)
      end
    end

    def test_repository_is_required
      as_script_test('.svntell.yml') do
        result = `ruby svntell --revision 5 foo 2>&1`
        assert_match(/must choose a repository/, result)
      end
    end

    def test_svnlook_must_exist
      as_script_test('.svntell.yml') do
        result = `ruby svntell --svnlook /foo/bar --repository /svn --revision 5 foo 2>&1`
        assert_match(%r{svnlook path '/foo/bar' does not exist.}, result)
      end
    end
  end
end