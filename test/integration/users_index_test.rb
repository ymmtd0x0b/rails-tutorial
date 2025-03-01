require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest
  def setup
    @admin = users(:michael)
    @non_admin = users(:archer)
  end

  test 'index as admin including pagination and delete links' do
    log_in_as(@admin)
    get users_path
    assert_template 'users/index'
    assert_select 'div.pagination', count: 2
    first_page_of_users = User.where(activated: true).paginate(page: 1)
    first_page_of_users.each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
      if user != @admin
        assert_select 'a[href=?]', user_path(user), text: 'delete', 'data-method' => 'delete'
      end
    end
    assert_difference 'User.count', -1 do
      delete user_path(@non_admin)
    end
  end

  test 'index as non-admin' do
    log_in_as(@non_admin)
    get users_path
    assert_select 'a', text: 'delete', count: 0
  end

  test 'index exclude non-activation user' do
    non_activation_user = users(:non_activation_user)
    assert_not non_activation_user.activated?

    log_in_as(@non_admin)
    User.paginate(page: 1).total_pages.times do |n|
      current_page = n + 1
      get users_path(page: current_page)
      assert_select 'li', text: non_activation_user.name, count: 0
    end
  end
end
