import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "source" ]
  static values = { url: String }

  connect() {
    if(this.urlValue) {
      fetch(this.urlValue, {
        method: "GET",
        headers: {
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': getMetaValue("csrf-token")
        },
        credentials: 'same-origin'
      })
        .then(response => response.json())
        .then(v => {
          this.sourceTargets[0].value = v.amount_cents / 100
        })
    }
  }

  apply() {
    // TODO decide what to do with validation errors
    fetch(this.urlValue, {
      method: "PATCH",
      headers: {
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': getMetaValue("csrf-token"),
        'Content-Type': 'application/json'
      },
      credentials: 'same-origin',
      body: JSON.stringify({
        amount_cents: this.sourceTargets[0].value * 100
      })
    })
      .then(v => {
        window.location.reload()
      }) 
  }
}

function getMetaValue(name) {
  const element = document.head.querySelector(`meta[name="${name}"]`)
  return element.getAttribute("content")
}
