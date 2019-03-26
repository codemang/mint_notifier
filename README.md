Mint Scraper And Notifier
=========================

A script that serves two functions.

1. Scrapes Mint for daily spend and income
1. Sends me a text with my aggregrate and itemized spend/income at 10PM

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

* Mint Account
* Twilio Account
* Macbook, iPhone, and a shared iMessage account between the two devices


## Running

1. Clone the repo

```
$ git clone XXXXXXXXXXXXX
```

2. Install gems

```
$ bundle i
```

3. Install [chromedriver](http://chromedriver.storage.googleapis.com/index.html)
   and put the executable somewhere in your path. As of the time of this writing
   I'm using version
   [2.46](https://chromedriver.storage.googleapis.com/index.html?path=2.46/) but
   you can find the latest version [here](https://chromedriver.storage.googleapis.com/LATEST_RELEASE).

4. Copy the env template and fill it out with your values

```
$ cp .env.template .env
```

5. You should now be able to test that the app works by running it manually.

```
$ bundle exec ruby main.rb
```
