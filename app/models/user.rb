class User < ApplicationRecord
  devise :database_authenticatable, :recoverable, :validatable

  has_many :notes, dependent: :destroy
end
