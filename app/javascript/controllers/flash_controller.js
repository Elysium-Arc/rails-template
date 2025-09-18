import { Controller } from "@hotwired/stimulus"

// Controls flash message behavior: show, auto-hide with pause on hover, dismiss on click,
// optional redirect on click, and add/remove visible classes for smooth animations.
// Supports multiple flashes with staggered entrance, custom timeouts, and accessibility.
export default class extends Controller {
    static values = {
        timeout: { type: Number, default: 6000 },
        animationDuration: { type: Number, default: 300 }
    }

    connect() {
        // container holds individual flash items
        this._timers = new Map()
        this._animationDuration = this.animationDurationValue
        this._observer = null
        
        this.showAll()
        this._setupMutationObserver()
    }

    disconnect() {
        // Clean up all timers on disconnect
        this._timers.forEach((id) => clearTimeout(id))
        this._timers.clear()
        
        // Clean up mutation observer
        if (this._observer) {
            this._observer.disconnect()
            this._observer = null
        }
    }

    showAll() {
        const items = Array.from(this.element.querySelectorAll('.flash-item:not(.flash-initialized)'))
        items.forEach((item, i) => this._showItem(item, i))
    }
    
    _setupMutationObserver() {
        // Watch for new flash items added dynamically via Turbo Stream
        this._observer = new MutationObserver((mutations) => {
            mutations.forEach((mutation) => {
                mutation.addedNodes.forEach((node) => {
                    if (node.nodeType === 1 && node.classList.contains('flash-item')) {
                        if (!node.classList.contains('flash-initialized')) {
                            this._showItem(node, 0)
                        }
                    }
                })
            })
        })
        
        this._observer.observe(this.element, {
            childList: true,
            subtree: false
        })
    }

    _showItem(item, index) {
        // Mark as initialized to prevent duplicate handling
        item.classList.add('flash-initialized')
        
        // Stagger entrance animations for multiple flashes
        const delay = index * 100 // 100ms stagger
        requestAnimationFrame(() => {
            setTimeout(() => {
                this._animateIn(item)
                // Start auto hide timer after animation completes
                setTimeout(() => this._startAutoHide(item), this._animationDuration)
                this._attachListeners(item)
            }, delay)
        })
    }

    _animateIn(item) {
        // Add show class to trigger entrance animation
        item.classList.add('flash-show')
        item.classList.remove('flash-hide')

        // Announce to screen readers
        this._announceToScreenReader(item)
    }

    _animateOut(item) {
        // Add hide class to trigger exit animation
        item.classList.add('flash-hide')
        item.classList.remove('flash-show')
    }

    _startAutoHide(item) {
        const timeout = Number(item.dataset.flashTimeout) || this.timeoutValue
        if (timeout <= 0) return

        const id = setTimeout(() => this.dismiss(item), timeout)
        this._timers.set(item, id)
    }

    _clearTimer(item) {
        const id = this._timers.get(item)
        if (id) {
            clearTimeout(id)
            this._timers.delete(item)
        }
    }

    _attachListeners(item) {
        // Pause on hover/focus
        const pause = () => this._clearTimer(item)
        const resume = () => this._startAutoHide(item)
        item.addEventListener('mouseenter', pause)
        item.addEventListener('focusin', pause)
        item.addEventListener('mouseleave', resume)
        item.addEventListener('focusout', resume)

        // Click-to-dismiss or redirect, but if the click target is a link/button inside,
        // let that element handle it. The explicit close button should dismiss without redirect.
        item.addEventListener('click', (e) => {
            const target = e.target
            console.debug('Flash item clicked:', { target, item })

            // If clicked a link or a non-close button inside, let default happen
            if (target.closest('a') || (target.closest('button') && !target.classList.contains('flash-close'))) return

            const redirect = item.dataset.redirectUrl
            if (redirect) {
                console.debug('Flash redirect to:', redirect)
                window.location.href = redirect
                return
            }

            // Otherwise dismiss on click (but close button uses its own listener below)
            if (!target.closest('.flash-close')) this.dismiss(item)
        })

        // Explicit close button listener to ensure it always dismisses
        const close = item.querySelector('.flash-close')
        if (close) {
            close.addEventListener('click', (e) => {
                e.stopPropagation()
                console.debug('Flash close button clicked', { item })
                this.dismiss(item)
            })
        }

        // Keyboard: escape to dismiss
        item.addEventListener('keydown', (e) => {
            if (e.key === 'Escape') this.dismiss(item)
        })
    }

    dismiss(item) {
        console.debug("Dismissing flash item", item)
        this._clearTimer(item)

        // Animate out
        this._animateOut(item)

        // Remove after animation completes
        setTimeout(() => {
            try {
                if (item && item.parentNode) item.parentNode.removeChild(item)
            } catch (e) {
                console.error('Failed to remove flash item', e)
            }
        }, this._animationDuration)
    }

    // API: dismiss all visible flashes
    dismissAll() {
        const items = Array.from(this.element.querySelectorAll('.flash-item:not(.flash-hide)'))
        items.forEach(item => this.dismiss(item))
    }

    // API: show a new flash programmatically
    show(message, type = 'info', options = {}) {
        const {
            timeout = this.timeoutValue,
            customClass = '',
            redirectUrl = null
        } = options

        // Create flash item element
        const item = document.createElement('div')
        item.className = `flash-item ${customClass}`
        item.setAttribute('role', 'status')
        item.setAttribute('tabindex', '0')
        item.setAttribute('data-flash-timeout', timeout)
        item.setAttribute('data-flash-type-value', type)
        if (redirectUrl) item.setAttribute('data-redirect-url', redirectUrl)

        // Create alert content
        const alert = document.createElement('div')
        alert.className = `alert alert-${type} shadow-xs border border-base-300 flash-alert`

        const content = document.createElement('div')
        content.className = 'flex-1'

        const icon = this._createIcon(type)
        if (icon) content.appendChild(icon)

        const label = document.createElement('label')
        label.className = 'flash-message'
        label.textContent = message
        content.appendChild(label)

        const closeBtn = document.createElement('button')
        closeBtn.type = 'button'
        closeBtn.className = 'flash-close btn btn-ghost btn-sm hover:bg-base-200'
        closeBtn.setAttribute('aria-label', 'Dismiss')
        closeBtn.setAttribute('title', 'Dismiss')
        closeBtn.innerHTML = '<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path></svg>'

        const closeContainer = document.createElement('div')
        closeContainer.className = 'flex-none'
        closeContainer.appendChild(closeBtn)

        alert.appendChild(content)
        alert.appendChild(closeContainer)
        item.appendChild(alert)

        // Add to container
        this.element.appendChild(item)

        // Show with animation
        const index = this.element.querySelectorAll('.flash-item').length - 1
        this._showItem(item, index)
    }

    _createIcon(type) {
        const iconMap = {
            success: '✓',
            error: '✕',
            warning: '⚠',
            info: 'ℹ'
        }

        const iconChar = iconMap[type]
        if (iconChar) {
            const div = document.createElement('div')
            div.className = 'flash-icon'
            div.textContent = iconChar
            return div
        }
        return null
    }

    _announceToScreenReader(item) {
        // Create a temporary live region for screen reader announcement
        const announcement = document.createElement('div')
        announcement.setAttribute('aria-live', 'assertive')
        announcement.setAttribute('aria-atomic', 'true')
        announcement.className = 'sr-only'
        announcement.textContent = item.querySelector('.flash-message')?.textContent || 'Flash message'

        document.body.appendChild(announcement)

        // Remove after announcement
        setTimeout(() => {
            document.body.removeChild(announcement)
        }, 1000)
    }
}
