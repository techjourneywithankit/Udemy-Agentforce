global class FileUploadAction {
    
    global class Input {
        @InvocableVariable(required=true)
        global Id recordId;
    }

    @InvocableMethod(label='Get File Uploader' description='Returns a UI component to upload a file')
    global static List<FileUploadResponse> getFileUploader(List<Input> inputs) {
        List<FileUploadResponse> outputList = new List<FileUploadResponse>();

        for (Input inp : inputs) {
            // 1. Create the Data Object
            FileUploadInfo info = new FileUploadInfo();
            info.targetRecordId = inp.recordId;

            // 2. Put it inside the Envelope
            FileUploadResponse resp = new FileUploadResponse();
            resp.result = info;

            outputList.add(resp);
        }

        return outputList;
    }
}