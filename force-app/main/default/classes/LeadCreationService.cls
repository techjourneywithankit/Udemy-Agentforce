public with sharing class LeadCreationService {
   
 
      // --- CLT INPUT DATA SHAPE ---
    public class LeadInput {
        @InvocableVariable(label='First Name' description='Lead first name')
        public String firstName;

        @InvocableVariable(label='Last Name' description='Lead last name' required=true)
        public String lastName;

        @InvocableVariable(label='Company' description='Company name' required=true)
        public String company;

        @InvocableVariable(label='Email' description='Lead email address')
        public String email;

        @InvocableVariable(label='Phone' description='Lead phone number')
        public String phone;

        @InvocableVariable(label='Lead Source' description='How the lead was acquired')
        public String leadSource;
    }

    public class LeadResult {
        @InvocableVariable(label='Lead Id')
        public String leadId;

        @InvocableVariable(label='Name')
        public String name;

        @InvocableVariable(label='Company')
        public String company;

        @InvocableVariable(label='Email')
        public String email;

        @InvocableVariable(label='Phone')
        public String phone;

        @InvocableVariable(label='Status')
        public String status;

        @InvocableVariable(label='Lead Source')
        public String leadSource;

        @InvocableVariable(label='Created Date')
        public String createdDate;
    }

       // --- REQUEST WRAPPER ---
    // Field name "lead_data" MUST match Agent Script action input name
    public class CreateLeadRequest {
        @InvocableVariable(required=true)
        public LeadInput lead_data;
    }

        // --- RESPONSE WRAPPER ---
    // Field names MUST match Agent Script action output names
    public class CreateLeadResponse {
        @InvocableVariable
        public LeadResult lead_result;

        @InvocableVariable
        public String lead_id;
    }
    
    @InvocableMethod(label='Create Lead' description='Creates a new Lead record')
    public static List<CreateLeadResponse> createLead(
        List<CreateLeadRequest> requests
    ) {
        List<CreateLeadResponse> responses = new List<CreateLeadResponse>();

        for (CreateLeadRequest req : requests) {
            LeadInput input = req.lead_data;

            Lead newLead = new Lead(
                FirstName  = input.firstName,
                LastName   = input.lastName,
                Company    = input.company,
                Email      = input.email,
                Phone      = input.phone,
                LeadSource = String.isNotBlank(input.leadSource)
                    ? input.leadSource : 'Web'
            );
            insert newLead;

            newLead = [SELECT Id, Name, Company, Email, Phone,
                              Status, LeadSource, CreatedDate
                       FROM Lead WHERE Id = :newLead.Id];

            LeadResult result   = new LeadResult();
            result.leadId       = newLead.Id;
            result.name         = newLead.Name;
            result.company      = newLead.Company;
            result.email        = newLead.Email;
            result.phone        = newLead.Phone;
            result.status       = newLead.Status;
            result.leadSource   = newLead.LeadSource;
            result.createdDate  = newLead.CreatedDate.format('MMMM d, yyyy');

            CreateLeadResponse response = new CreateLeadResponse();
            response.lead_result = result;
            response.lead_id     = newLead.Id;
            responses.add(response);
        }
        return responses;
    }
}