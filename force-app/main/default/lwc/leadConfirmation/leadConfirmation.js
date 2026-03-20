import { LightningElement,api } from 'lwc';

export default class LeadConfirmation extends LightningElement {
    @api value;
    lead = {};

  connectedCallback() {
    if (this.value) {
      this.lead = this.value;
    } else {
      console.error("leadConfirmation: No value provided");
    }
  }

  get hasLead() {
    return this.lead && Object.keys(this.lead).length > 0;
  }

  get fullName() {
    const first = this.lead?.firstName || "";
    const last = this.lead?.lastName || "";
    return [first, last].filter(Boolean).join(" ").trim() || "—";
  }

  get statusVariant() {
    if (this.lead?.status === "SUBMITTED") return "success";
    return "default";
  }

  get statusIcon() {
    if (this.lead?.status === "SUBMITTED") return "utility:success";
    return "utility:info";
  }

}