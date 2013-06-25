require 'test_helper'

class EventsControllerTest < ActionController::TestCase


  test "should get poll" do
    get :poll
    assert_response :success
  end

end
