class Budget < ApplicationRecord
  validates :title, presence: true
  has_many :categories, dependent: :destroy
  has_many :accounts, dependent: :destroy
end
