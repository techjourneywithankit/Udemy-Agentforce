/**
 * @description Invocable Apex service to update internal comments on a Case by Case Number
 * and return the Case Priority, Subject, Description, and the posted comment.
 * Designed for use with Agentforce actions.
 * @see CaseInternalCommentServiceTest
 */
public with sharing class CaseInternalCommentService {

    /**
     * @description Request wrapper for the invocable method.
     */
    public class CommentRequest {
        @InvocableVariable(
            label='Case Number'
            description='The Case Number to look up (e.g. 00001042)'
            required=true
        )
        public String caseNumber;

        @InvocableVariable(
            label='Internal Comment'
            description='The internal comment text to add to the Case'
            required=true
        )
        public String internalComment;
    }

    /**
     * @description Response wrapper containing case details and the posted comment.
     */
    public class CommentResponse {
        @InvocableVariable(
            label='Success'
            description='True if the operation completed successfully'
        )
        public Boolean success;

        @InvocableVariable(
            label='Message'
            description='Status or error message'
        )
        public String message;

        @InvocableVariable(
            label='Priority'
            description='The priority of the Case'
        )
        public String priority;

        @InvocableVariable(
            label='Subject'
            description='The subject of the Case'
        )
        public String subject;

        @InvocableVariable(
            label='Description'
            description='The description of the Case'
        )
        public String description;

        @InvocableVariable(
            label='Internal Comment'
            description='The internal comment that was posted'
        )
        public String internalComment;
    }

    /**
     * @description Adds an internal comment to the Case identified by Case Number
     * and returns the Case Priority, Subject, Description, and posted comment.
     * @param requests List of CommentRequest with case number and comment text
     * @return List of CommentResponse with case details for each request
     */
    @InvocableMethod(
        label='Update Case Internal Comment'
        description='Adds an internal comment to a Case by Case Number and returns Priority, Subject, Description, and the comment'
    )
    public static List<CommentResponse> updateInternalComment(List<CommentRequest> requests) {
        List<CommentResponse> responses = new List<CommentResponse>();

        if (requests == null || requests.isEmpty()) {
            responses.add(buildErrorResponse('No request provided'));
            return responses;
        }

        Set<String> caseNumbers = new Set<String>();
        for (CommentRequest req : requests) {
            if (String.isNotBlank(req.caseNumber)) {
                caseNumbers.add(req.caseNumber.trim());
            }
        }

        Map<String, Case> casesByNumber = new Map<String, Case>();
        if (!caseNumbers.isEmpty()) {
            for (Case c : [
                SELECT Id, CaseNumber, Priority, Subject, Description
                FROM Case
                WHERE CaseNumber IN :caseNumbers
                WITH USER_MODE
            ]) {
                casesByNumber.put(c.CaseNumber, c);
            }
        }

        List<CaseComment> commentsToInsert = new List<CaseComment>();
        List<Integer> commentIndexes = new List<Integer>();

        for (Integer i = 0; i < requests.size(); i++) {
            CommentRequest req = requests[i];
            CommentResponse response = new CommentResponse();

            if (String.isBlank(req.caseNumber)) {
                responses.add(buildErrorResponse('Case Number is required'));
                continue;
            }

            if (String.isBlank(req.internalComment)) {
                responses.add(buildErrorResponse('Internal Comment is required'));
                continue;
            }

            String trimmedNumber = req.caseNumber.trim();
            Case matchedCase = casesByNumber.get(trimmedNumber);

            if (matchedCase == null) {
                responses.add(buildErrorResponse('No Case found with number: ' + trimmedNumber));
                continue;
            }

            CaseComment comment = new CaseComment();
            comment.ParentId = matchedCase.Id;
            comment.CommentBody = req.internalComment.trim();
            comment.IsPublished = false;
            commentsToInsert.add(comment);
            commentIndexes.add(i);

            response.success = true;
            response.priority = String.isNotBlank(matchedCase.Priority) ? matchedCase.Priority : 'None';
            response.subject = String.isNotBlank(matchedCase.Subject) ? matchedCase.Subject : '';
            response.description = String.isNotBlank(matchedCase.Description) ? matchedCase.Description : '';
            response.internalComment = req.internalComment.trim();
            response.message = 'Internal comment added to Case ' + trimmedNumber;
            responses.add(response);
        }

        if (!commentsToInsert.isEmpty()) {
            List<Database.SaveResult> saveResults = Database.insert(
                commentsToInsert, AccessLevel.USER_MODE
            );

            Integer responseOffset = 0;
            for (Integer j = 0; j < saveResults.size(); j++) {
                if (!saveResults[j].isSuccess()) {
                    Integer originalIndex = commentIndexes[j];
                    String errorMsg = saveResults[j].getErrors()[0].getMessage();
                    CommentResponse failedResponse = buildErrorResponse(
                        'Failed to insert comment: ' + errorMsg
                    );
                    responses.set(originalIndex, failedResponse);
                }
            }
        }

        return responses;
    }

    /**
     * @description Creates an error response with success=false.
     * @param errorMsg Error message to return
     * @return CommentResponse configured for failure
     */
    private static CommentResponse buildErrorResponse(String errorMsg) {
        CommentResponse response = new CommentResponse();
        response.success = false;
        response.message = errorMsg;
        response.priority = '';
        response.subject = '';
        response.description = '';
        response.internalComment = '';
        return response;
    }
}
