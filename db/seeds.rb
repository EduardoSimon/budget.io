# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

budget = Budget.create!(title: "Test budget")
account = Account.create!(name: "Test account", institution: Institution.first, budget: budget)
category = Category.create!(name: "groceries", assigned_amount: "20.00", budget: budget)
