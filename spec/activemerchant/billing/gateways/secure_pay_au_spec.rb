require 'spec_helper'

RSpec.describe ActiveMerchant::Billing::SecurePayAuGateway do
  let(:gateway) { ActiveMerchant::Billing::SecurePayAuGateway.new(
    login: 'login',
    password: 'password'
  )}
  let(:credit_card) { ActiveMerchant::Billing::CreditCard.new(
    number: 4444333322221111,
    verification_value: 123,
    first_name: 'Fred',
    last_name: 'Smith',
    month: 10,
    year: Time.now.year + 1
  )}

  describe '#recurring' do
    let(:payment_interval) { :monthly }
    let(:start_date) { '20200101' }
    let(:number_of_payments) { 999 }
    let(:amount) {  30.0 }

    describe 'validation' do
      describe 'payment intervals' do
        context 'when not set' do
          it 'raises ActiveMerchant::Recurring::InvalidPaymentIntervalError' do
            expect { gateway.recurring(nil, start_date, number_of_payments, amount) }.to raise_error(ActiveMerchant::Recurring::InvalidPaymentIntervalError)
          end
        end

        context 'when not supported' do
          let(:supported_payment_intervals) { gateway.send(:supported_payment_intervals) }

          it 'raises ActiveMerchant::Recurring::InvalidPaymentIntervalError' do
            supported_payment_intervals.each do |interval, _|
              expect { gateway.recurring(interval, start_date, number_of_payments, amount) }.not_to raise_error
            end

            expect { gateway.recurring(:daily, start_date, number_of_payments, amount) }.to raise_error(ActiveMerchant::Recurring::InvalidPaymentIntervalError)
          end
        end
      end

      context 'start date' do
        context 'when not set' do
          it 'raises ActiveMerchant::Recurring::InvalidStartDateError' do
            expect { gateway.recurring(payment_interval, nil, number_of_payments, amount) }.to raise_error(ActiveMerchant::Recurring::InvalidStartDateError)
          end
        end

        context 'when not in Ymd format' do
          it 'raises ActiveMerchant::Recurring::InvalidStartDateError' do
            ['01012020', '1234567890', '123', '12Mar16'].each do |invalid_date|
              expect { gateway.recurring(payment_interval, invalid_date, number_of_payments, amount) }.to raise_error(ActiveMerchant::Recurring::InvalidStartDateError), "#{invalid_date} was accepted as a valid start date, but it isn't in Ymd format."
            end
          end
        end

        context 'when in Ymd format' do
          it 'does not raise an error' do
            expect { gateway.recurring(payment_interval, '20200101', number_of_payments, amount) }.not_to raise_error
          end
        end
      end

      describe 'number of payments' do
        context 'when not set' do
          it 'raises ActiveMerchant::Recurring::InvalidNumberOfPaymentsError' do
          expect { gateway.recurring(payment_interval, start_date, nil, amount) }.to raise_error(ActiveMerchant::Recurring::InvalidNumberOfPaymentsError)
          end
        end

        context 'when 0' do
          it 'raises ActiveMerchant::Recurring::InvalidNumberOfPaymentsError' do
            expect { gateway.recurring(payment_interval, start_date, 0, amount) }.to raise_error(ActiveMerchant::Recurring::InvalidNumberOfPaymentsError)
          end
        end

        context 'when it includes a decimal point' do
          it 'raises ActiveMerchant::Recurring::InvalidNumberOfPaymentsError' do
            expect { gateway.recurring(payment_interval, start_date, 1.5, amount) }.to raise_error(ActiveMerchant::Recurring::InvalidNumberOfPaymentsError)
          end
        end

        context 'when greater than or equal to 1' do
          it 'does not raise an error' do
            expect { gateway.recurring(payment_interval, start_date, 1, amount) }.not_to raise_error
          end
        end
      end
    end
  end
end