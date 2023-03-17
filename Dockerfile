FROM ruby:3.1.0

ENV APP_ROOT /usr/src/app
WORKDIR ${APP_ROOT}

COPY Gemfile* .
RUN bundle install

ENTRYPOINT [ "./entrypoint" ]
CMD [ "rails", "s" ]