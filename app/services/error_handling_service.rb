class ErrorHandlingService
  def self.parse_error_message(message)
    case message
    when /not found/i
      ActiveRecord::RecordNotFound.new(message)
    when /invalid/i
      ArgumentError.new(message)
    else
      StandardError.new(message)
    end
  end
end
