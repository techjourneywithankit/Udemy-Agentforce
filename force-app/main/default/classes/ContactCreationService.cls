/*
 * @description Apex Invocable Service for creating Contact records
 * This class demonstrates how to create an Apex action that can be called from Agent Script
 * Used by the CustomActionsDemo agent for contact creation
 */

public class ContactCreationService {
    
    /**
     * @description Request class for contact creation
     * Each @InvocableVariable maps to an input in the agent action
     */
    public class ContactRequest {
        @InvocableVariable(
            label='Last Name'
            description='The last name for the new contact record'
            required=true
        )
        public String lastname;

        @InvocableVariable(
            label='Email'
            description='The email address for the new contact record'
            required=true
        )
        public String email;

        @InvocableVariable(
            label='Phone'
            description='The phone number for the new contact record'
            required=false
        )
        public String phone;
    }
    
      /**
     * @description Response class for contact creation
     * Each @InvocableVariable maps to an output in the agent action
     */
    public class ContactResponse {
        @InvocableVariable(
            label='New Contact ID'
            description='The Salesforce ID of the newly created contact'
        )
        public String new_contact_id;

        @InvocableVariable(
            label='Success'
            description='True if contact was created successfully, false if creation failed'
        )
        public Boolean success;

        @InvocableVariable(
            label='Message'
            description='Success confirmation or error message describing the result'
        )
        public String message;
    }
    
    /**
     * @description Creates a new contact record in Salesforce
     * @param requests List of ContactRequest objects containing contact details
     * @return List of ContactResponse objects with creation results
     */
    @InvocableMethod(
        label='Create New Contact'
        description='Creates a new contact record in Salesforce with the provided last name and email'
    )
    public static List<ContactResponse> createContact(List<ContactRequest> requests) {
 		List<ContactResponse> responses = new List<ContactResponse>();

        for (ContactRequest req : requests) {
            ContactResponse response = new ContactResponse();

            try {
                // Validate inputs
                if (String.isBlank(req.lastname)) {
                    response.success = false;
                    response.message = 'Last name is required';
                    response.new_contact_id = '';
                    responses.add(response);
                    continue;
                }

                if (String.isBlank(req.email)) {
                    response.success = false;
                    response.message = 'Email is required';
                    response.new_contact_id = '';
                    responses.add(response);
                    continue;
                }

                // Validate email format
                if (!isValidEmail(req.email)) {
                    response.success = false;
                    response.message = 'Invalid email format: ' + req.email;
                    response.new_contact_id = '';
                    responses.add(response);
                    continue;
                }

                // Create the contact record
                Contact newContact = new Contact(
                    LastName = req.lastname,
                    Email = req.email
                );

                // Add phone if provided
                if (String.isNotBlank(req.phone)) {
                    newContact.Phone = req.phone;
                }

                insert newContact;

                // Set success response
                response.new_contact_id = newContact.Id;
                response.success = true;
                response.message = 'Contact created successfully: ' + req.lastname + ' (' + req.email + ')';

            } catch (DmlException e) {
                response.success = false;
                response.message = 'Failed to create contact: ' + e.getMessage();
                response.new_contact_id = '';
            } catch (Exception e) {
                response.success = false;
                response.message = 'Unexpected error: ' + e.getMessage();
                response.new_contact_id = '';
            }

            responses.add(response);
        }

        return responses;
    }

    /**
     * @description Validates email format using a simple pattern
     * @param email The email address to validate
     * @return True if email format is valid, false otherwise
     */
    private static Boolean isValidEmail(String email) {
        if (String.isBlank(email)) {
            return false;
        }
        // Simple email validation pattern
        String emailPattern = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$';
        Pattern p = Pattern.compile(emailPattern);
        Matcher m = p.matcher(email);
        return m.matches();
    }

}