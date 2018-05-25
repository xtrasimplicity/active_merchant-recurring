module ActiveMerchant
  module Recurring
    class InvalidPaymentIntervalError < StandardError; end
    class InvalidStartDateError < StandardError; end
    class InvalidNumberOfPaymentsError < StandardError; end
  end
end