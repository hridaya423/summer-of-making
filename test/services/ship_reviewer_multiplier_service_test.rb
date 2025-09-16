require "test_helper"

class ShipReviewerMultiplierServiceTest < ActiveSupport::TestCase
  def setup
    puts "\n" + "="*60
    puts "SHIP REVIEWER MULTIPLIER SERVICE TESTS"
    puts "Testing position-based payout multipliers"
    puts "="*60
  end

  test "base shells per review constant" do
    puts "\nBASE RATE TEST:"
    puts "   Expected: 0.5 shells per review"
    puts "   Actual:   #{ShipReviewerMultiplierService::BASE_SHELLS_PER_REVIEW} shells per review"

    assert_equal 0.5, ShipReviewerMultiplierService::BASE_SHELLS_PER_REVIEW
    puts "   PASS: Base rate is correct"
  end

  test "multiplier for top 3 positions" do
    puts "\nMULTIPLIER LOGIC TEST:"
    puts "   Top 3 positions should get 1.5x multiplier"

    (1..3).each do |position|
      multiplier = ShipReviewerMultiplierService.calculate_multiplier_for_position(position)
      puts "   Position #{position}: #{multiplier}x multiplier"
      assert_equal 1.5, multiplier
    end
    puts "   PASS: Top 3 positions get bonus multiplier"
  end

  test "multiplier for positions 4 and above" do
    puts "\nSTANDARD MULTIPLIER TEST:"

    [ 4, 5, 10, 50 ].each do |position|
      multiplier = ShipReviewerMultiplierService.calculate_multiplier_for_position(position)
      puts "   Position #{position}: #{multiplier}x multiplier"
      assert_equal 1.0, multiplier
    end

    multiplier = ShipReviewerMultiplierService.calculate_multiplier_for_position(nil)
    puts "   No position (nil): #{multiplier}x multiplier"
    assert_equal 1.0, multiplier
    puts "   PASS: Standard positions get base multiplier"
  end

  test "effective rate calculation" do
    puts "\nEFFECTIVE RATE CALCULATION:"
    puts "   Formula: BASE_RATE (0.5) × MULTIPLIER = EFFECTIVE_RATE"

    test_cases = [
      { position: 1, expected_rate: 0.75 },
      { position: 3, expected_rate: 0.75 },
      { position: 4, expected_rate: 0.5 },
      { position: 10, expected_rate: 0.5 }
    ]

    test_cases.each do |test_case|
      effective_rate = ShipReviewerMultiplierService.calculate_effective_rate(test_case[:position])
      multiplier = ShipReviewerMultiplierService.calculate_multiplier_for_position(test_case[:position])
      puts "   Position #{test_case[:position]}: 0.5 × #{multiplier} = #{effective_rate} shells/review"
      assert_equal test_case[:expected_rate], effective_rate
    end
    puts "   PASS: Effective rates calculated correctly"
  end

  test "total earned for different scenarios" do
    puts "\nTOTAL EARNINGS CALCULATION:"
    puts "   Demonstrating payout differences by position"

    [ 5, 10, 20 ].each do |review_count|
      puts "\n   For #{review_count} reviews:"
      [ 1, 3, 4, 10 ].each do |position|
        total = ShipReviewerMultiplierService.calculate_total_earned(review_count, position)
        rate = ShipReviewerMultiplierService.calculate_effective_rate(position)
        puts "     Position #{position.to_s.rjust(2)}: #{review_count} × #{rate} = #{total} shells"
        assert_equal review_count * rate, total
      end
    end

    puts "\n   Key insight: Top 3 earn 50% more than standard positions"
    puts "   Position 1-3: 10 reviews = 7.5 shells"
    puts "   Position 4+:  10 reviews = 5.0 shells"
    puts "   PASS: Earnings calculated correctly"
  end

  test "edge cases" do
    puts "\nEDGE CASE TESTING:"

    # Zero reviews
    total_zero = ShipReviewerMultiplierService.calculate_total_earned(0, 1)
    puts "   0 reviews at position 1: #{total_zero} shells"
    assert_equal 0, total_zero

    # Nil position
    total_nil = ShipReviewerMultiplierService.calculate_total_earned(10, nil)
    puts "   10 reviews at nil position: #{total_nil} shells"
    assert_equal 5.0, total_nil

    puts "   PASS: Edge cases handled properly"
  end

  test "integration with payout request" do
    puts "\nINTEGRATION TEST:"

    # Test fallback to base rate when no reviewer specified
    amount = ShipReviewerPayoutRequest.calculate_amount_for_decisions(10)
    puts "   10 decisions, no reviewer: #{amount} shells (base rate)"
    assert_equal 5.0, amount

    puts "   PASS: Integration with payout system works"
    puts "\n" + "="*60
    puts "ALL TESTS PASSED - Multiplier system working correctly"
    puts "="*60
  end
end
