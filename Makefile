console:
	bin/rails c

postgres:
	psql -U 

.PHONY: test_prepare
test_prepare:
	bundle exec rake assets:precompile
	bundle exec rails db:create
	bundle exec rails db:migrate

.PHONY: test
test:
	bin/rails t

.PHONY: lint
lint:
	bundle exec rake factory_bot:lint



