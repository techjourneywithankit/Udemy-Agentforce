/**
 * @description Invocable Apex that looks up a Case by Case Number and
 *              returns a one-line summary. Used as the Apex-backed action
 *              in the CreateSupportCase agent, after Flow creates the Case.
 *              Read-only — no DML.
 */
public with sharing class CaseDetailsByNumberService {
    /**
     * @description Request wrapper for a single case-number lookup.
     */
    public class LookupRequest {
        @InvocableVariable(
            label='Case Number'
            description='The Case Number to look up (for example 00001012)'
            required=true
        )
        public String caseNumber;
    }

    /**
     * @description Response wrapper with a Case summary for the agent to read back.
     */
    public class LookupResponse {
        @InvocableVariable(
            label='Case Summary'
            description='One-line summary of the Case for the agent to read back'
        )
        public String caseSummary;
    }

    /**
     * @description Looks up each Case by Case Number and returns a summary.
     * @param requests List of LookupRequest objects
     * @return List of LookupResponse objects (one per request, in order)
     */
    @InvocableMethod(
        label='Get Case Details by Number'
        description='Looks up a Case by Case Number and returns a one-line summary'
    )
    public static List<LookupResponse> getCaseDetails(
        List<LookupRequest> requests
    ) {
        List<LookupResponse> responses = new List<LookupResponse>();
        if (requests == null || requests.isEmpty()) {
            responses.add(summaryResponse('Case Number is required.'));
            return responses;
        }

        Set<String> caseNumbers = new Set<String>();
        for (LookupRequest req : requests) {
            if (req != null && String.isNotBlank(req.caseNumber)) {
                caseNumbers.add(req.caseNumber.trim());
            }
        }

        Map<String, Case> casesByNumber = new Map<String, Case>();
        if (!caseNumbers.isEmpty()) {
            for (Case record : [
                SELECT CaseNumber, Status, Priority
                FROM Case
                WHERE CaseNumber IN :caseNumbers
                WITH USER_MODE
            ]) {
                casesByNumber.put(record.CaseNumber, record);
            }
        }

        for (LookupRequest req : requests) {
            if (req == null || String.isBlank(req.caseNumber)) {
                responses.add(summaryResponse('Case Number is required.'));
                continue;
            }

            Case record = casesByNumber.get(req.caseNumber.trim());
            if (record == null) {
                responses.add(
                    summaryResponse(
                        'No Case found with number ' + req.caseNumber.trim() + '.'
                    )
                );
                continue;
            }

            String priority = String.isBlank(record.Priority)
                ? 'None'
                : record.Priority;
            responses.add(
                summaryResponse(
                    'Case ' +
                    record.CaseNumber +
                    ' is ' +
                    record.Status +
                    ' with ' +
                    priority +
                    ' priority.'
                )
            );
        }

        return responses;
    }

    private static LookupResponse summaryResponse(String message) {
        LookupResponse response = new LookupResponse();
        response.caseSummary = message;
        return response;
    }
}
