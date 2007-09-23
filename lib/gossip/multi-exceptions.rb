#! /opt/local/bin/ruby
#
#  Created by Brian Marick on 2007-09-15.
#  Copyright (c) 2007. All rights reserved.



require 'thread'

class Queue # :nodoc:
  def to_a
    result = []
    until empty?
      result << self.pop
    end
    result
  end
end

module Gossip
  # This collects exceptions from several threads and packages them up 
  # into a single exception.
  class MultiException < StandardError

    attr_reader :traces
    
    def initialize(exceptions)
      messages = exceptions.collect { | ex | "#{ex.to_s} (#{ex.class})" }
      super(messages.join("\n"))
      @traces = exceptions.collect { | ex | ex.backtrace }
    end

    def self.reraise_with_combined_backtrace
      yield
    rescue MultiException => ex
      ex.traces.each_with_index { | trace, index | 
        trace.unshift("Trace number #{index}:\n")
      }
      ex.set_backtrace(ex.traces.flatten)
      raise
    end
      
    
  end
  
end
  
