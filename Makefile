.PHONY: prepare
prepare:
	bundle exec rake assets:precompile
	bundle exec rails db:create db:migrate db:seed

.PHONY: up
up: prepare
	bin/rails s

.PHONY: console
console:
	bin/rails c

.PHONY: postgres
postgres:
	psql -U 

.PHONY: test_prepare
test_prepare:
	bundle exec rake assets:precompile
	bundle exec rails db:create
	bundle exec rails db:migrate

.PHONY: test
test: test_prepare
	bin/rails t

.PHONY: lint
lint:
	bundle exec rake factory_bot:lint



