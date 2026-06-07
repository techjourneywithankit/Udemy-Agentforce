@RestResource(urlMapping='/mcp/createCase')
global with sharing class McpCreateCase {

    global class ResponseWrapper {
        public String recordNumber;
        public String message;

        public ResponseWrapper(String recordNumber, String message) {
            this.recordNumber = recordNumber;
            this.message = message;
        }
    }

    @HttpPost
    global static ResponseWrapper execute(String subject, String description, String priority) {

        Case c = new Case(
            Subject = subject,
            Description = description,
            Priority = priority,
            Origin = 'Web'
        );

        insert c;

        // Retrieve Case Number
        Case newCase = [
            SELECT CaseNumber 
            FROM Case 
            WHERE Id = :c.Id
            LIMIT 1
        ];

        return new ResponseWrapper(newCase.CaseNumber, 'Success: Case created');
    }
}