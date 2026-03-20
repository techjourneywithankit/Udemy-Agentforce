/**
 * @description Invocable Apex service to retrieve open Cases for a Contact by email address.
 * Designed for use with Agentforce actions. Returns Case Number, Priority, Status, and Subject
 * for all open (non-closed) Cases linked to the Contact.
 * @see OpenCasesByContactEmailServiceTest
 */
public with sharing class OpenCasesByContactEmailService {

    /**
     * @description Request wrapper for the invocable method.
     */
    public class OpenCasesRequest {
        @InvocableVariable(
            label='Email'
            description='The email address of the contact to look up'
            required=true
        )
        public String email;
    }

    /**
     * @description Response wrapper containing open cases summary.
     */
    public class OpenCasesResponse {
        @InvocableVariable(
            label='Success'
            description='True if the lookup completed successfully'
        )
        public Boolean success;

        @InvocableVariable(
            label='Message'
            description='Status or error message'
        )
        public String message;

        @InvocableVariable(
            label='Case Count'
            description='Number of open cases found for the contact'
        )
        public Integer case_count;

        @InvocableVariable(
            label='Cases Summary'
            description='Formatted list of open cases with Case Number, Priority, Status, and Subject'
        )
        public String cases_summary;
    }

    /**
     * @description Retrieves all open Cases for the Contact matching the given email.
     * Only returns Cases where IsClosed = false.
     * @param requests List of OpenCasesRequest with email to look up
     * @return List of OpenCasesResponse with case details for each request
     */
    @InvocableMethod(
        label='Get Open Cases by Contact Email'
        description='Retrieves open cases (Case Number, Priority, Status, Subject) for a contact by email address'
    )
    public static List<OpenCasesResponse> getOpenCases(List<OpenCasesRequest> requests) {
        List<OpenCasesResponse> responses = new List<OpenCasesResponse>();

        if (requests == null || requests.isEmpty()) {
            responses.add(buildErrorResponse('No request provided'));
            return responses;
        }

        for (OpenCasesRequest req : requests) {
            OpenCasesResponse response = new OpenCasesResponse();

            try {
                if (String.isBlank(req.email)) {
                    response = buildErrorResponse('Email is required');
                    responses.add(response);
                    continue;
                }

                if (!isValidEmail(req.email)) {
                    response = buildErrorResponse('Invalid email format: ' + req.email);
                    responses.add(response);
                    continue;
                }

                List<Contact> contacts = [
                    SELECT Id
                    FROM Contact
                    WHERE Email = :req.email.trim()
                    WITH USER_MODE
                    LIMIT 1
                ];

                if (contacts.isEmpty()) {
                    response.success = true;
                    response.message = 'No contact found with email: ' + req.email;
                    response.case_count = 0;
                    response.cases_summary = '';
                    responses.add(response);
                    continue;
                }

                Id contactId = contacts[0].Id;

                List<Case> openCases = [
                    SELECT CaseNumber, Priority, Status, Subject
                    FROM Case
                    WHERE ContactId = :contactId
                    AND IsClosed = false
                    WITH USER_MODE
                    ORDER BY CreatedDate DESC
                ];

                response.success = true;
                response.case_count = openCases.size();
                response.message = openCases.isEmpty()
                    ? 'No open cases found for contact with email: ' + req.email
                    : 'Found ' + openCases.size() + ' open case(s)';

                response.cases_summary = formatCasesSummary(openCases);
                responses.add(response);

            } catch (QueryException e) {
                response = buildErrorResponse('Query error: ' + e.getMessage());
                responses.add(response);
            } catch (Exception e) {
                response = buildErrorResponse('Unexpected error: ' + e.getMessage());
                responses.add(response);
            }
        }

        return responses;
    }

    /**
     * @description Builds a formatted string of case details for agent display.
     * @param cases List of Case records
     * @return Formatted string with numbered cases and Case Number, Priority, Status, Subject
     */
    private static String formatCasesSummary(List<Case> cases) {
        if (cases == null || cases.isEmpty()) {
            return '';
        }

        List<String> blocks = new List<String>();
        Integer index = 1;
        for (Case c : cases) {
            String priority = String.isNotBlank(c.Priority) ? c.Priority : 'None';
            String status = String.isNotBlank(c.Status) ? c.Status : '';
            String subject = String.isNotBlank(c.Subject) ? c.Subject : '(No subject)';
            blocks.add(
                index + '. Case Number - ' + c.CaseNumber + '\n' +
                '   Case Priority - ' + priority + '\n' +
                '   Case Status - ' + status + '\n' +
                '   Subject - ' + subject
            );
            index++;
        }
        return String.join(blocks, '\n\n');
    }

    /**
     * @description Creates an error response with success=false.
     * @param errorMsg Error message to return
     * @return OpenCasesResponse configured for failure
     */
    private static OpenCasesResponse buildErrorResponse(String errorMsg) {
        OpenCasesResponse response = new OpenCasesResponse();
        response.success = false;
        response.message = errorMsg;
        response.case_count = 0;
        response.cases_summary = '';
        return response;
    }

    /**
     * @description Validates email format.
     * @param email The email address to validate
     * @return True if format is valid
     */
    private static Boolean isValidEmail(String email) {
        if (String.isBlank(email)) {
            return false;
        }
        String emailPattern = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$';
        Pattern p = Pattern.compile(emailPattern);
        Matcher m = p.matcher(email.trim());
        return m.matches();
    }
}
