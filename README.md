# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

# Development

## Ruby version

Use a ruby dependency manager like rbenv or asdf. The supported ruby version is stated in the .ruby-version file

## Setup

1. Install dependencies

`bundle install`

2. Install postgres

`brew install postgresql`

3. Run postgres as a brew service

`brew services start postgresql`

4. Prepare dabatase

`bin/rails db:create db:migrate db:seed`

5. Run the server

`bin/rails s`

## Installing git hooks

You might install the provided git hooks to prevent committing changes that do not conform to the established style guide.

For such please install `pre-commit` in your system. Refer to the [docs](https://pre-commit.com/#install) on how to install it.

Once set up, you will need to install the hooks in your local repository. Please run:

```
pre-commit install
```

After a successful execution, the commit hoo will trigger when committing files.

# Testing

`make test`

# Linting

`make lint`

# Domain

✅ A `budget` is a collection of `categories`.
✅ A `category` has a name and an `allocated_amount` per month.
✅ A `target amount` is the desired allocated amount for a given `category`
A `category` can be:

- `overspent` when the sum of movements is greater than the `allocated_amount`
- `underfunded` when the `allocated_amount` is smaller than the `target amount`
- `funded` when the `allocated_amount` is equal or greater than the `target_amount` and the sum of movements is fewer tham the `allocated_amount`

The `allocated_amount` of a category is depleted by each `movement`.
A `movement` belongs to an account. It can be a `credit` or a `debit`.
✅ A `credit` is a money movement flowing out of your account.
✅ A `debit` is a money movement flowing into your account.
✅ A `movement` has a `payer`.
✅ A `movement` can be assigned to a `category`
Every unassigned movement will be considered `Ready to asign` funds, i.e funds to be added to the budget.
