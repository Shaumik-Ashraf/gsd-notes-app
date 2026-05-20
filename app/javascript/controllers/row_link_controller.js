import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  click(event) {
    if (event.target.closest("a, button, form")) return
    window.location.href = this.element.dataset.rowLink
  }
}
