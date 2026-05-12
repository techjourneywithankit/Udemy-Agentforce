public class CasePriorityRecommenderInvoker {

    private static final String AGENT_API_NAME = 'CasePriorityRecommender';
    public static String recommendPriority(String subject, String description) {
        
         String userMessage =
            'Please recommend a priority for this case. ' +
            'Subject: ' + subject + '. ' +
            'Description: ' + description;

         String sessionId = null;
        
         Invocable.Action action = Invocable.Action.createCustomAction(
            'generateAiAgentResponse',
            AGENT_API_NAME
        );
        
        action.setInvocationParameter('userMessage', userMessage);
        
          if (sessionId != null) {
            // Add session id only if it exists
            action.setInvocationParameter('sessionId', sessionId);
        }
        
        List<Invocable.Action.Result> results = action.invoke();
        
         Invocable.Action.Result result = results[0];
        String agentResponse = (String) result.getOutputParameters()
            .get('agentResponse');
        System.debug('Agent Response: ' + agentResponse);
        return agentResponse;
    }

}