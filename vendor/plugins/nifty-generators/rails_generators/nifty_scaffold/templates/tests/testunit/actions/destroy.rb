  def test_destroy
    <%= singular_name %> = <%= class_name %>.first
    delete :destroy, :id => <%= singular_name %>
    assert_redirected_to <%= plural_name %>_url
    assert !<%= class_name %>.exists?(<%= singular_name %>.id)
  end
