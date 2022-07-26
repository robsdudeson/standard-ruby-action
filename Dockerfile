FROM ruby:3.1.2-alpine

RUN apk add --update build-base git

LABEL "repository"="https://github.com/testdouble/standard-ruby-action"
LABEL "version"="0.0.3"

COPY lib /action/lib
COPY README.md LICENSE /

RUN gem install bundler

ENTRYPOINT ["/action/lib/entrypoint.sh"]
