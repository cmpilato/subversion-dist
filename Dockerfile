FROM debian:stable

# Fetch required packages.
RUN apt-get update -y
RUN apt-get install -y build-essential subversion python-yaml \
                       pax gettext m4 zip unzip bzip2 gzip \
                       swig python3 py3c-dev

# Setup the application home directory.
ENV APP_HOME="/app"
RUN mkdir $APP_HOME
WORKDIR $APP_HOME
COPY . $APP_HOME
