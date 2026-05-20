require "test_helper"

class NoteTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(email: "noter@example.com", password: "password123")
  end

  teardown do
    @user.destroy
  end

  test "invalid without body or attachment" do
    note = Note.new(user: @user)
    assert_not note.valid?
    assert_includes note.errors[:base], "A note must have a body or an attachment."
  end

  test "valid with body only" do
    note = Note.new(user: @user, body: "Some content")
    assert note.valid?
  end

  test "valid with attachment only" do
    note = Note.new(user: @user)
    note.file.attach(io: StringIO.new("data"), filename: "report.pdf", content_type: "application/pdf")
    assert note.valid?
  end

  test "body is encrypted at rest" do
    note = Note.create!(user: @user, body: "plaintext-marker-xyz")
    raw = ActiveRecord::Base.connection.select_value("SELECT body FROM notes WHERE id = #{note.id}")
    assert_not_includes raw.to_s, "plaintext-marker-xyz"
  end

  test "derived_title returns first non-blank line of body" do
    note = Note.new(user: @user, body: "First line\nSecond line")
    assert_equal "First line", note.derived_title
  end

  test "derived_title skips blank leading lines" do
    note = Note.new(user: @user, body: "   \n\n  Hello")
    assert_equal "Hello", note.derived_title
  end

  test "derived_title returns attachment filename when no body" do
    note = Note.new(user: @user)
    note.file.attach(io: StringIO.new("data"), filename: "report.pdf", content_type: "application/pdf")
    assert_equal "report.pdf", note.derived_title
  end

  test "derived_title returns Untitled when no body and no attachment" do
    note = Note.new(user: @user)
    assert_equal "Untitled", note.derived_title
  end

  test "destroying user destroys their notes" do
    note = Note.create!(user: @user, body: "to be destroyed")
    note_id = note.id
    @user.destroy
    assert_raises(ActiveRecord::RecordNotFound) { Note.find(note_id) }
  end

  test "purging attachment before destroy removes the blob" do
    note = Note.create!(user: @user, body: "with file")
    note.file.attach(io: StringIO.new("data"), filename: "bye.txt", content_type: "text/plain")
    blob_id = note.file.blob.id
    note.file.purge
    note.destroy
    assert_equal 0, ActiveStorage::Blob.where(id: blob_id).count
  end
end
