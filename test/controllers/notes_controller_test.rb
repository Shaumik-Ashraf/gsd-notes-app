require "test_helper"

class NotesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user   = User.create!(email: "notetaker@example.com", password: "password123")
    @user_b = User.create!(email: "userb@example.com", password: "password123")
  end

  teardown do
    @user.destroy
    @user_b.destroy
  end

  # ---------- authentication gate ----------

  test "unauthenticated visit to GET /notes redirects to sign-in" do
    get notes_path
    assert_redirected_to new_user_session_path
  end

  test "unauthenticated visit to GET /notes/new redirects to sign-in" do
    get new_note_path
    assert_redirected_to new_user_session_path
  end

  # ---------- index ----------

  test "GET /notes renders index for signed-in user" do
    sign_in @user
    get notes_path
    assert_response :ok
  end

  test "index only shows the current user's notes" do
    @user_b.notes.create!(body: "userb-secret-note")
    sign_in @user
    get notes_path
    assert_no_match "userb-secret-note", response.body
  end

  # ---------- new ----------

  test "GET /notes/new renders form" do
    sign_in @user
    get new_note_path
    assert_response :ok
  end

  # ---------- create ----------

  test "POST /notes with valid body creates note and redirects" do
    sign_in @user
    assert_difference "@user.notes.count", 1 do
      post notes_path, params: { note: { body: "My first note" } }
    end
    assert_response :redirect
  end

  test "POST /notes with file-only note creates note" do
    sign_in @user
    fixture = fixture_file_upload("report.txt", "text/plain")
    assert_difference "@user.notes.count", 1 do
      post notes_path, params: { note: { file: fixture } }
    end
    assert_response :redirect
  end

  test "POST /notes with no body and no file re-renders form with 422 and validation error" do
    sign_in @user
    assert_no_difference "@user.notes.count" do
      post notes_path, params: { note: { body: "" } }
    end
    assert_response :unprocessable_entity
    assert_match "A note must have a body or an attachment.", response.body
  end

  test "POST /notes does not create notes belonging to another user" do
    sign_in @user
    post notes_path, params: { note: { body: "owned" } }
    assert_equal @user, Note.last.user
  end
end
