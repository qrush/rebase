require 'test_helper'

class RepoTest < ActiveSupport::TestCase
  def test_should_be_valid
    assert Repo.new.valid?
  end
end
