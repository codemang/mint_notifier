require 'twilio-ruby'

module SummaryNotifier
  extend self

  def send_summary_message(transactions_by_date)
    client = Twilio::REST::Client.new(ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN'])
    transactions_by_date.each do |date, transactions|
      client.api.account.messages.create(
        from: ENV['SENDER_PHONE_NUMBER'],
        to: ENV['RECIPIENT_PHONE_NUMBER'],
        body: build_summary_message(transactions, date),
      )
    end
  end

  private

  def build_summary_message(transactions, date)
    summary_message =  <<~HEREDOC
      Summary For: #{date.strftime('%b %e, %Y')}

      ## Overall Summary
    HEREDOC
      .strip

    debits = transactions.select{|t| t[:money_number] < 0}.map{|t| t[:money_number]}.sum
    if debits < 0
      summary_message << "\nTotal Debits: -$" + number_with_commas(debits.round(2).abs)
    end
    credits = transactions.select{|t| t[:money_number] > 0}.map{|t| t[:money_number]}.sum
    if credits > 0
      summary_message << "\nTotal Credits: $" + number_with_commas(credits.round(2))
    end

    summary_message << "\n\n## Spending Summary"
    if debits < 0
      transactions.select{|t| t[:money_number] < 0}.each do |transaction|
        summary_message << "\n* #{transaction[:description]}: #{transaction[:money_string]}"
      end
    else
      summary_message << "\nNo Transactions"
    end

    summary_message << "\n\n## Income Summary"
    if credits > 0
      transactions.select{|t| t[:money_number] > 0}.each do |transaction|
        summary_message << "\n* #{transaction[:description]}: #{transaction[:money_string]}"
      end
    else
      summary_message << "\nNo Transactions"
    end

    summary_message.strip
  end

  def number_with_commas(number)
    number.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
  end
end
