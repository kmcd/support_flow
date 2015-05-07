Griddler.configure do |config|
  config.email_service = :mandrill
  config.processor_class = EmailProcessor
end