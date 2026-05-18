require "application_system_test_case"

class AuthenticationTest < ApplicationSystemTestCase
  def sign_in_as(email, password)
    visit new_user_session_path
    fill_in "Email", with: email
    fill_in "Password", with: password
    click_button "Sign in"
  end

  test "user with console-created credentials can sign in and lands on root" do
    User.create!(email: "user@example.com", password: "password123")
    sign_in_as "user@example.com", "password123"
    assert_text "Signed in as user@example.com"
    assert_equal root_path, current_path
  end

  test "session persists across browser refresh" do
    User.create!(email: "persist@example.com", password: "password123")
    sign_in_as "persist@example.com", "password123"
    assert_text "Signed in as persist@example.com"
    visit current_path
    assert_text "Signed in as persist@example.com"
    assert_equal root_path, current_path
  end

  test "user can sign out from any page and is redirected to sign-in; root is then blocked" do
    User.create!(email: "signout@example.com", password: "password123")
    sign_in_as "signout@example.com", "password123"
    assert_text "Signed in as signout@example.com"
    click_button "Sign out"
    assert_selector "h1", text: "Notes"
    assert_equal new_user_session_path, current_path
    visit root_path
    assert_selector "h1", text: "Notes"
    assert_equal new_user_session_path, current_path
  end

  test "no sign-up or forgot-password link is rendered anywhere on the sign-in page" do
    visit new_user_session_path
    assert page.has_no_link?("Sign up"), "expected no Sign up link on sign-in page"
    assert page.has_no_link?("Forgot your password?"), "expected no Forgot your password link"
    assert page.has_no_field?("user_remember_me"), "expected no remember me checkbox"
    assert page.has_no_content?("Sign up"), "expected no Sign up text on sign-in page"
  end

  test "invalid credentials show the generic error message" do
    User.create!(email: "error@example.com", password: "password123")
    sign_in_as "error@example.com", "wrongpassword"
    assert_text "Invalid email or password."
  end
end
