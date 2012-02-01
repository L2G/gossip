require 'bundler/setup'
require 'test/unit'
require 's4t-utils'
include S4tUtils
set_test_paths(__FILE__)

require 'gossip'


class PreteenTests < Test::Unit::TestCase
  include Gossip

  class SilentCrony < Crony
    attr_reader :scandal, :details
    
    def name; "silent"; end
    def symbol; :silent; end
    
    def hear(scandal, details)
      @scandal = scandal
      @details = details
    end
  end

  class WhiningCrony < Crony
    def name; "whiner"; end
    def symbol; :whiner; end

    def hear(scandal, details)
      raise StandardError.new("whine: #{scandal}")
    end
  end
    
  def make(crony_class, init)
    prog1(crony_class.new) do | crony |
      crony.user_choices = init
    end
  end
  
  def test_preteen_fails_nicely_when_given_bad_cronies
    assert_raises_with_matching_message(StandardError, /:wrong_crony is not a known crony/) {
      Preteen.new({}, [:wrong_crony], [])
    }
    assert_raises_with_matching_message(StandardError, /:wrong_crony is not a known crony/) {
      Preteen.new({}, [], [:wrong_crony])
    }
  end
  

  def test_preteen_tells_bffs
    silent = make(SilentCrony, :silent => true)
    whiner = make(WhiningCrony, :whiner => false)

    preteen = Preteen.new
    preteen.accept(silent, whiner)
    preteen.tell_bffs('scandal', 'details')
    
    assert_equal('scandal', silent.scandal)
    assert_equal('details', silent.details)
  end

  def test_preteen_gathers_failures
    preteen = Preteen.new
    silent = make(SilentCrony, :silent => true)
    preteen.accept(make(WhiningCrony, :whiner => true), 
                   silent,
                   make(WhiningCrony, :whiner => true),
                   make(WhiningCrony, :whiner => true))
    preteen.tell_bffs('fact', 'embellishments')
  rescue MultiException => ex
    messages = ex.message.split("\n")
    # Three whining messages
    assert_equal(3, messages.grep(/Complaint from whiner: whine: fact \(StandardError\)/).length)
    # But failures don't interfere with success.
    assert_equal('fact', silent.scandal)
    assert_equal('embellishments', silent.details)
  else
    fail("No exception thrown.")
  end    

    
end
