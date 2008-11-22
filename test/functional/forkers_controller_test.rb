require 'test_helper'

class ForkersControllerTest < ActionController::TestCase
  def test_index
    get :index
    assert_template 'index'
  end
  
  def test_show
    get :show, :id => Forker.first
    assert_template 'show'
  end
  
  def test_new
    get :new
    assert_template 'new'
  end
  
  def test_create_invalid
    Forker.any_instance.stubs(:valid?).returns(false)
    post :create
    assert_template 'new'
  end
  
  def test_create_valid
    Forker.any_instance.stubs(:valid?).returns(true)
    post :create
    assert_redirected_to forker_url(assigns(:forker))
  end
  
  def test_edit
    get :edit, :id => Forker.first
    assert_template 'edit'
  end
  
  def test_update_invalid
    Forker.any_instance.stubs(:valid?).returns(false)
    put :update, :id => Forker.first
    assert_template 'edit'
  end
  
  def test_update_valid
    Forker.any_instance.stubs(:valid?).returns(true)
    put :update, :id => Forker.first
    assert_redirected_to forker_url(assigns(:forker))
  end
  
  def test_destroy
    forker = Forker.first
    delete :destroy, :id => forker
    assert_redirected_to forkers_url
    assert !Forker.exists?(forker.id)
  end
end
