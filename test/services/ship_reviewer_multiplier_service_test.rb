require "test_helper"

class ShipReviewerMultiplierServiceTest < ActiveSupport::TestCase
  test "calculate_multiplier_for_position returns 1.5 for top 3 positions" do
    assert_equal 1.5, ShipReviewerMultiplierService.calculate_multiplier_for_position(1)
    assert_equal 1.5, ShipReviewerMultiplierService.calculate_multiplier_for_position(2)
    assert_equal 1.5, ShipReviewerMultiplierService.calculate_multiplier_for_position(3)
  end

  test "calculate_multiplier_for_position returns 1.0 for positions 4 and above" do
    assert_equal 1.0, ShipReviewerMultiplierService.calculate_multiplier_for_position(4)
    assert_equal 1.0, ShipReviewerMultiplierService.calculate_multiplier_for_position(10)
    assert_equal 1.0, ShipReviewerMultiplierService.calculate_multiplier_for_position(nil)
  end

  test "calculate_effective_rate returns correct rates" do
    assert_equal 0.75, ShipReviewerMultiplierService.calculate_effective_rate(1)  # 0.5 * 1.5
    assert_equal 0.75, ShipReviewerMultiplierService.calculate_effective_rate(3)  # 0.5 * 1.5
    assert_equal 0.5, ShipReviewerMultiplierService.calculate_effective_rate(4)   # 0.5 * 1.0
    assert_equal 0.5, ShipReviewerMultiplierService.calculate_effective_rate(10)  # 0.5 * 1.0
  end

  test "calculate_total_earned returns correct totals" do
    assert_equal 7.5, ShipReviewerMultiplierService.calculate_total_earned(10, 1)  # 10 * 0.75
    assert_equal 5.0, ShipReviewerMultiplierService.calculate_total_earned(10, 5)  # 10 * 0.5
    assert_equal 0, ShipReviewerMultiplierService.calculate_total_earned(0, 1)     # 0 * 0.75
  end
end