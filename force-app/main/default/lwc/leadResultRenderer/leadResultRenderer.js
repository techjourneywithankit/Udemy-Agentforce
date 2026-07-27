import { LightningElement,api } from 'lwc';

export default class LeadResultRenderer extends LightningElement {
    @api value;

    get name()       { return this.value?.name || ''; }
    get company()     { return this.value?.company || ''; }
    get email()       { return this.value?.email || ''; }
    get phone()       { return this.value?.phone || ''; }
    get status()      { return this.value?.status || ''; }
    get leadSource()  { return this.value?.leadSource || ''; }
    get createdDate() { return this.value?.createdDate || ''; }
}