public class FileQnAService {
    
    @AuraEnabled(cacheable=false)
    public static String invokeFileQnATemplate(String userQuestion, Id fileId) {
        
         // Wrap the user question string in a WrappedValue object for the prompt template input
        ConnectApi.WrappedValue userQuestionInstance = new ConnectApi.WrappedValue();
        userQuestionInstance.value = userQuestion;

        // Create a map to hold the file ID (required format for object inputs)
        Map<String, String> recordMap = new Map<String, String>();
        recordMap.put('id', fileId); 
        
         // Wrap the file record map in a WrappedValue object for the prompt template input
        ConnectApi.WrappedValue fileInstance = new ConnectApi.WrappedValue();
        fileInstance.value = recordMap;
        
          // Create the input parameters map that will be passed to the prompt template
        // The key format 'Input:ParameterName' must match the API names defined in the template
        Map<String, ConnectApi.WrappedValue> inputParamsMap = new Map<String, ConnectApi.WrappedValue>();
        inputParamsMap.put('Input:User_Question', userQuestionInstance);
        inputParamsMap.put('Input:File', fileInstance);
        
         // Create the input object for the prompt template generation
        ConnectApi.EinsteinPromptTemplateGenerationsInput executeTemplateInput = new ConnectApi.EinsteinPromptTemplateGenerationsInput();
        
        // Configure additional settings for the LLM generation
        executeTemplateInput.additionalConfig = new ConnectApi.EinsteinLlmAdditionalConfigInput();
        executeTemplateInput.additionalConfig.applicationName = 'PromptBuilderPreview';
        
        // Set isPreview to false to generate actual responses (true would only resolve the prompt)
        executeTemplateInput.isPreview = false;
        
        // Assign the input parameters to the template input object
        executeTemplateInput.inputParams = inputParamsMap;
        
        // Invoke the prompt template using Connect API
        // This will resolve the template, pass it through the Einstein Trust Layer, and generate a response
        ConnectApi.EinsteinPromptTemplateGenerationsRepresentation generationsOutput = 
        ConnectApi.EinsteinLLM.generateMessagesForPromptTemplate('File_QnA_Template', executeTemplateInput);
        
        // Extract the first generation response from the output
        ConnectApi.EinsteinLLMGenerationItemOutput response = generationsOutput.generations[0];
        
         // Debug log the response for troubleshooting
        System.debug('Response ===>>>>> '+response.text);
        
        // Return the generated text response
        return response.text;
    }

}