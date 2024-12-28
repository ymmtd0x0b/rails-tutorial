require 'test_helper'

class UserShowTest < ActionDispatch::IntegrationTest
  def setup
    @michael = users(:michael)
  end

  test 'show activation user' do
    archer = users(:archer)
    assert archer.activated?

    log_in_as(@michael)
    get user_path(archer)
    assert_template 'users/show'
  end

  test 'show redirect root url when non activation user' do
    non_activation_user = users(:non_activation_user)
    assert_not non_activation_user.activated?

    log_in_as(@michael)
    get user_path(non_activation_user)
    follow_redirect!
    assert_template 'static_pages/home'
  end
end
