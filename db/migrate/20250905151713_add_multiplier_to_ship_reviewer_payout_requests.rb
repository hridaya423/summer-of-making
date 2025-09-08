class AddMultiplierToShipReviewerPayoutRequests < ActiveRecord::Migration[8.0]
  def change
    add_column :ship_reviewer_payout_requests, :multiplier, :decimal, precision: 4, scale: 2, default: 1.0
  end
end
