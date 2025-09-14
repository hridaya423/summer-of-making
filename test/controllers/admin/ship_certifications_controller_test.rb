require "test_helper"

module Admin
  class ShipCertificationsControllerTest < ActionDispatch::IntegrationTest
    def setup
      @admin_user = users(:admin_user)
      @reviewer_user = users(:reviewer_user)
      @regular_user = users(:regular_user)
      @project = projects(:project_one)
    end

    test "leaderboard includes ship certification decisions in weekly count" do
      # Create ship certification with reviewer
      ship_cert = ShipCertification.create!(
        project: @project,
        reviewer: @reviewer_user,
        judgement: :approved,
        notes: "Test certification",
        updated_at: 1.day.ago
      )

      # Sign in as admin to access the dashboard
      sign_in @admin_user

      get admin_ship_certifications_path

      assert_response :success
      assert_not_nil assigns(:leaderboard_week)

      # Check that the reviewer appears in the weekly leaderboard
      leaderboard_users = assigns(:leaderboard_week).map { |entry| entry[1] } # emails
      assert_includes leaderboard_users, @reviewer_user.email
    end

    test "leaderboard includes fraud report decisions in weekly count" do
      # Create fraud report resolved by reviewer
      fraud_report = FraudReport.create!(
        suspect_type: "Project",
        suspect_id: @project.id,
        reporter: @regular_user,
        reason: "Low quality project",
        category: "low_quality",
        resolved: true,
        resolved_by: @reviewer_user,
        resolved_at: 1.day.ago,
        resolved_outcome: "low_quality",
        resolved_message: "Confirmed low quality"
      )

      # Sign in as admin
      sign_in @admin_user

      get admin_ship_certifications_path

      assert_response :success
      assert_not_nil assigns(:leaderboard_week)

      # Check that the reviewer appears in the weekly leaderboard for fraud report decision
      leaderboard_users = assigns(:leaderboard_week).map { |entry| entry[1] } # emails
      assert_includes leaderboard_users, @reviewer_user.email
    end

    test "leaderboard combines ship certification and fraud report counts" do
      # Create both types of decisions for the same reviewer
      ship_cert = ShipCertification.create!(
        project: @project,
        reviewer: @reviewer_user,
        judgement: :approved,
        notes: "Test certification",
        updated_at: 1.day.ago
      )

      fraud_report = FraudReport.create!(
        suspect_type: "Project",
        suspect_id: @project.id,
        reporter: @regular_user,
        reason: "Low quality project",
        category: "low_quality",
        resolved: true,
        resolved_by: @reviewer_user,
        resolved_at: 1.day.ago,
        resolved_outcome: "low_quality",
        resolved_message: "Confirmed low quality"
      )

      # Sign in as admin
      sign_in @admin_user

      get admin_ship_certifications_path

      assert_response :success
      assert_not_nil assigns(:leaderboard_week)

      # Find the reviewer in the leaderboard and check their count
      reviewer_entry = assigns(:leaderboard_week).find { |entry| entry[1] == @reviewer_user.email }
      assert_not_nil reviewer_entry, "Reviewer should appear in weekly leaderboard"
      assert_equal 2, reviewer_entry[2], "Reviewer should have combined count of 2 (1 ship cert + 1 fraud report)"
    end

    test "leaderboard_all includes all-time counts for both decision types" do
      # Create decisions from different time periods
      old_ship_cert = ShipCertification.create!(
        project: @project,
        reviewer: @reviewer_user,
        judgement: :rejected,
        notes: "Old certification",
        updated_at: 1.month.ago
      )

      old_fraud_report = FraudReport.create!(
        suspect_type: "Project",
        suspect_id: @project.id,
        reporter: @regular_user,
        reason: "Old low quality project",
        category: "low_quality",
        resolved: true,
        resolved_by: @reviewer_user,
        resolved_at: 1.month.ago,
        resolved_outcome: "low_quality",
        resolved_message: "Old decision"
      )

      # Sign in as admin
      sign_in @admin_user

      get admin_ship_certifications_path

      assert_response :success
      assert_not_nil assigns(:leaderboard_all)

      # Find the reviewer in the all-time leaderboard
      reviewer_entry = assigns(:leaderboard_all).find { |entry| entry[1] == @reviewer_user.email }
      assert_not_nil reviewer_entry, "Reviewer should appear in all-time leaderboard"
      assert_equal 2, reviewer_entry[2], "Reviewer should have combined all-time count"
    end

    test "logs leaderboard includes fraud report resolutions" do
      # Create fraud report decision
      fraud_report = FraudReport.create!(
        suspect_type: "Project",
        suspect_id: @project.id,
        reporter: @regular_user,
        reason: "Low quality project",
        category: "low_quality",
        resolved: true,
        resolved_by: @reviewer_user,
        resolved_at: 1.day.ago,
        resolved_outcome: "low_quality",
        resolved_message: "Confirmed low quality"
      )

      # Sign in as admin
      sign_in @admin_user

      get logs_admin_ship_certifications_path

      assert_response :success
      assert_not_nil assigns(:leaderboard)

      # Check that fraud report decisions are included in logs leaderboard
      leaderboard_users = assigns(:leaderboard).map { |entry| entry[1] } # emails
      assert_includes leaderboard_users, @reviewer_user.email
    end

    private

    def sign_in(user)
      # Mock authentication - adjust based on your authentication system
      session[:user_id] = user.id
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
      allow_any_instance_of(ApplicationController).to receive(:admin_or_ship_certifier?).and_return(true)
    end
  end
end
