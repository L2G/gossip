require 'bundler/setup'
require 'test/unit'

set_test_paths(__FILE__)

require 'gossip'

# Most of the crony behavior is interaction with Command, so see 
# command-tests.rb

class ChoicesTests < Test::Unit::TestCase
  include Gossip

  class ConcreteCrony < Crony
    def name; 'non-abstract'; end
    def symbol; :sym; end
  end

  def test_crony_checks_for_typos
    crony = ConcreteCrony.new(:key => 'value')
    
    assert_equal('value', crony.checked(:key))
    assert_raises_with_matching_message(StandardError, /:ky is nil.*#{crony.name}.*typo/) do 
      crony.checked(:ky)
    end
  end
  
  
  def test_crony_can_describe_defaults
    crony = ConcreteCrony.new(:key => 'value')
    assert_equal('Defaults to "value".', crony.df(:key))

    assert_raises_with_matching_message(StandardError, /:ky is nil.*#{crony.name}.*typo/) do 
      crony.checked(:ky)
    end
  end
  
  def test_crony_friendship_depends_on_user_choices
    crony = ConcreteCrony.new
    crony.user_choices=({:sym => true})
    assert_true(crony.is_bff?)
    crony.user_choices=({:sym => false})
    assert_false(crony.is_bff?)
  end
  
end
