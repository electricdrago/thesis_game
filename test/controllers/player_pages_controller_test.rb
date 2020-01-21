require 'test_helper'

class PlayerPagesControllerTest < ActionDispatch::IntegrationTest
  test "should get home" do
    get player_pages_home_url
    assert_response :success
  end

end
