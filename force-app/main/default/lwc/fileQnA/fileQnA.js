import { LightningElement } from 'lwc';
import invokeFileQnATemplate from '@salesforce/apex/FileQnAService.invokeFileQnATemplate';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class FileQnA extends LightningElement {
    acceptedFormats = ['.pdf','.png','.jpg','.jpeg'];
    contentDocumentId;
    fileUploaded=false;
    errorMessage;
    userQuestion
    isLoading = false;
    hasQuestion = false;
    answer;

    handleUploadFinished(){
         const uploadedFiles = event.detail.files;
         if (uploadedFiles && uploadedFiles.length > 0){
            const uploadResult = uploadedFiles[0];
            if (uploadResult.documentId) {
                // Get the ContentDocumentId from the uploaded file
                this.contentDocumentId = uploadResult.documentId;
                this.fileUploaded=true;
                this.errorMessage='';
                 // Show success toast
                this.showToast('Success', 'File uploaded successfully', 'success');
            } else {
                // Show error toast
                this.showToast('Error', 'File upload failed', 'error');
                this.fileUploaded=false;
                this.errorMessage='File upload failed. Please ensure you have a valid record context or are logged in.';
            }
         }
    }

     showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

    handleQuestionChange(event){
        this.userQuestion=event.target.value;
        this.errorMessage='';
        this.hasQuestion = this.userQuestion.length > 0;
    }

    handleSubmit(){

         if(!this.contentDocumentId){
            this.errorMessage = 'Please upload a file before asking a question.';
            this.showToast('Error', this.errorMessage, 'error');
            return;
        }

        if(this.hasQuestion === false){
            this.errorMessage = 'Please enter a question before submitting.';
            this.showToast('Error', this.errorMessage, 'error');
            return;
        }

        this.isLoading = true;
        this.errorMessage = '';
        this.answer = '';

        invokeFileQnATemplate({
            userQuestion : this.userQuestion,
            fileId : this.contentDocumentId
        }).then(result => {
            this.answer = result;
            this.showToast('Success', 'Question submitted successfully', 'success');
            this.isLoading = false;
        })
        .catch(error => {
            this.errorMessage = error.body.message;
            this.showToast('Error', this.errorMessage, 'error');
            this.isLoading = false;
        })
    }

    handleClear(){
        this.userQuestion = '';
        this.answer = '';
        this.errorMessage = '';
        this.hasQuestion = false;
        this.isLoading = false;
    }

      get isSubmitDisabled(){
        return this.isLoading || !this.fileUploaded || !this.hasQuestion
    }

     get hasAnswer(){
        return this.answer && this.answer.length > 0;
    }

    get hasError(){
        return this.errorMessage && this.errorMessage.length > 0;
    }

}