module MintClient
  extend self

  def fetch_transactions(dates = [Date.today])
    Capybara.default_max_wait_time = 10

    session = ENV['VISIBLE_BROWSER'] ?
      Capybara::Session.new(:selenium) :
      Capybara::Session.new(:selenium_chrome_headless)

    visit_transactions_page(session)
    transactions_by_date = find_transactions_for_dates(session, dates)
    transactions_by_date
  end

  private

  def visit_transactions_page(session)
    session.visit "https://mint.com"

    # Login
    session.all('a', text: 'Log In')[0].click
    session.fill_in 'ius-userid', with: ENV['MINT_EMAIL']
    session.fill_in 'ius-password', with: ENV['MINT_PASSWORD']
    session.find('#ius-sign-in-submit-btn-text').click

    # Input login codes if necessary
    if session.has_text?("Let's make sure it's you")
      session.find('#ius-mfa-options-submit-btn').click
      sleep 30 # Wait for code to come in

      find_login_codes.each do |code|
        sleep 3
        if session.all('#ius-mfa-confirm-code').count != 0
          session.fill_in 'ius-mfa-confirm-code', with: code
          session.find('#ius-mfa-otp-submit-btn').click
        else
          break
        end
      end
    end

    # Visit transactions page
    session.all('a', text: 'TRANSACTIONS')[0].click

    # Mint only loads transactions when you visit their site. This can take
    # awhile, so sleep for two minutes.
    sleep 120
  end

  def find_transactions_for_dates(session, dates)
    dates.each_with_object({}) do |date, memo|
      date_with_mint_format = date.strftime('%b %e').upcase
      transactions = []
      session.all("#transaction-list-body .firstdate").each do |block|
        transaction_date = block.find('.date').text
        if transaction_date == date_with_mint_format
          transactions << {
            description: block.find('.description').text,
            money_string: block.find('.money').text,
            money_number: block.find('.money').text.gsub('$', '').gsub('–', '-').gsub(',', '').to_f,
          }
        end
      end
      memo[date] = transactions
    end
  end

  def find_login_codes
    date = Date.today.strftime('%Y-%m-%d')
    login_codes = []

    Dir["#{ENV['HOME']}/Library/Messages/Archive/#{date}/*"].each do |file|
      encoded_body = File.read(file)
      utf8_body = encoded_body.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')

      # We use scan here because it's possible to receive multiple login codes on a single day.
      login_code_match = utf8_body.scan(/Your Mint Code is (\d+)/)
      login_codes << login_code_match.uniq if !login_code_match.empty?
    end

    # Reverse is useful because with multiple login codes, the latest one is at the end
    login_codes.flatten.reverse
  end
end
