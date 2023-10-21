FROM ruby:3.1.0

ENV APP_ROOT /app
WORKDIR ${APP_ROOT}

COPY Gemfile* .
RUN bundle install

COPY . ${APP_ROOT}

ENTRYPOINT [ "./entrypoint" ]
CMD [ "rails", "s" ]
