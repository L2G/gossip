#! /opt/local/bin/ruby
#
#  Created by Brian Marick on 2007-09-15.
#  Copyright (c) 2007. All rights reserved.

require 'gossip/multi-exceptions'
require 'gossip/crony'

module Gossip

  # A Preteen is someone who tells her Best Friends Forever some gossip. 
  # Each BFF is a Crony, but some Cronies can be out of favor during a 
  # particular invocation of a script. A Crony who's out of favor is not 
  # told the gossip.
  class Preteen
    include Gossip

    attr_reader :cronies
    
    # The second and third arguments are symbols that name Crony subclasses. 
    # (See Crony#symbol.) The first
    # set will hear gossip; the second will not. The _cronymaker_ is a hash. 
    # It is indexed by crony symbol. The values are blocks that first load
    # the Crony subclass's source, then return a new crony of that class. 
    def initialize(cronymaker = nil, bff =[], on_the_outs_forever_and_ever_until_tomorrow=[])
      @cronies = []
      (bff+on_the_outs_forever_and_ever_until_tomorrow).each do | name |
        crony = cronymaker[name].call
        crony.is_bff_by_default = bff.include?(name)
        accept(crony)
      end
    end

    def accept(*cronies) # :nodoc: 
      @cronies += cronies
    end

    # Tell Crony objects who are in favor (best friends forever) a _scandal_
    # and its _details_. The _scandal_ should be short - think an email
    # Subject line.
    def tell_bffs(scandal, details)
      simultaneously do | crony | 
        crony.hear(scandal, details) if crony.is_bff?
      end
    end
    
    
    
    private 

    def annotate(exception, crony)
      # Note: cannot raise exception.class because on Windows the 
      # exception message for Net errors will contain duplicate errors.
      # This is annoying because with_pleasant_exceptions appends the
      # exception class. So we have to append it ourselves.
      annotated = StandardError.new("Complaint from #{crony.name}: #{exception.to_s} (#{exception.class})")
      annotated.set_backtrace(exception.backtrace)
      annotated
    end


    def simultaneously # execute block in thread
      Thread.abort_on_exception = false
      queue = Queue.new
      threads = @cronies.collect do | crony |
        Thread.new(crony) do | crony |
          begin
            yield(crony)
          rescue Exception => ex
            queue << annotate(ex, crony)
          end
        end
      end
      threads.each { | thread | thread.join }
      # This peculiarness is the way to set the exception's
      # backtrace with the combination of the backtraces of
      # all saved exceptions (if any)
      MultiException.reraise_with_combined_backtrace { 
        raise MultiException.new(queue.to_a) if queue.length > 0
      }
    end
  end               
end
