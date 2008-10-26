require 'test_helper'

class ReposControllerTest < ActionController::TestCase
  def test_index
    get :index
    assert_template 'index'
  end
  
  def test_show
    get :show, :id => Repo.first
    assert_template 'show'
  end
  
  def test_new
    get :new
    assert_template 'new'
  end
  
  def test_create_invalid
    Repo.any_instance.stubs(:valid?).returns(false)
    post :create
    assert_template 'new'
  end
  
  def test_create_valid
    Repo.any_instance.stubs(:valid?).returns(true)
    post :create
    assert_redirected_to repo_url(assigns(:repo))
  end
  
  def test_edit
    get :edit, :id => Repo.first
    assert_template 'edit'
  end
  
  def test_update_invalid
    Repo.any_instance.stubs(:valid?).returns(false)
    put :update, :id => Repo.first
    assert_template 'edit'
  end
  
  def test_update_valid
    Repo.any_instance.stubs(:valid?).returns(true)
    put :update, :id => Repo.first
    assert_redirected_to repo_url(assigns(:repo))
  end
  
  def test_destroy
    repo = Repo.first
    delete :destroy, :id => repo
    assert_redirected_to repos_url
    assert !Repo.exists?(repo.id)
  end
end
