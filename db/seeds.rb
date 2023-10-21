# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
# Reload the schema due to migrations altering column information
# It can happen when running db:drop db:create db:migrate and db:seed together
ApplicationRecord.reset_column_information

ENV["RAILS_ENV"] = "development"

budget = Budget.create!(title: "Test budget")

institution = Institution.create!(
  institution_id: "04533925-cd07-473d-9b3b-f47a52184b14",
  name: "Test institution"
)

account = Account.create!(name: "Test account",
  institution: institution,
  budget: budget,
  institution_id: institution.id,
  external_account_id: "48883f05-bfe1-46fb-818c-d272ace6a069")

AuthSession.create!(account: account,
  external_id: "707bbbe7-12e3-41e9-98f9-23277b1fb186",
  status: "success",
  external_account_id: "48883f05-bfe1-46fb-818c-d272ace6a069",
  external_institution_id: "SANDBOXFINANCE_SFIN0000")

Category.create!(name: "Food", budget: budget, target_amount_cents: 200_00)
Category.create!(name: "Housing", budget: budget, target_amount_cents: 0)
Category.create!(name: "Cat", budget: budget, target_amount_cents: 0)

def create_movement(amount:, date:, account:, description:, category: nil)
  Movement.create!(
    payer: "payer",
    category: category,
    account: account,
    amount: Money.new(amount, "EUR"),
    description: description,
    created_at: date
  )
end

current_month = DateTime.now.utc.beginning_of_month
previous_month = DateTime.now.utc.beginning_of_month.prev_month
next_month = DateTime.now.utc.beginning_of_month.next_month

create_movement(amount: 600_00, date: previous_month + 2.days, account: account, description: "payment")
create_movement(amount: -50_00, date: previous_month + 4.days, account: account, description: "payment")
create_movement(amount: 50_00, date: previous_month + 6.days, account: account, description: "payment")
create_movement(amount: -40_00, date: previous_month + 8.days, account: account, description: "payment")
create_movement(amount: -20_00, date: previous_month + 10.days, account: account, description: "payment")
create_movement(amount: -40_00, date: previous_month + 12.days, account: account, description: "payment")

create_movement(amount: 600_00, date: current_month + 2.days, account: account, description: "payment")
create_movement(amount: -50_00, date: current_month + 4.days, account: account, description: "payment")
create_movement(amount: 50_00, date: current_month + 6.days, account: account, description: "payment")
create_movement(amount: -40_00, date: current_month + 8.days, account: account, description: "payment")
create_movement(amount: -20_00, date: current_month + 10.days, account: account, description: "payment")
create_movement(amount: -40_00, date: current_month + 12.days, account: account, description: "payment")

create_movement(amount: 600_00, date: next_month + 2.days, account: account, description: "payment")
create_movement(amount: -50_00, date: next_month + 4.days, account: account, description: "payment")
create_movement(amount: 50_00, date: next_month + 6.days, account: account, description: "payment")
create_movement(amount: -40_00, date: next_month + 8.days, account: account, description: "payment")
create_movement(amount: -20_00, date: next_month + 10.days, account: account, description: "payment")
create_movement(amount: -40_00, date: next_month + 12.days, account: account, description: "payment")
