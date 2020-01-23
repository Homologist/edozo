#!/usr/bin/env bash

gpg --keyserver hkp://pool.sks-keyservers.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
\curl -sSL https://get.rvm.io | bash -s stable --ruby

source $HOME/.rvm/scripts/rvm || source /etc/profile.d/rvm.sh

rvm use --default --install $1

shift

if (( $# ))
then gem install $@
fi

rvm cleanup all

sudo apt-get install -y libxslt-dev
sudo apt-get install libxml2-dev

# Install rails
gem install rails -v 6.0.1
gem install bundler
