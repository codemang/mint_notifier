Mint Scraper And Notifier
=========================

A script that serves two functions.

1. Scrapes Mint for daily spend and income
1. Sends me a text with my aggregrate and itemized spend/income every night at 10PM

## Rationale

I wanted to get better insight into my daily spending. There are many spending
apps out there, but they  offer more features than I want and lack the simple
notifications I do want. This began as a weekend hack project that eventually
grew into a more robust app driven by Plaid.

## Overview

This solution is **hacky**! And I love hacky things :)

This is a general overview of how the script interacts with Mint

1. The script simulates a browser with Capybara/Selenium
1. The script visits the Mint homepage
1. The script logs in with username/password
1. Mint will then text you a login token to your phone
1. The script finds the Mint text by looking through your local iMessage chats
1. The script inputs the login token and completes authentication
1. The script navigates to the transactions page
1. The script collects all transactions for the current date
1. The script creates a summary message of the transactions and uses Twilio to
   send you the summary message

## Requirements

* Ruby and Bundle
* Mint Account
* Twilio Account
* Macbook, iPhone, and a shared iMessage account between the two devices


## Building

1. Clone the repo

```bash
$ git clone XXXXXXXXXXXXX
```

2. Install gems

```bash
$ bundle i
```

3. Install [chromedriver](http://chromedriver.storage.googleapis.com/index.html)
   and put the executable somewhere in your path. As of the time of this writing
   I'm using version
   [2.46](https://chromedriver.storage.googleapis.com/index.html?path=2.46/) but
   you can find the latest version [here](https://chromedriver.storage.googleapis.com/LATEST_RELEASE).

4. Copy the env template and fill it out with your values

```bash
$ cp .env.template .env
```

## Running

There are two main ways to run this program.

**Run Manually**

This command will immediately send a text with today's spend/income. This is useful to test that everything is setup correctly.

```bash
$ bundle exec ruby main.rb
```

**Run Periodically**

The real reason I built this script was to receive a text every night with my
spend/income. To do that I used cron.

When a script is run via cron it doesn't have the same PATH or other
environment variables as when you are running the script yourself. For
example, if I used this cron command...

```bash
0 0 22 * * bundle exec ruby /Users/codemang/Personal/mint/main.rb
```

It would use the system ruby. This would break for me, because I use a different
version of ruby when developing. Gems that have been installed are scoped to the
ruby version, so my system ruby would not find the required gems for this
script. It would also likely complain that it couldn't find the chromedriver
executable.

To solve this problem, I created a bash script [main.sh](https://github.com/codemang/mint_scraper/blob/master/main.sh) which would first configure the
environment. The three things that needed to be done were...
  1. Use the correct ruby build. I use chruby to manage my ruby versions so you
     can see calls to their startup scripts.

  1. Add chromedriver to the path

  1. Call the script

```bash
# Add chromedriver to path
PATH=/Users/codemang/.chromedriver:$PATH

# Switch to using chruby ruby so gems can be found
source /usr/local/share/chruby/chruby.sh
source /usr/local/share/chruby/auto.sh

# Call the script
cd "$( dirname "$0" )"
bundle exec ruby main.rb schedule
```

Now I can add this to my crontab and the script will run successfully.

```bash
0 0 22 * * /Users/codemang/Personal/mint_notifier/main.sh
```

Lastly, since I only want to receive one text at 10PM, I could try to setup my
cron as above. But what if I had my computer closed? The script wouldn't run and
no text would be sent for the day.

To make this more resilient, I run the script every five minutes and track when
texts have been sent to avoid double texting.  If my computer is closed at 10PM
but I open at 11PM, it will send the text then.  Additionally, if my computer
has been closed for multiple days, it will send texts for those missed days.

To enable this functionality, you just have to pass in `schedule` as a command
line argument, which you can see in
[main.sh](https://github.com/codemang/mint_scraper/blob/master/main.sh). The
final cron command is...

```bash
*/5 * * * * /Users/codemang/Personal/mint_notifier/main.sh
```

## Viewing The Browser

If you want to view the browser as it is being automated, just call the script
with `VISIBLE_BROWSER=true`
