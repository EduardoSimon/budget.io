.PHONY: prepare
prepare:
	bundle install #install dependencies
	bundle exec rake assets:precompile # build Rails Asset pipeline
	bundle exec rails db:prepare # create, migrate and seed database

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
	bundle exec standardrb



