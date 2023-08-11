console:
	rails c

postgres:
	psql -U 

.PHONY: test_prepare
test_prepare:
	bundle exec rake assets:precompile
	bundle exec rails db:create
	bundle exec rails db:migrate

.PHONY: test
test:
	rails t

.PHONY: lint
lint:
	bundle exdc rake factory_bot:lint



