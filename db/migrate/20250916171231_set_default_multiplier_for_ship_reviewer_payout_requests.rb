class SetDefaultMultiplierForShipReviewerPayoutRequests < ActiveRecord::Migration[8.0]
  def change
    change_column_default :ship_reviewer_payout_requests, :multiplier, 1.0

    # Backfill existing records with the default value
    safety_assured do
      execute "UPDATE ship_reviewer_payout_requests SET multiplier = 1.0 WHERE multiplier IS NULL"
    end
  end
end
