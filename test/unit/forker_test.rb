require 'test_helper'

class ForkerTest < ActiveSupport::TestCase
  def test_should_be_valid
    assert Forker.new.valid?
  end
end
