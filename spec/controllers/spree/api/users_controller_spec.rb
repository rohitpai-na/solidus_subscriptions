require 'rails_helper'
require 'spree/api/testing_support/helpers'

RSpec.describe Spree::Api::UsersController, type: :controller do
  include Spree::Api::TestingSupport::Helpers
  routes { Spree::Core::Engine.routes }

  let!(:user) do
    create(:user) { |user| user.generate_spree_api_key }.tap(&:save)
  end
  let!(:subscription) { create :subscription, :with_line_item, user: user }

  describe 'patch /update' do
    subject { patch :update, params: params }

    let(:params) do
      {
        id: user.id,
        token: user.spree_api_key,
        format: 'json',
        user: {
          subscriptions_attributes: [{
            id: subscription.id,
            line_items_attributes: [line_item_attributes]
          }]
        }
      }
    end

    let(:line_item_attributes) do
      {
        id: subscription.line_item_ids.first,
        quantity: 6,
        interval_length: 1,
        interval_units: 'months'
      }
    end

    it 'updates the subscription line items' do
      subject
      line_item = subscription.line_items.reload.first

      expect(line_item).to have_attributes(line_item_attributes)
    end
  end
end
