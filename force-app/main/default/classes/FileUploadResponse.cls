global class FileUploadResponse {
    
    // This is the variable that will show up in the Agent Action Output list
    @InvocableVariable
    @AuraEnabled
    global FileUploadInfo result;

    public FileUploadResponse() {}
}