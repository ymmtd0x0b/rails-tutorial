require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
  end

  test 'unsuccessful edit' do
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
end
