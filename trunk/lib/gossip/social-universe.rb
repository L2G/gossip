#!/usr/bin/env ruby
#
#  Created by Brian Marick on 2007-09-17.
#  Copyright (c) 2007. All rights reserved.

module Gossip
  
  CronyMaker = {}
  
  # Syntactic sugar to associate a symbol naming a Crony subclass 
  # with a block that knows how to load that class and create an object
  # from it. The symbol must be one returned by Crony#symbol.
 
  def when_not_TOTALLY_out_of_the_social_scene(crony, &crony_maker) 
    CronyMaker[crony] = crony_maker
  end

end