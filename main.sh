#!/bin/bash

PATH=/Users/codemang/.chromedriver:$PATH
source /usr/local/share/chruby/chruby.sh
source /usr/local/share/chruby/auto.sh

cd "$( dirname "$0" )"
bundle exec ruby main.rb schedule
