import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    title: String
  }

  connect() {
    this.updateModalTitle()
  }

  updateModalTitle() {
    const modal = document.getElementById('terminal-modal')
    if (modal && this.hasTitleValue) {
      const titleElement = modal.querySelector('h3')
      if (titleElement) {
        titleElement.textContent = this.titleValue
      }
    }
  }
}
