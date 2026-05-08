/**
 * @description Invocable Apex service that qualifies a Lead using its
 *              human-readable auto-number reference (Lead_Reference_Number__c).
 *              Reads the Lead's standard fields, calculates a score (0-100),
 *              and returns the lead name and score — or an error message if
 *              the Lead is not found.
 *
 *              Used as the single Apex-backed action in the LeadQualifier
 *              agent recipe. Read-only — no DML.
 */
public with sharing class LeadQualifierService {
    /**
     * @description Request wrapper for a single qualify-lead invocation.
     */
    public class QualifyRequest {
        @InvocableVariable(
            label='Lead Reference Number'
            description='The Lead auto-number reference (e.g. LEAD-00042)'
            required=true
        )
        public String leadReferenceNumber;
    }

    /**
     * @description Response wrapper returning qualification results.
     *              Exactly one of (leadName + score) or errorMessage will be populated.
     */
    public class QualifyResponse {
        @InvocableVariable(
            label='Lead Name'
            description='The full name of the qualified Lead — populated on success'
        )
        public String leadName;

        @InvocableVariable(
            label='Score'
            description='Calculated lead score from 0 to 100 — populated on success'
        )
        public Integer score;

        @InvocableVariable(
            label='Error Message'
            description='Error details when the Lead cannot be found or scored — populated on failure'
        )
        public String errorMessage;
    }

    /**
     * @description Looks up each Lead by its reference number and calculates a score.
     * @param requests List of QualifyRequest objects
     * @return List of QualifyResponse objects (one per request, in order)
     */
    @InvocableMethod(
        label='Qualify Lead'
        description='Looks up a Lead by its reference number and returns a calculated score'
    )
    public static List<QualifyResponse> qualifyLead(
        List<QualifyRequest> requests
    ) {
        List<QualifyResponse> responses = new List<QualifyResponse>();

        Set<String> refNumbers = new Set<String>();
        for (QualifyRequest req : requests) {
            if (String.isNotBlank(req.leadReferenceNumber)) {
                refNumbers.add(req.leadReferenceNumber.trim());
            }
        }

        Map<String, Lead> leadsByRef = new Map<String, Lead>();
        if (!refNumbers.isEmpty()) {
            for (Lead lead : [
                SELECT
                    Name,
                    Industry,
                    AnnualRevenue,
                    NumberOfEmployees,
                    Lead_Reference_Number__c
                FROM Lead
                WHERE Lead_Reference_Number__c IN :refNumbers
                WITH USER_MODE
            ]) {
                leadsByRef.put(lead.Lead_Reference_Number__c, lead);
            }
        }

        for (QualifyRequest req : requests) {
            QualifyResponse response = new QualifyResponse();

            if (String.isBlank(req.leadReferenceNumber)) {
                response.errorMessage = 'Lead reference number is required.';
                responses.add(response);
                continue;
            }

            Lead lead = leadsByRef.get(req.leadReferenceNumber.trim());
            if (lead == null) {
                response.errorMessage =
                    'No Lead found with reference ' +
                    req.leadReferenceNumber +
                    '.';
                responses.add(response);
                continue;
            }

            response.leadName = lead.Name;
            response.score = calculateScore(lead);
            responses.add(response);
        }

        return responses;
    }

    /**
     * @description Calculates a 0-100 score using Industry, AnnualRevenue,
     *              and NumberOfEmployees. Weights: Industry up to 30,
     *              Annual Revenue up to 40, Employee Count up to 30.
     */
    private static Integer calculateScore(Lead lead) {
        Integer score = 0;
        score += scoreIndustry(lead.Industry);
        score += scoreRevenue(lead.AnnualRevenue);
        score += scoreEmployees(lead.NumberOfEmployees);
        return Math.min(100, Math.max(0, score));
    }

    private static Integer scoreIndustry(String industry) {
        if (String.isBlank(industry)) {
            return 0;
        }
        Set<String> highValue = new Set<String>{
            'Technology',
            'Finance',
            'Banking',
            'Healthcare',
            'Biotechnology'
        };
        Set<String> midValue = new Set<String>{
            'Manufacturing',
            'Consulting',
            'Telecommunications',
            'Energy'
        };
        if (highValue.contains(industry)) {
            return 30;
        }
        if (midValue.contains(industry)) {
            return 18;
        }
        return 8;
    }

    private static Integer scoreRevenue(Decimal annualRevenue) {
        if (annualRevenue == null || annualRevenue <= 0) {
            return 0;
        }
        if (annualRevenue >= 100000000) {
            return 40;
        }
        if (annualRevenue >= 10000000) {
            return 28;
        }
        if (annualRevenue >= 1000000) {
            return 15;
        }
        return 5;
    }

    private static Integer scoreEmployees(Decimal numberOfEmployees) {
        if (numberOfEmployees == null || numberOfEmployees <= 0) {
            return 0;
        }
        if (numberOfEmployees >= 5000) {
            return 30;
        }
        if (numberOfEmployees >= 500) {
            return 20;
        }
        if (numberOfEmployees >= 50) {
            return 10;
        }
        return 5;
    }
}
