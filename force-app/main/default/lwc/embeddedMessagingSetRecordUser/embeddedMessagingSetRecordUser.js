import { LightningElement, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import Id from '@salesforce/user/Id';
import First_Name from '@salesforce/schema/User.FirstName';
import Last_Name from '@salesforce/schema/User.LastName';
import Email from '@salesforce/schema/User.Email';


const fields = [First_Name, Last_Name, Email];


export default class EmbeddedMessagingSetRecordUser extends LightningElement {
   userId = Id;
   user;


   @wire(getRecord, { recordId: '$userId', fields })
   wiredRecord({ error, data }) {
       if (error) {
           let message = "Unknown error";
           if (Array.isArray(error.body)) {
               message = error.body.map((e) => e.message).join(", ");
           } else if (typeof error.body.message === "string") {
               message = error.body.message;
           }
           console.error("Error loading user record:" + message);
       } else if (data) {
           this.user = data;
           console.log('before custom event');
           var selectedEvent = new CustomEvent('userInfo',
                   {
                       detail: {
                           fname: getFieldValue(this.user, First_Name),
                           lname : getFieldValue(this.user, Last_Name),
                           email: getFieldValue(this.user, Email)
                       },
                       bubbles: true,
                       composed: true
                   });


           // Dispatches the event.
           window.dispatchEvent(selectedEvent);
       }
   }
}