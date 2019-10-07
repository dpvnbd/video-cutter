FROM ruby:2.6.5
RUN apt-get update -qq && apt-get install -y nodejs postgresql-client ffmpeg
RUN mkdir /vc-api
WORKDIR /vc-api
COPY Gemfile /vc-api/Gemfile
COPY Gemfile.lock /vc-api/Gemfile.lock
RUN bundle install
COPY . /vc-api

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

# Start the main process.
CMD ["rails", "server", "-b", "0.0.0.0", "-e", "production"]
