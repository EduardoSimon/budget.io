class Budget < ApplicationRecord
  validates :title, presence: true
  has_many :categories,  -> { order("name") }, dependent: :destroy
  has_many :accounts, dependent: :destroy
  has_many :movements, -> { includes(:account) }, through: :accounts
  after_create :create_ready_to_assign_category!

  def uncategorized_movements_in(current_month)
    beginning_of_month = current_month.beginning_of_month
    end_of_month = current_month.end_of_month
    movements.between_dates(beginning_of_month, end_of_month)
      .where(category_id: nil, transfer_to_account_id: nil)
  end

  def ready_to_assign
    ready_to_assign_cents = Category.find(ready_to_assign_category_id).spent_amount_cents
    assigned_cents_in_categories = categories
      .joins(:monthly_assignments)
      .where
      .not(id: ready_to_assign_category_id)
      .sum('monthly_assignments.amount_cents')
    Money.new(ready_to_assign_cents - assigned_cents_in_categories, ready_to_assign_currency)
  end

  private 


  def create_ready_to_assign_category!
    ready_to_assign_category = Category.create(budget_id: id, name: "Ready to Assign")
    update!(ready_to_assign_category_id: ready_to_assign_category.id)
  end
end   
