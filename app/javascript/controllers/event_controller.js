import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  // Broadcast an event using dataset only.
  // - data-event-name is required.
  // - data-event-data is optional. We attempt JSON.parse, falling back to the raw string.
  // - The dispatched CustomEvent.detail will always include `element: this.element`.
  broadcast() {
    const eventName = this.element.dataset.eventName;
    if (!eventName) {
      throw new Error("data-event-name is required for event_controller#broadcast");
    }

    const rawData = this.element.dataset.eventData;
    let parsedData;
    if (rawData === undefined) {
      parsedData = undefined;
    } else {
      try {
        parsedData = JSON.parse(rawData);
      } catch {
        // If it's not valid JSON, use the raw string
        parsedData = rawData;
      }
    }

    const detail = { element: this.element };
    if (parsedData !== undefined) detail.data = parsedData;

    const event = new CustomEvent(eventName, { bubbles: true, composed: true, detail });
    document.dispatchEvent(event);
  }
}
