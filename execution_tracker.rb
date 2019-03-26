module ExecutionTracker
  extend self

  TRACKING_FILE = File.join(File.expand_path(File.dirname(__FILE__)), '.execution_tracking.txt')

  # Ensure tracking file always exists
  `touch #{TRACKING_FILE}`

  def dates_to_run_for
    return [] if is_non_sending_hours?

    last_run_date = File.open(TRACKING_FILE, 'r').to_a.last
    current_date = Date.today
    return [current_date] if last_run_date.nil?

    dates_to_run_for = []
    last_run_date = Date.parse(last_run_date)
    return [] if last_run_date == current_date

    while last_run_date != current_date - 1
      last_run_date += 1
      dates_to_run_for << last_run_date
    end

    if is_ideal_sending_hours?
      dates_to_run_for << current_date
    end

    dates_to_run_for
  end

  def mark_as_run(date = Date.today)
    File.open(TRACKING_FILE, 'a') do |f|
      f.puts date
    end
  end

  private

  def is_non_sending_hours?
    hour = Time.new.hour
    hour >= 0 && hour <= 8 # between midnight and 8AM
  end

  def is_ideal_sending_hours?
    hour = Time.new.hour
    hour >= 19 && hour <= 23 # between 9PM and 11PM
  end
end
