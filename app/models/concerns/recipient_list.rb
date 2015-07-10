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
    @recipients.present? && invalid.empty?
  end
  
  def invalid
    addresses.find_all {|_| _ !~ EMAIL_REGEX }
  end

  private

  def recipients
    addresses.map do |address|
      if address[/(to|cc|bcc):\s*#{EMAIL_REGEX}/i]
        address
      else
        "to:#{address}"
      end
    end
  end

  def addressed(regex)
    recipients.
      grep(/#{regex.to_s}:\s*#{EMAIL_REGEX}/i).
      uniq.map {|_| _.gsub /(#{regex.to_s}:)/, '' }
  end
  
  def addresses
    @recipients.split(/(\s+|,)/).reject {|_| _.blank? || _[/,/] }
  end
end
