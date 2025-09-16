# frozen_string_literal: true

class BrainrotController < ApplicationController
  before_action :authenticate_user!

  # Check if brainrot mode should be active for the current user
  def brainrot_mode_active?
    return false unless current_user

    current_user.ship_events
                .where('ship_events.created_at > ?', brainrot_activation_time)
                .any?
  end

  # Get brainrot configuration data
  def brainrot_config
    {
      sounds: brainrot_sounds,
      video_url: subway_surfers_video_url,
      activation_time: brainrot_activation_time
    }
  end

  # API endpoint to check brainrot status
  def status
    render json: {
      active: brainrot_mode_active?,
      config: brainrot_config
    }
  end

  # API endpoint to get random brainrot sound
  def random_sound
    sounds = brainrot_sounds
    random_sound = sounds.sample
    
    render json: {
      sound_url: random_sound,
      sounds_count: sounds.length
    }
  end

  private

  def brainrot_activation_time
    @brainrot_activation_time ||= Time.zone.parse('2025-09-15 11:00:00 EDT')
  end

  def brainrot_sounds
    [
      '/brainrot/67.mp3',
      '/brainrot/tung-tung-sahur.mp3',
      '/brainrot/brr-brr-patapim.mp3',
      '/brainrot/rizz.mp3',
      '/brainrot/deathfort.mp3',
      '/brainrot/jet2holiday.mp3',
      '/brainrot/huh-cat.mp3',
      '/brainrot/spongebob.mp3'
    ]
  end

  def subway_surfers_video_url
    'https://cdn.revid.ai/subway_surfers/LOW_RES/2.mp4'
  end
end