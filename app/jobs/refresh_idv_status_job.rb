# frozen_string_literal: true

class RefreshIdvStatusJob < ApplicationJob
  include UniqueJob
  queue_as :literally_whenever

  def perform
    # latesty users
    users_to_check = User.where.not(identity_vault_access_token: nil)
                        .where("created_at > ? OR ysws_verified = false", 1.week.ago)
                        .limit(50)

    Rails.logger.info "Refreshing IDV status for #{users_to_check.count} users"

    users_to_check.find_each do |user|
      refresh_user_idv_status(user)
    rescue StandardError => e
      Rails.logger.error "Failed to refresh IDV status for user #{user.id}: #{e.message}"
      Honeybadger.notify(e, context: { user_id: user.id, slack_id: user.slack_id })
    end
  end

  private

  def refresh_user_idv_status(user)
    return unless user.identity_vault_access_token.present?

    begin
      user.refresh_identity_vault_data!
      Rails.logger.debug "Successfully refreshed IDV status for user #{user.id}"
    rescue => e
      if e.message.include?("401") || e.message.include?("unauthorized")
        Rails.logger.warn "Access token expired for user #{user.id}, clearing IDV data"
        Rails.cache.delete("user_idv_status_#{user.id}")
      else
        raise e
      end
    end
  end
end
