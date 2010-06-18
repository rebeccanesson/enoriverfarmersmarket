require 'test_helper'

class OrderablesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:orderables)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create orderable" do
    assert_difference('Orderable.count') do
      post :create, :orderable => { }
    end

    assert_redirected_to orderable_path(assigns(:orderable))
  end

  test "should show orderable" do
    get :show, :id => orderables(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => orderables(:one).to_param
    assert_response :success
  end

  test "should update orderable" do
    put :update, :id => orderables(:one).to_param, :orderable => { }
    assert_redirected_to orderable_path(assigns(:orderable))
  end

  test "should destroy orderable" do
    assert_difference('Orderable.count', -1) do
      delete :destroy, :id => orderables(:one).to_param
    end

    assert_redirected_to orderables_path
  end
end
