public class AccountScoreFlexGrounding {

    @InvocableMethod
    public static List<Response> getPrompt(List<Request> requests) {

        Request input = requests[0];
        List<Response> responses = new List<Response>();
        Response output = new Response();
        responses.add(output);

        Account acc = input.account;

        Integer openCases = [
            SELECT COUNT()
            FROM Case
            WHERE AccountId = :acc.Id
            AND Status IN ('New','Working','Escalated')
        ];

        Integer closedWonDeals = [
            SELECT COUNT()
            FROM Opportunity
            WHERE AccountId = :acc.Id
            AND StageName = 'Closed Won'
        ];

        Integer score = 0;

        if (acc.AnnualRevenue != null && acc.AnnualRevenue > 1000000) {
            score += 40;
        } else {
            score += 20;
        }

        if (openCases == 0) {
            score += 30;
        } else {
            score += 10;
        }

        if (closedWonDeals > 0) {
            score += 30;
        }

        // Apex returns ONLY the calculated score as grounding
        output.Prompt = String.valueOf(score);

        return responses;
    }

    public class Request {
        @InvocableVariable(required=true)
        public Account account;
    }

    public class Response {
        @InvocableVariable
        public String Prompt;
    }
}