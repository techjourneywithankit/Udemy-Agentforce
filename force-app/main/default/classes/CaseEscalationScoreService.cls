public with sharing class CaseEscalationScoreService {

    @InvocableMethod(
        label = 'Calculate Case Escalation Score'
        description = 'Calculates an escalation score for a Case based on priority, age, and account-related factors'
    )
    public static List<EscalationResult> calculateScore(List<EscalationRequest> requests) {

        List<EscalationResult> results = new List<EscalationResult>();

        if (requests == null || requests.isEmpty()) {
            return results;
        }

        // NOTE: Designed for single-record Agentforce execution
        Id caseId = requests[0].caseId;

        // Fetch Case and related Account data (selective fields only)
        Case c = [
            SELECT Id,
                   Priority,
                   CreatedDate,
                   AccountId,
                   Account.Rating,
                   Account.AnnualRevenue
            FROM Case
            WHERE Id = :caseId
            LIMIT 1
        ];

        // Count open Cases on the related Account
        Integer openCaseCount = 0;
        if (c.AccountId != null) {
            openCaseCount = [
                SELECT COUNT()
                FROM Case
                WHERE AccountId = :c.AccountId
                AND IsClosed = false
            ];
        }

        Integer escalationScore = 0;
        List<String> scoreDrivers = new List<String>();

        // -------- Priority Weight (Max 30) --------
        if (c.Priority == 'High') {
            escalationScore += 30;
            scoreDrivers.add('High case priority (+30)');
        } else if (c.Priority == 'Medium') {
            escalationScore += 15;
            scoreDrivers.add('Medium case priority (+15)');
        }

        // -------- Case Age Weight (Max 15) --------
        if (c.CreatedDate != null) {
            Long caseAgeHours =
                (System.now().getTime() - c.CreatedDate.getTime()) / (1000 * 60 * 60);

            if (caseAgeHours > 48) {
                escalationScore += 15;
                scoreDrivers.add('Case open for more than 48 hours (+15)');
            }
        }

        // -------- Account Rating Weight (Max 15) --------
        if (c.Account != null && c.Account.Rating == 'Hot') {
            escalationScore += 15;
            scoreDrivers.add('Account rating is Hot (+15)');
        }

        // -------- Revenue Weight (Max 15) --------
        if (c.Account != null &&
            c.Account.AnnualRevenue != null &&
            c.Account.AnnualRevenue >= 10000000) {

            escalationScore += 15;
            scoreDrivers.add('Account revenue is 10M or higher (+15)');
        }

        // -------- Open Case Load Weight (Max 10) --------
        if (openCaseCount >= 5) {
            escalationScore += 10;
            scoreDrivers.add('Account has 5 or more open cases (+10)');
        }

        // Prepare result
        EscalationResult result = new EscalationResult();
        result.escalationScore = escalationScore;
        result.isHighRisk = escalationScore >= 70;
        result.scoreSummary = buildSummary(escalationScore, scoreDrivers);

        results.add(result);
        return results;
    }

    // -------- Helper to build explainable summary --------
    private static String buildSummary(Integer score, List<String> drivers) {

        if (drivers.isEmpty()) {
            return 'Escalation score is ' + score +
                   '. No significant risk factors were identified.';
        }

        return 'Escalation score is ' + score +
               '. Contributing factors: ' +
               String.join(drivers, '; ') + '.';
    }

    // -------- Input Wrapper --------
    public class EscalationRequest {
        @InvocableVariable(
            required = true
            description = 'Case Record Id used to calculate escalation score'
        )
        public Id caseId;
    }

    // -------- Output Wrapper --------
    public class EscalationResult {

        @InvocableVariable(
            description = 'Calculated escalation score for the Case'
        )
        public Integer escalationScore;

        @InvocableVariable(
            description = 'Indicates whether the Case represents a high escalation risk'
        )
        public Boolean isHighRisk;

        @InvocableVariable(
            description = 'Explainable summary of factors contributing to the escalation score'
        )
        public String scoreSummary;
    }
}