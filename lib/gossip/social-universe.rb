#!/usr/bin/env ruby
#
#  Created by Brian Marick on 2007-09-17.
#  Copyright (c) 2007. All rights reserved.

module Gossip
  
  CronyMaker = {}
  
  def when_not_TOTALLY_out_of_the_social_scene(crony, &crony_maker)
    CronyMaker[crony] = crony_maker
  end

end