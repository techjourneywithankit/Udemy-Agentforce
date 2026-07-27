import { LightningElement,api } from 'lwc';

export default class LeadInputEditor extends LightningElement {
     @api readOnly = false;
     _value;

    @api
    get value() { return this._value; }
    set value(val) {
        this._value = val;
        if (val) {
            this.firstName  = val.firstName || '';
            this.lastName   = val.lastName || '';
            this.company    = val.company || '';
            this.email      = val.email || '';
            this.phone      = val.phone || '';
            this.leadSource = val.leadSource || '';
        }
    }

    firstName = '';  lastName = '';  company = '';
    email = '';      phone = '';     leadSource = '';

    leadSourceOptions = [
        { label: 'Web', value: 'Web' },
        { label: 'Phone Inquiry', value: 'Phone Inquiry' },
        { label: 'Partner Referral', value: 'Partner Referral' },
        { label: 'Purchased List', value: 'Purchased List' },
        { label: 'Other', value: 'Other' }
    ];

    handleInputChange(event) {
        event.stopPropagation();
        const { name, value } = event.target;
        this[name] = value;

        // CRITICAL: Always dispatch ALL fields
        this.dispatchEvent(new CustomEvent('valuechange', {
            detail: {
                value: {
                    firstName: this.firstName, lastName: this.lastName,
                    company: this.company,     email: this.email,
                    phone: this.phone,         leadSource: this.leadSource
                }
            }
        }));
    }
}