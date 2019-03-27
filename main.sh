#!/bin/bash

# Add chromedriver to path
PATH=/Users/codemang/.chromedriver:$PATH

# Switch to using chruby ruby so gems can be found
source /usr/local/share/chruby/chruby.sh
source /usr/local/share/chruby/auto.sh

cd "$( dirname "$0" )"
bundle exec ruby main.rb schedule
