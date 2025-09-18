import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "icon", "link"]

  connect() {
    document.addEventListener("sidebar:toggle", (e) => {
      this.toggle(e)
    })

    // listen for clicks on the document to collapse sidebar on small screens
    this.handleDocumentClickBound = this.handleDocumentClick.bind(this)
    document.addEventListener("click", this.handleDocumentClickBound)
  }

  toggle(event) {
    // const isCollapsed = this.menuTarget.classList.contains("sidebar-collapsed");
    if (event.detail.element.querySelector("[data-sidebar-target='collapse-icon']")) {
      const icon = event.detail.element.querySelector("[data-sidebar-target='collapse-icon']");
      // this.update_icon(icon, isCollapsed)
    }
    this.menuTarget.classList.toggle("sidebar-collapsed");
    this.menuTarget.querySelector("#sidebar-logo img").classList.toggle("hidden")
    this.linkTargets.forEach((link) => {
      link.classList.toggle("hidden")
    });
    this.saveState()
  }

  disconnect() {
    // cleanup the document click listener
    if (this.handleDocumentClickBound) {
      document.removeEventListener("click", this.handleDocumentClickBound)
      this.handleDocumentClickBound = null
    }
  }

  handleDocumentClick(event) {
    // Only act on small screens
    if (window.innerWidth > 767) return

    // If sidebar already collapsed, nothing to do
    if (this.menuTarget.classList.contains("sidebar-collapsed")) return

    // If click is inside the sidebar, ignore
    if (this.element.contains(event.target)) return

    // If click is on a toggle that broadcasts the sidebar event, ignore (so toggle still works)
    const clickedToggle = event.target.closest('[data-event-name="sidebar:toggle"], [data-action*="event#broadcast"]')
    if (clickedToggle) return

    // Collapse the sidebar and hide link text/logo as in toggle()
    this.menuTarget.classList.add("sidebar-collapsed")
    const logoImg = this.menuTarget.querySelector("#sidebar-logo img")
    if (logoImg) logoImg.classList.add("hidden")
    this.linkTargets.forEach((link) => {
      link.classList.add("hidden")
    });
    this.saveState()
  }

  update_icon(icon, isCollapsed) {
    // Ensure the icon has the base transition class
    icon.classList.add('collapse-icon');

    // Toggle rotation classes based on sidebar state
    if (isCollapsed) {
      icon.classList.add('collapse-icon-collapsed');
      icon.classList.remove('collapse-icon-expanded');
    } else {
      icon.classList.add('collapse-icon-expanded');
      icon.classList.remove('collapse-icon-collapsed');
    }
  }

  isCollapsed() {
    return this.menuTarget.classList.contains("sidebar-collapsed");
  }

  saveState() {
    localStorage.setItem("sidebar-collapsed", this.isCollapsed() ? "true" : "false");
    document.cookie = `sidebar-collapsed=${this.isCollapsed() ? "true" : "false"}; path=/; max-age=31536000; SameSite=Lax`
  }
}

