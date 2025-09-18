import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]

  connect() {
    this.isOpen = false
    document.addEventListener("dropdown:opened", this.closeIfOther)
  }

  toggle(event) {
    event.preventDefault()
    event.stopPropagation()
    this.isOpen ? this.close() : this.open()
  }

  open() {
    this.isOpen = true
    this.menuTarget.classList.remove("hidden")
    this.element.classList.add("dropdown-open")
    // Close other dropdowns
    document.dispatchEvent(new CustomEvent("dropdown:opened", { detail: { source: this.element } }))

    document.addEventListener("click", this.closeOnOutsideClick)
  }

  close() {
    if (!this.isOpen) return
    this.isOpen = false
    this.menuTarget.classList.add("hidden")
    this.element.classList.remove("dropdown-open")

    document.removeEventListener("click", this.closeOnOutsideClick)
    window.removeEventListener("scroll", this.handleScroll, true)
  }

  closeIfOther = (event) => {
    const source = event.detail?.source
    // Skip if same dropdown or nested inside this dropdown
    if (source === this.element || this.element.contains(source)) return
    this.close()
  }

  closeOnOutsideClick = (event) => {
    if (!this.element.contains(event.target)) this.close()
  }

  disconnect() {
    document.removeEventListener("click", this.closeOnOutsideClick)
    window.removeEventListener("scroll", this.handleScroll, true)
    document.removeEventListener("dropdown:opened", this.closeIfOther)
  }
}
