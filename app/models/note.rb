class Note < ApplicationRecord
  belongs_to :user
  has_one_attached :file, dependent: :purge
  encrypts :body

  validate :body_or_file_present

  def derived_title
    if body.present?
      body.lines.map(&:strip).find(&:present?)
    elsif file.attached?
      file.filename.to_s
    else
      "Untitled"
    end
  end

  private

  def body_or_file_present
    if body.blank? && !file.attached?
      errors.add(:base, "A note must have a body or an attachment.")
    end
  end
end
