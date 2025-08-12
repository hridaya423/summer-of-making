import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "toggle", "loading"]
  static values = { 
    shipEventId: Number,
    loaded: Boolean 
  }

  connect() {
    this.loadedValue = false
  }

  toggle() {
    if (this.contentTarget.classList.contains("hidden")) {
      this.expand()
    } else {
      this.collapse()
    }
  }

  async expand() {
    this.contentTarget.classList.remove("hidden")
    this.toggleTarget.textContent = "Hide AI Feedback"
    
    if (!this.loadedValue) {
      await this.loadFeedback()
    }
  }

  collapse() {
    this.contentTarget.classList.add("hidden")
    this.toggleTarget.textContent = "Show AI Feedback"
  }

  async loadFeedback() {
    this.loadingTarget.classList.remove("hidden")
    
    try {
      const response = await fetch(`/ship_events/${this.shipEventIdValue}/feedback`)
      const data = await response.json()
      
      if (response.ok) {
        this.contentTarget.innerHTML = this.markdownToHtml(data.feedback)
        this.loadedValue = true
      } else {
        this.contentTarget.innerHTML = `<p class="text-gray-500">No feedback available yet.</p>`
      }
    } catch (error) {
      console.error("Failed to load feedback:", error)
      this.contentTarget.innerHTML = `<p class="text-red-500">Failed to load feedback.</p>`
    } finally {
      this.loadingTarget.classList.add("hidden")
    }
  }

  markdownToHtml(markdown) {
    return markdown
      .replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>')
      .replace(/\* (.*?)(\n|$)/g, '<li>$1</li>')
      .replace(/\n\n/g, '</p><p class="mb-3">')
      .replace(/\n/g, '<br>')
      .replace(/^/, '<div class="prose max-w-none">')
      .replace(/$/, '</div>')
      .replace(/<li>/g, '<ul class="list-disc list-inside mb-3"><li>')
      .replace(/<\/li>/g, '</li></ul>')
  }
}