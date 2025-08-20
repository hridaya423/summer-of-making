import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["submitButton", "form", "explanation", "counter"]
  static values = {
    loadingText: { type: String, default: "Processing..." },
    isConfirming: { type: Boolean, default: false }
  }

  connect() {
    this.submitting = false
    this.originalButtonText = null
    // only when both exist
    if (this.hasExplanationTarget && this.hasSubmitButtonTarget) {
      this.requiredLength = this.explanationTarget.getAttribute('minlength') ? parseInt(this.explanationTarget.getAttribute('minlength'), 10) : 100
      this.updateCounter()
      this.toggleSubmitAccordingToLength()
      this.explanationTarget.addEventListener('input', () => {
        this.updateCounter()
        this.toggleSubmitAccordingToLength()
      })
      const voteRadios = this.element.querySelectorAll('input[name="vote[winning_project_id]"]')
      voteRadios.forEach(radio => radio.addEventListener('change', () => this.toggleSubmitAccordingToLength()))
    }
  }

  disconnect() {
    if (this.submitting) {
      this.resetButton()
    }
  }

  validateAndPreventDoubleSubmission(event) {
    const attachmentField = this.element.querySelector('input[name="devlog[attachment]"]')
    if (attachmentField && (!attachmentField.value || attachmentField.value.trim() === '')) {
      event.preventDefault()
      alert('Please attach an attachment before posting your devlog.')
      return
    }
    
    this.preventDoubleSubmission(event)
  }

  preventDoubleSubmission(event) {
    if (this.submitting) {
      event.preventDefault()
      return
    }
    
    this.submitting = true
    this.disableSubmitButton()

    const turboDisabled = this.element.dataset.turbo === 'false'
    
    if (!turboDisabled) {
      this.element.addEventListener("turbo:submit-end", () => {
        this.resetButton()
        this.element.reset() 
      }, { once: true })
    }
  }

  disableSubmitButton() {
    try {
      const button = this.submitButtonTarget
      
      button.innerHTML = `
        <div class="inline-flex items-center">
          <span>${this.loadingTextValue}</span>
        </div>
      `
      button.disabled = true
      button.classList.add('opacity-75', 'cursor-not-allowed')
    } catch (error) {
      console.error('Error disabling submit button:', error)
      this.resetButton()
    }
  }

  resetButton() {
    try {
      const button = this.submitButtonTarget
      if (this.originalButtonText) {
        button.innerHTML = this.originalButtonText
      }
      button.disabled = false
      button.classList.remove('opacity-75', 'cursor-not-allowed', 'bg-vintage-red')
      this.submitting = false
      this.isConfirming = false
    } catch (error) {
      console.error('Error resetting button:', error)
    }
  }

  toggleSubmitAccordingToLength() {
    const button = this.hasSubmitButtonTarget ? this.submitButtonTarget : null
    if (!button) return
    const currentLen = this.hasExplanationTarget ? this.explanationTarget.value.trim().length : 0
    const hasWinner = !!this.element.querySelector('input[name="vote[winning_project_id]"]:checked')
    const ok = currentLen >= (this.requiredLength || 0) && hasWinner
    button.disabled = !ok
    button.classList.toggle('opacity-75', !ok)
    button.classList.toggle('cursor-not-allowed', !ok)
    button.classList.toggle('pointer-events-none', !ok)
  }

  updateCounter() {
    if (!this.hasCounterTarget || !this.hasExplanationTarget) return
    const current = this.explanationTarget.value.trim().length
    const min = this.requiredLength || 0
    const remaining = Math.max(0, min - current)
    this.counterTarget.textContent = remaining > 0 ? `${remaining} more characters required` : `Looks awesome! Ty <3`
    this.counterTarget.className = `text-sm mt-1 ${remaining > 0 ? 'text-gray-600' : 'text-forest'}`
  }
} 