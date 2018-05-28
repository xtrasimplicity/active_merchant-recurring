module ActiveMerchant::Recurring
  module Gateways
    # SecurePay Australia
    # Scheduled Payments API Integration documentation is available from: 
    # https://www.securepay.com.au/wp-content/uploads/2017/06/API_Card_Storage_and_Scheduled_Payments.pdf
    module SecurePayAu

      # Create a recurring payment
      # @param payment_interval [Symbol] The payment interval/frequency
      # @param start_date [String] The date, in Ymd format, in which the first payment should be charged.
      # @param number_of_payments [Fixnum] The number of payments to make before the subscription ends.
      # @param amount [Numeric] The amount to charge.
      # @param credit_card [ActiveMerchant::Billing::CreditCard]
      def recurring(payment_interval, start_date, number_of_payments, amount, credit_card)
        raise InvalidPaymentIntervalError unless supported_payment_intervals.has_key?(payment_interval)
        raise InvalidStartDateError unless start_date_valid?(start_date)
        raise InvalidNumberOfPaymentsError unless (number_of_payments.to_s =~ /\A[0-9]+\z/ && number_of_payments.to_i >= 1) 
      end

      private

      # The payment intervals supported by SecurePay AU
      # https://www.securepay.com.au/wp-content/uploads/2017/06/API_Card_Storage_and_Scheduled_Payments.pdf
      def supported_payment_intervals
        HashWithIndifferentAccess.new(
          weekly: 1,
          fortnightly: 2,
          monthly: 3,
          quarterly: 4,
          halfyearly: 5,
          annually: 6
        )
      end

      def start_date_valid?(date)
        return false if date.nil?
        return false if date.to_s.length != 8
        
        year, month, day = date[0..3].to_i, date[4..5].to_i, date[6..date.length].to_i

        return false if year < 1900 || year > 9999
        return false if month < 1 || month > 12
        return false if day < 1 || day > 31

        true
      end
    end


    ActiveMerchant::Billing::SecurePayAuGateway.send(:include, SecurePayAu)
  end
end