#!/usr/bin/env ruby
#
#  Created by Brian Marick on 2007-09-25.
#  Copyright (c) 2007. All rights reserved.


class Test::Unit::TestCase
  include S4tUtils
  
  def as_script_test(config_name)
    yaml = %q{
      standard-output: true
    }

    Dir.chdir(PACKAGE_ROOT + "/scripts") do
      with_local_config_file(config_name, yaml) do
        yield
      end
    end
  end
  
end