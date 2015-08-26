class RecipientList
  EMAIL_REGEX = /([^\s]+)((?:[-a-z0-9]\.)[a-z]{2,})/i

  def initialize(recipients)
    @recipients = recipients
  end

  def to
    addressed :to
  end

  def cc
    addressed :cc
  end

  def bcc
    addressed :bcc
  end

  def all
    [ to, cc, bcc ].compact.flatten.uniq
  end

  def valid?
    recipients.present?
  end

  private

  def recipients
    addresses.map do |address|
      next unless address =~ EMAIL_REGEX

      if address[/(to|cc|bcc)\s*:\s*#{EMAIL_REGEX}/i]
        address
      else
        "to:#{address}"
      end
    end
  end

  def addressed(regex)
    recipients.
      grep(/\b#{regex.to_s}\s*:\s*#{EMAIL_REGEX}/i).
      uniq.map {|_| _.gsub /(\b#{regex.to_s}\s*:)/i, '' }
  end

  def addresses
    @recipients.split(/(\s+|,)/).reject {|_| _.blank? || _[/,/] }
  end
end
