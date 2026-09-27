import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["addButton", "checkoutButton", "badge", "badgeCount"];

  add(event) {
    const btn = event.currentTarget;
    const originalText = btn.textContent.trim();
    const originalClasses = [...btn.classList];

    // Button aufleuchten
    btn.textContent = "✓";
    btn.classList.add("bg-green-600", "scale-110");
    btn.classList.remove("bg-blue-600", "bg-gray-700");

    // Badge animieren
    if (this.hasBadgeTarget) {
      this.badgeTarget.classList.add("animate-bounce");
      setTimeout(() => {
        this.badgeTarget.classList.remove("animate-bounce");
      }, 800);
    }

    // Button zurücksetzen
    setTimeout(() => {
      btn.textContent = originalText;
      btn.classList.remove("bg-green-600", "scale-110");
      btn.classList.add("bg-blue-600");
    }, 600);
  }

  checkout(event) {
    const btn = event.currentTarget;

    // Zweiter Klick während der Buchung: unterdrücken, sonst wird doppelt gebucht.
    if (btn.dataset.checkoutPending === "true") {
      event.preventDefault();
      return;
    }

    btn.dataset.checkoutPending = "true";
    btn.innerHTML = `
      <span class="inline-block w-6 h-6 border-2 border-white/30
                   border-t-white rounded-full animate-spin
                   align-middle mr-2"></span>
      Wird gebucht…`;

    btn.classList.add("opacity-75", "cursor-not-allowed");
    btn.classList.remove("hover:bg-emerald-500", "active:scale-95");

    // Wichtig: Der Button darf hier NICHT synchron disabled werden. Der Browser
    // führt die Activation Behavior des Buttons erst nach dem click-Handler aus,
    // und die bricht bei einem disabled Button sofort ab ("If element is
    // disabled, then return"). Das Formular würde dann nie abgeschickt.
    setTimeout(() => { btn.disabled = true; }, 0);
  }

  remove(event) {
    const btn = event.currentTarget;
    const row = btn.closest("tr") || btn.closest("[data-cart-row]");

    if (row) {
      row.classList.add("opacity-0", "scale-95");
      row.style.transition = "all 0.2s ease-out";
    }
  }
}
