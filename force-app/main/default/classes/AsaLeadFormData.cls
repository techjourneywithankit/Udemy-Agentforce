/**
 * @description Lightning Type backing class for ASA Lead Form
 * Holds lead form data as JSON string
 * Used with Agentforce and Enhanced Chat
 */
@JsonAccess(serializable='always' deserializable='always')
global class AsaLeadFormData {
    
    @AuraEnabled
    global String leadFormJSON;
    
    /**
     * Constructor with JSON string
     */
    global AsaLeadFormData(String leadFormJSON) {
        this.leadFormJSON = leadFormJSON;
    }
    
    /**
     * Default constructor
     */
    global AsaLeadFormData() {
        this.leadFormJSON = '';
    }
}