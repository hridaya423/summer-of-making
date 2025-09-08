class ShipReviewerMultiplierService
  BASE_SHELLS_PER_REVIEW = 0.5

  class << self
    def calculate_multiplier_for_position(position)
      case position
      when 1..3
        1.5  # 1st to 3rd place get 1.5x multiplier
      else
        1.0  # Everyone else gets 1.0x multiplier
      end
    end

    def calculate_effective_rate(position)
      multiplier = calculate_multiplier_for_position(position)
      BASE_SHELLS_PER_REVIEW * multiplier
    end

    def calculate_total_earned(review_count, position)
      effective_rate = calculate_effective_rate(position)
      review_count * effective_rate
    end
  end
end