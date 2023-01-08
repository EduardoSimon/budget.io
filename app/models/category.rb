class Category < ApplicationRecord
  validates :name, presence: true

  has_many :movements, dependent: :destroy
  belongs_to :budget
end
