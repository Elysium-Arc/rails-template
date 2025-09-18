import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static values = {
        sortColumn: String,
        sortDirection: String
    }

    connect() {
    }

    sort(event) {
        event.preventDefault()

        const column = event.currentTarget.dataset.tableColumn
        const url = new URL(window.location)
        
        // Get current sorts from URL
        const currentSorts = url.searchParams.getAll('sort[]').length > 0 
            ? url.searchParams.getAll('sort[]')
            : (url.searchParams.get('sort') ? [url.searchParams.get('sort')] : [])
        
        const currentDirections = url.searchParams.getAll('direction[]').length > 0
            ? url.searchParams.getAll('direction[]')
            : (url.searchParams.get('direction') ? [url.searchParams.get('direction')] : [])
        
        // Build current sorts array
        const sorts = currentSorts.map((col, index) => ({
            column: col,
            direction: currentDirections[index] || 'asc'
        }))

        // Find if this column is already sorted
        const existingIndex = sorts.findIndex(s => s.column === column)
        
        if (existingIndex >= 0) {
            // Column is already sorted
            if (sorts[existingIndex].direction === 'asc') {
                // First click: asc -> second click: desc
                sorts[existingIndex].direction = 'desc'
            } else {
                // Second click: desc -> third click: remove sort
                sorts.splice(existingIndex, 1)
            }
        } else {
            // Column not sorted yet - add as ascending
            sorts.push({ column, direction: 'asc' })
        }

        // Always do a page refresh to ensure everything stays in sync
        this.updateSort(sorts)
    }

    updateSort(sorts) {
        const url = new URL(window.location)

        // Clear old sort params
        url.searchParams.delete('sort')
        url.searchParams.delete('sort[]')
        url.searchParams.delete('direction')
        url.searchParams.delete('direction[]')

        // Add new sort params
        if (sorts && sorts.length > 0) {
            sorts.forEach(sort => {
                url.searchParams.append('sort[]', sort.column)
                url.searchParams.append('direction[]', sort.direction)
            })

            // Dispatch event with first sort for backwards compatibility
            document.dispatchEvent(new CustomEvent('table:sort-changed', {
                detail: { column: sorts[0].column, direction: sorts[0].direction },
                bubbles: true
            }))
        } else {
            // Dispatch event with null to clear
            document.dispatchEvent(new CustomEvent('table:sort-changed', {
                detail: { column: null, direction: null },
                bubbles: true
            }))
        }

        // Reset to page 1 when sorting changes
        url.searchParams.delete('page')

        // Use Turbo.visit for full page navigation (fast, updates all frames)
        if (typeof Turbo !== 'undefined' && Turbo.visit) {
            Turbo.visit(url.toString(), { frame: '_top' })
        } else {
            window.location.href = url.toString()
        }
    }

    // Handle responsive table behavior

    toggleSelectAll(event) {
        const isChecked = event.target.checked
        const checkboxes = this.element.querySelectorAll('tbody input[type="checkbox"]')

        checkboxes.forEach(checkbox => {
            checkbox.checked = isChecked
        })

        this.updateSelectedIds()
    }

    toggleSelect(event) {
        const checkbox = event.target
        this.updateSelectAllCheckbox()
        this.updateSelectedIds()
    }

    updateSelectAllCheckbox() {
        const selectAllCheckbox = this.element.querySelector('thead input[type="checkbox"]')
        const checkboxes = this.element.querySelectorAll('tbody input[type="checkbox"]')
        const checkedBoxes = this.element.querySelectorAll('tbody input[type="checkbox"]:checked')

        selectAllCheckbox.checked = checkboxes.length > 0 && checkboxes.length === checkedBoxes.length
        selectAllCheckbox.indeterminate = checkedBoxes.length > 0 && checkedBoxes.length < checkboxes.length
    }

    updateSelectedIds() {
        const checkedBoxes = this.element.querySelectorAll('tbody input[type="checkbox"]:checked')
        const selectedIds = Array.from(checkedBoxes).map(cb => cb.dataset.tableRecordId)

        // Dispatch custom event with selected IDs
        this.element.dispatchEvent(new CustomEvent('table:selection-changed', {
            detail: { selectedIds },
            bubbles: true
        }))
    }

    disconnect() {
    }
}