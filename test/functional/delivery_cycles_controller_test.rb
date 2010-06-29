require 'test_helper'

class Admin::DeliveryCyclesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:delivery_cycles)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create delivery_cycle" do
    assert_difference('DeliveryCycle.count') do
      post :create, :delivery_cycle => { }
    end

    assert_redirected_to delivery_cycle_path(assigns(:delivery_cycle))
  end

  test "should show delivery_cycle" do
    get :show, :id => delivery_cycles(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => delivery_cycles(:one).to_param
    assert_response :success
  end

  test "should update delivery_cycle" do
    put :update, :id => delivery_cycles(:one).to_param, :delivery_cycle => { }
    assert_redirected_to delivery_cycle_path(assigns(:delivery_cycle))
  end

  test "should destroy delivery_cycle" do
    assert_difference('DeliveryCycle.count', -1) do
      delete :destroy, :id => delivery_cycles(:one).to_param
    end

    assert_redirected_to delivery_cycles_path
  end
end
