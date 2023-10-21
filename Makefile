TEST_DOCKER_FILES=-f docker-compose.yml -f docker-compose.test.yml
DOCKER_BIN=docker compose

.PHONY: up
up:
	$(DOCKER_BIN) up --build

.PHONY: build
build:
	$(DOCKER_BIN) build

.PHONY: down
down:
	$(DOCKER_BIN) $(TEST_DOCKER_FILES) down --remove-orphans --volumes

.PHONY: clean
clean:
	$(DOCKER_BIN) $(TEST_DOCKER_FILES) down --remove-orphans --volumes --rmi all

.PHONY: test
test:
	$(DOCKER_BIN) $(TEST_DOCKER_FILES) up -d --build
	$(DOCKER_BIN) exec -e RAILS_ENV=test web rails t
	$(DOCKER_BIN) down

.PHONY: lint
lint:
	$(DOCKER_BIN) exec web bundle exec rake factory_bot:lint
	$(DOCKER_BIN) exec web bundle exec standardrb
	
.PHONY: shell-dev
shell-dev:
	$(DOCKER_BIN) up -d --build
	$(DOCKER_BIN) exec -it web /bin/bash

.PHONY: shell-test
shell-test:
	$(DOCKER_BIN) $(TEST_DOCKER_FILES) up -d --build
	$(DOCKER_BIN) exec -it -e RAILS_ENV=test web /bin/bash

.PHONY: rails-console
rails-console: up
	$(DOCKER_BIN) exec web rails c

.PHONY: ruby-prepare
ruby-prepare:
	bundle install
	bundle exec rake assets:precompile
	bundle exec rails db:prepare

.PHONY: ruby-console
ruby-console:
	bin/rails c

.PHONY: ruby-postgres
ruby-postgres:
	psql -U 

.PHONY: ruby-test-prepare
ruby-test-prepare:
	bundle exec rake assets:precompile
	bundle exec rails db:create
	bundle exec rails db:migrate

.PHONY: test
ruby-test: ruby-test-prepare
	bin/rails t

.PHONY: ruby-lint
ruby-lint:
	bundle exec rake factory_bot:lint
	bundle exec standardrb

