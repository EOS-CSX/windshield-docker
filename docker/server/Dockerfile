FROM ubuntu:18.04

###########################
# Backend
###########################

# Install dependencies and Apache -  https://www.tecmint.com/install-apache-web-server-on-ubuntu-18-04/
RUN \
  apt-get update && \
  apt-get install dialog apt-utils net-tools locales curl supervisor git wget -y \
  && apt-get install gnupg gnupg1 gnupg2 -y

#ENV TERM=screen-256color
ENV TERM=xterm
ARG WINDSHIELD_TAG=v0.2.1
ENV REPOTAG="$WINDSHIELD_TAG"
RUN locale-gen en_US.UTF-8
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

ARG SERVERNAME=www.example.com
ENV SERVERNAME="$SERVERNAME"
ENV PORT=4000
ENV MIX_ENV=prod


# Install er-lang
RUN \
  wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb && \
  dpkg -i erlang-solutions_1.0_all.deb && \
  apt-get update && \
  apt-get install elixir esl-erlang -y

# Install mongodb
RUN \
  apt-get install mongodb -y

###########################
## Frontend
##########################

## Install Apache html server
RUN \
  apt-get install -y \
  apache2 git net-tools curl wget vim

# Install apache modules
RUN \
  a2enmod proxy \
  && a2enmod proxy_http \
  && a2enmod proxy_wstunnel \
  && a2enmod rewrite

# Update the default apache site
ADD apache-config.conf /etc/apache2/sites-enabled/000-default.conf
RUN echo ServerName "$SERVERNAME" >> /etc/apache2/apache2.conf


RUN \
  apt-get install -y nodejs npm

RUN \
  cd /tmp \
  && cp -r /var/www/html/ /var/www/html.bak/ \
  && wget https://github.com/cypherglassdotcom/windshield/archive/"$REPOTAG".tar.gz \
  && tar -xvzf "$REPOTAG".tar.gz -C /var/www/html/ --strip 1


WORKDIR /var/www/html/backend
ADD prod.secret.exs start-backend.sh config/
ADD start-backend.sh .

RUN \
  mix local.hex --force \
  && mix local.rebar \
  && mix deps.get \
  && MIX_ENV=prod mix compile



WORKDIR /var/www/html/frontend
RUN sed -i -e "s/localhost/$SERVERNAME/g" ./public/index.html
ADD elm.json .
RUN mkdir /root/.elm-install
RUN npm install -g elm@0.18.0 
RUN npm install -g create-elm-app@1.10.4
RUN npm install -g elm-github-install
RUN npm install 

# Work around for hardcoded path for dependency in package.json
RUN mkdir mkdir -p \
  /usr/local/lib/node_modules/create-elm-app/node_modules/elm/Elm-Platform/0.18.0/.cabal-sandbox/bin/
RUN ln -s /usr/local/bin/elm-make \
  /usr/local/lib/node_modules/create-elm-app/node_modules/elm/Elm-Platform/0.18.0/.cabal-sandbox/bin/elm-make

##############################
# Container Specific
##############################

# Persist volume for mongodb
VOLUME /data/db
VOLUME /windshield/backend/config

ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf
EXPOSE 4000 80

WORKDIR /var/www/html
ADD start-dev.sh .

WORKDIR /var/www/html/backend
CMD ["/usr/bin/supervisord", "-n"]

