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

  # ---------- show ----------

  test "GET /notes/:id renders note show for signed-in owner" do
    note = @user.notes.create!(body: "# Hello\n\nSome **bold** text")
    sign_in @user
    get note_path(note)
    assert_response :ok
    assert_match "<h1>Hello</h1>", response.body
    assert_match "<strong>bold</strong>", response.body
  end

  test "show page includes download link when attachment present" do
    note = @user.notes.create!(body: "with file")
    note.file.attach(io: StringIO.new("data"), filename: "doc.pdf", content_type: "application/pdf")
    sign_in @user
    get note_path(note)
    assert_response :ok
    assert_match "Download doc.pdf", response.body
    assert_match "rails/active_storage", response.body
  end

  test "show page does not render body section when body blank" do
    note = @user.notes.new
    note.file.attach(io: StringIO.new("data"), filename: "only.pdf", content_type: "application/pdf")
    note.save!
    sign_in @user
    get note_path(note)
    assert_response :ok
    assert_no_match "note-body", response.body
  end

  test "show page does not render attachment section when no file" do
    note = @user.notes.create!(body: "body only")
    sign_in @user
    get note_path(note)
    assert_response :ok
    assert_no_match "note-attachment", response.body
  end

  test "GET /notes/:id for another user's note returns 404" do
    other_note = @user_b.notes.create!(body: "secret-b")
    sign_in @user
    get note_path(other_note)
    assert_response :not_found
  end

  test "rendered markdown is sanitized - script tags stripped" do
    note = @user.notes.create!(body: "<script>alert('xss')</script>**ok**")
    sign_in @user
    get note_path(note)
    assert_response :ok
    assert_no_match(/<script[^>]*>alert/, response.body)
    assert_match "<strong>ok</strong>", response.body
  end
end
