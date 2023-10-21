FROM ruby:3.1.0

ENV APP_ROOT /app
WORKDIR ${APP_ROOT}

COPY Gemfile* .
RUN bundle install

COPY . ${APP_ROOT}

RUN bundle exec rake assets:precompile

ENTRYPOINT [ "./entrypoint" ]
CMD [ "rails", "s" ]
