import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    connect() {
        // Ensure the direction matches the current html lang at connect time
        this.syncDirection()

        // Observe changes to the lang attribute (Turbo will update head lang when navigating)
        this.observer = new MutationObserver(() => this.syncDirection())
        this.observer.observe(document.documentElement, { attributes: true, attributeFilter: ['lang'] })
    }

    disconnect() {
        this.observer && this.observer.disconnect()
    }

    syncDirection() {
        const lang = document.documentElement.getAttribute('lang')
        const dir = (lang && lang.toString() === 'ar') ? 'rtl' : 'ltr'
        document.documentElement.setAttribute('dir', dir)
    }
}
