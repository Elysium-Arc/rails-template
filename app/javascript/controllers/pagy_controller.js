import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    connect() {
        try {
            const frame = this.element.closest('turbo-frame')
            const frameId = frame?.id
            if (frameId) {
                // set data-turbo-frame on any internal pagination links to ensure they target the table frame
                this.element.querySelectorAll('a').forEach(a => {
                    // Only set when not already explicitly targeting another frame
                    if (!a.hasAttribute('data-turbo-frame')) {
                        a.setAttribute('data-turbo-frame', frameId)
                    }
                    // Add click handler to update browser URL and sync with filter form
                    a.addEventListener('click', (e) => {
                        const href = a.getAttribute('href')
                        if (href) {
                            try {
                                // Update browser URL immediately
                                window.history.pushState({}, '', href)
                                
                                // Extract page number from URL and update hidden field in filter form
                                const url = new URL(href, window.location.origin)
                                const pageNumber = url.searchParams.get('page')
                                if (pageNumber) {
                                    // Find the filter form and update its page field
                                    const filterForm = document.querySelector('form[data-controller*="filter"]')
                                    if (filterForm) {
                                        const pageField = filterForm.querySelector('input[name="page"]')
                                        if (pageField) {
                                            pageField.value = pageNumber
                                        }
                                    }
                                }
                            } catch (err) {
                                // ignore
                            }
                        }
                    })
                })
            }
        } catch (e) {
            // ignore
        }
    }

    // Triggered via data-action="change->pagy#limitChanged"
    limitChanged(event) {
        const el = event.currentTarget

        // Primary: associated form element
        let form = el.form || null

        // Fallback 1: form attribute referencing an id
        if (!form) {
            const attr = el.getAttribute && el.getAttribute('form')
            if (attr) form = document.getElementById(attr)
        }

        // Fallback 2: closest ancestor form (select wrapped in a form)
        if (!form) form = el.closest && el.closest('form')

        // Fallback 3: a filter form inside the same turbo-frame as this component
        if (!form) {
            const frame = this.element.closest && this.element.closest('turbo-frame')
            if (frame) form = frame.querySelector('form[data-controller="filter"], form')
        }

        // Fallback 4: any global filter form on the page
        if (!form) form = document.querySelector('form[data-controller="filter"], form')

        if (!form) return

        try {
            // Merge current URL params with the form's data so limit + sort + filters are preserved
            const params = new URLSearchParams(window.location.search)
            const fd = new FormData(form)

            // Make sure the select's own chosen value always overrides any stale value
            const selectName = el.name || 'limit'
            params.set(selectName, el.value)

            for (const [k, v] of fd.entries()) {
                // Do not let form entries overwrite the select's freshly-chosen value
                if (k === selectName) continue
                if (v === null || v === undefined || v === '') params.delete(k)
                else params.set(k, v)
            }

            const newUrl = `${window.location.pathname}${params.toString() ? '?' + params.toString() : ''}`
            try { window.history.replaceState({}, '', newUrl) } catch (e) { }

            if (typeof Turbo !== 'undefined' && Turbo.visit) {
                Turbo.visit(newUrl)
                return
            }

            console.warn("PagyController#limitChanged: Turbo is not available");

            // Fallback to full navigation
            window.location.href = newUrl
        } catch (e) {
            console.error("PagyController#limitChanged error:", e)
            // final fallback: attempt form submit
            if (typeof form.requestSubmit === 'function') form.requestSubmit()
            else if (typeof form.submit === 'function') form.submit()
        }
    }
}

