require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
    @other_user = users(:archer)
  end

  test 'unsuccessful edit' do
    log_in_as(@user)

    get edit_user_path(@user)
    assert_template 'users/edit'

    patch user_path(@user), params: { user: { name: '',
                                              email: 'foo@invalid',
                                              password:              'foo',
                                              password_confirmation: 'bar' } }
    assert_template 'users/edit'
    assert_select 'div.alert', count: 1, text: 'The form contains 4 errors'
  end

  test 'successful edit' do
    log_in_as(@user)

    get edit_user_path(@user)
    assert_template 'users/edit'

    patch user_path(@user), params: { user: { name: 'Foo Bar',
                                              email: 'foo@bar.com',
                                              password:              '',
                                              password_confirmation: ''} }
    assert flash.key?(:success)
    assert_redirected_to @user
    @user.reload
    assert_equal 'Foo Bar', @user.name
    assert_equal 'foo@bar.com', @user.email
  end

  test 'should redirect edit when not logged in' do
    get edit_user_path(@user)
    assert flash.key?(:danger)
    assert_redirected_to login_path
  end

  test 'should redirect update when not logged in' do
    patch user_path(@user), params: { user: { name: 'not_logged_in',
                                              email: 'miss_update@example.com' } }
    assert flash.key?(:danger)
    assert_redirected_to login_path
  end

  test 'should redirect edit when logged in as wrong user' do
    log_in_as(@other_user)
    get edit_user_path(@user)

    assert flash.key?(:danger)
    assert_redirected_to root_path
  end

  test 'should redirect update when logged in as wrong user' do
    log_in_as(@other_user)
    patch user_path(@user), params: { user: { name: 'not_logged_in',
                                              email: 'miss_update@example.com' } }

    assert flash.key?(:danger)
    assert_redirected_to root_path
  end
end
