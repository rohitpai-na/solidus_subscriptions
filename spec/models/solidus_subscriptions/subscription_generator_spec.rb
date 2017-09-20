require 'rails_helper'

RSpec.describe SolidusSubscriptions::SubscriptionGenerator do
  describe '.activate' do
    subject { described_class.activate(subscription_line_item) }

    it { is_expected.to be_a SolidusSubscriptions::Subscription }

    it 'creates subscriptions with the correct attributes', :aggregate_failures do
      expect(subject).to have_attributes(
        subscription_preset: subscription_line_item.priceable,
        # end_date: subscription_line_item.end_date,
      )

      expect(subject.line_item).to match subscription_line_item
    end
  end

end
