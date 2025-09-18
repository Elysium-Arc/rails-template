import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["icon"]

    connect() {
        this.load()
    }

    load() {
        const theme = localStorage.getItem('theme') || this.preferred()
        this.apply(theme)
    }

    preferred() {
        return window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light'
    }

    apply(theme) {
        if (theme === 'dark') {
            document.documentElement.dataset.theme = 'dark'
            this.iconTarget && (this.iconTarget.textContent = '🌙')
        } else {
            document.documentElement.dataset.theme = 'light'
            this.iconTarget && (this.iconTarget.textContent = '☀️')
        }
        localStorage.setItem('theme', theme)
        document.cookie = `theme=${theme}; path=/; max-age=31536000; SameSite=Lax`
    }

    toggle() {
        const isDark = document.documentElement.dataset.theme === 'dark'
        this.apply(isDark ? 'light' : 'dark')
    }
}
