FROM ubuntu:14.04
MAINTAINER Chris Kacerguis "kacerguis_christopher@bah.com"
LABEL version="1.0"
LABEL description="Project Jellyfish Core"

RUN apt-get update
RUN apt-get install -y git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev  
RUN apt-get install -y libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties
RUN apt-get install -y libffi-dev ntp npm nginx wget nodejs-legacy

RUN echo 'deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main' > /etc/apt/sources.list.d/pgdg.list
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -

RUN apt-get update

RUN git clone https://github.com/sstephenson/rbenv.git ~/.rbenv
RUN echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile
RUN echo 'eval "$(rbenv init -)"' >> ~/.bash_profile

RUN git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build

RUN git clone https://github.com/projectjellyfish/api.git /root/api

RUN bash -c 'source ~/.bash_profile;rbenv install "$(cat /root/api/.ruby-version)"'
RUN bash -c 'source ~/.bash_profile;rbenv global "$(cat /root/api/.ruby-version)"'

RUN apt-get install -y --force-yes postgresql-9.4 postgresql-contrib-9.4 libpq-dev

RUN bash -c "source ~/.bash_profile;gem install pg -v '0.18.2' -- --with-pg-config=/usr/bin/pg_config"

RUN bash -c "source ~/.bash_profile;gem install bundler"

RUN bash -c "source ~/.bash_profile;cd /root/api;bundle install"

RUN bash -c "npm install bower -g"
RUN bash -c "npm install gulp -g"

RUN bash -c "cd /root/api;npm install"

CMD bash -c "source ~/.bash_profile;cd /root/api;rails s -b 0.0.0.0"

# ENV DATABASE_URL <set db url>
# ENV DEVISE_SECRET_KEY <random key>
# ENV MOCK_FOG true
# ENV AWS_ACCESS_KEY <aws access key>
# ENV AWS_SECRET_KEY <aws secret key>

# docker build -t jellyfish .
# docker run -d -p 3000:3000 jellyfish

# Finished