class ShipFeedbackService
  def initialize(ship_event)
    @ship_event = ship_event
  end

  def generate_feedback
    votes = collect_payout_votes
    return nil if votes.empty?

    explanations = votes.map(&:explanation).join("\n---\n")
    
    prompt = build_feedback_prompt(explanations)
    
    begin
      feedback = GroqService.call(prompt)
      @ship_event.update!(feedback: feedback)
      feedback
    rescue GroqService::InferenceError => e
      Rails.logger.error "Failed to generate ship feedback for ship_event #{@ship_event.id}: #{e.message}"
      nil
    end
  end

  private

  def collect_payout_votes
    project = @ship_event.project
    
    Vote.joins(:vote_changes)
        .where(vote_changes: { project: project })
        .where("votes.created_at > ?", @ship_event.created_at)
        .where(status: 'active')
        .includes(:user)
        .limit(18) 
  end

  def build_feedback_prompt(explanations)
    project_name = @ship_event.project.title
    
    <<~PROMPT
      Analyze the following voter feedback for a shipped project called "#{project_name}". Provide structured feedback with:

      1. **Summary**: Brief overview of the project reception (2-3 sentences)
      2. **Strengths**: Key positive aspects mentioned by voters (3-4 bullet points)
      3. **Areas for Improvement**: Constructive feedback and suggestions (2-3 bullet points)  
      4. **Common Themes**: Recurring topics across voter explanations

      Keep the tone constructive and encouraging. Focus on specific technical and creative aspects mentioned by voters.
      Format your response in clean markdown with clear sections.

      Voter explanations:
      #{explanations}
    PROMPT
  end
end