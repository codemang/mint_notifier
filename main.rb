require 'rubygems'
require 'bundler/setup'
require 'dotenv/load'
require 'time'

require_relative 'mint_client'
require_relative 'summary_notifier'
require_relative 'execution_tracker'

Bundler.require(:default)

module Main
  extend self

  def execute
    if ARGV[0] == 'schedule'
      execute_on_schedule
    else
      execute_for_today
    end
  end

  private

  def execute_for_today
    scrape_and_send_summary_messagae
  end

  def execute_on_schedule
    dates_to_run_for = ExecutionTracker.dates_to_run_for
    scrape_and_send_summary_messagae(dates_to_run_for)
    ExecutionTracker.mark_as_run(dates_to_run_for)
  end

  def scrape_and_send_summary_messagae(dates = [Date.today])
    transactions_by_date = MintClient.fetch_transactions(dates)
    SummaryNotifier.send_summary_message(transactions_by_date)
  end
end

Main.execute
