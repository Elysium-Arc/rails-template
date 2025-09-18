import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["title", "modalBox", "content"]
  static values = {
    backdropDismissable: { type: Boolean, default: true }
  }

  connect() {
    console.log('Modal controller connected')

    this.boundHandleFrameClick = this.handleFrameClick.bind(this)
    document.addEventListener('click', this.boundHandleFrameClick, true)
    
    this.boundBeforeStreamRender = this.handleBeforeStreamRender.bind(this)
    document.addEventListener('turbo:before-stream-render', this.boundBeforeStreamRender)
    
    this.boundHandleDialogClose = this.handleDialogClose.bind(this)
    this.element.addEventListener('close', this.boundHandleDialogClose)
    
    this.element._modalController = this
    
    // Save original state
    this.saveOriginalState()

    this.setEventListeners()
  }

  disconnect() {
    document.removeEventListener('click', this.boundHandleFrameClick, true)
    document.removeEventListener('turbo:before-stream-render', this.boundBeforeStreamRender)
    this.element.removeEventListener('close', this.boundHandleDialogClose)
    
    if (this.element.open) {
      this.element.close()
    }
    
    delete this.element._modalController
  }

  saveOriginalState() {
    const modalBox = this.element.querySelector('.modal-box')
    const frame = this.element.querySelector('turbo-frame')
    
    if (modalBox && frame) {
      this.originalState = {
        title: this.hasTitleTarget ? this.titleTarget.textContent : '',
        modalBoxClasses: modalBox.className,
        turboFrameId: frame.id,
        frameContent: frame.innerHTML
      }
    }
  }

  restoreOriginalState() {
    if (!this.originalState) return
    
    // Restore title
    if (this.hasTitleTarget) {
      this.titleTarget.textContent = this.originalState.title
    }
    
    // Restore modal box classes
    const modalBox = this.element.querySelector('.modal-box')
    if (modalBox) {
      modalBox.className = this.originalState.modalBoxClasses
    }
    
    // Restore turbo frame to loading state
    const frame = this.element.querySelector('turbo-frame')
    if (frame) {
      frame.innerHTML = this.originalState.frameContent
      frame.removeAttribute('src')
      frame.removeAttribute('complete')
    }
  }

  handleDialogClose() {
    // Dialog has fired close event, but animation may still be running
    // Wait for all animations/transitions to complete before restoring state
    // DaisyUI modals typically have 200ms fade animations
    setTimeout(() => {
      this.restoreOriginalState()
    }, 300)  // 300ms to ensure all animations complete
  }

  handleFrameClick(event) {
    const link = event.target.closest('a[data-turbo-frame="modal-content"]')
    if (link) {
      event.preventDefault()
      event.stopPropagation()
      
      const options = {
        title: link.dataset.modalTitleParam,
        size: link.dataset.modalSize,
        width: link.dataset.modalWidth,
        url: link.href
      }
      this.open(options)
    }
  }

  handleBeforeStreamRender(event) {
    const streamAction = event.target.getAttribute('action')
    if (streamAction === 'refresh') {
      this.close()
    }
  }

  open(options = {}) {
    if (!this.element.open) {
      // Apply dynamic configuration
      this.applyConfiguration(options)
      
      this.element.showModal()
    }
  }

  applyConfiguration(options) {
    const modalBox = this.element.querySelector('.modal-box')
    if (!modalBox) return

    // Update title
    if (options.title && this.hasTitleTarget) {
      this.titleTarget.textContent = options.title
    }

    // Update size - remove existing size classes and add new one
    if (options.size) {
      const sizeClasses = {
        sm: 'max-w-sm',
        md: 'max-w-2xl',
        lg: 'max-w-4xl',
        xl: 'max-w-6xl',
        full: 'max-w-7xl'
      }
      
      // Remove all size classes
      Object.values(sizeClasses).forEach(cls => {
        modalBox.classList.remove(cls)
      })
      
      // Add new size class
      const newSize = sizeClasses[options.size] || sizeClasses.md
      modalBox.classList.add(newSize)
    }

    // Update custom width
    if (options.width) {
      // Remove existing max-w-* classes
      const classList = Array.from(modalBox.classList)
      classList.forEach(cls => {
        if (cls.startsWith('max-w-') || cls.startsWith('w-')) {
          modalBox.classList.remove(cls)
        }
      })
      
      // Add custom width classes
      options.width.split(' ').forEach(cls => {
        modalBox.classList.add(cls)
      })
    }

    // Load URL in frame if provided
    if (options.url) {
      const frame = this.element.querySelector('turbo-frame')
      if (frame) {
        frame.src = options.url
      }
    }
  }

  close(event) {
    if (event) {
      event.preventDefault()
    }
    
    if (this.element.open) {
      // Just close the dialog
      // The 'close' event will handle restoration
      this.element.close()
    }
  }

  setEventListeners() {
    this.element.addEventListener('modal:close', () => {
      console.log('modal:close event received')
      this.close()
    })
  }
}

