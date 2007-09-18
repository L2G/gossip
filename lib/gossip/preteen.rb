#! /opt/local/bin/ruby
#
#  Created by Brian Marick on 2007-09-15.
#  Copyright (c) 2007. All rights reserved.

require 'gossip/multi-exceptions'
require 'gossip/crony'

module Gossip

  # A Preteen is a collection of cronies who all hear the same gossip. 
  # The current state of the preteen is from the point of view of one of 
  # its members, who has an important fact to tell... to those preteen members
  # she's talking to today.
  class Preteen
    include Gossip

    attr_reader :cronies
    
    def initialize(cronymaker = nil, bff =[], on_the_outs_forever_and_ever_until_tomorrow=[])
      @cronies = []
      (bff+on_the_outs_forever_and_ever_until_tomorrow).each do | name |
        crony = cronymaker[name].call
        crony.on_by_default = bff.include?(name)
        accept(crony)
      end
    end

    def accept(*cronies)
      @cronies += cronies
    end

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
