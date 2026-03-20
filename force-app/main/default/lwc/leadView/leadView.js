import { LightningElement, api } from "lwc";

export default class LeadView extends LightningElement {
  country = "";
  firstName = "";
  lastName = "";
  email = "";
  phone = "";
  companyName = "";
  title = "";

  countryOptions = [
    { label: "Canada", value: "Canada" },
    { label: "USA", value: "USA" },
    { label: "United Kingdom", value: "United Kingdom" },
    { label: "India", value: "India" },
    { label: "Australia", value: "Australia" }
  ];

  @api
  get value() {
    return {
      country: this.country,
      firstName: this.firstName,
      lastName: this.lastName,
      email: this.email,
      phone: this.phone,
      companyName: this.companyName,
      title: this.title
    };
  }
  set value(val) {
    if (val) {
      this.country = val.country || "";
      this.firstName = val.firstName || "";
      this.lastName = val.lastName || "";
      this.email = val.email || "";
      this.phone = val.phone || "";
      this.companyName = val.companyName || "";
      this.title = val.title || "";
    }
  }

  dispatchValueChange() {
    this.dispatchEvent(
      new CustomEvent("valuechange", {
        detail: { value: this.value },
        bubbles: true,
        composed: true
      })
    );
  }

  handleInputChange(event) {
    event.stopPropagation();
    const fieldName = event.target.name;
    const fieldValue = event.target.value;
    this[fieldName] = fieldValue;
    this.dispatchValueChange();
  }
}