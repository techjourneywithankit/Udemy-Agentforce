import { close, execute, open } from 'lightning/accApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getFieldValue, getRecord } from 'lightning/uiRecordApi';
import { LightningElement, api, wire } from 'lwc';
import CASE_NUMBER_FIELD from '@salesforce/schema/Case.CaseNumber';
import DESCRIPTION_FIELD from '@salesforce/schema/Case.Description';
import SUBJECT_FIELD from '@salesforce/schema/Case.Subject';

const CASE_FIELDS = [CASE_NUMBER_FIELD, SUBJECT_FIELD, DESCRIPTION_FIELD];
const ERROR_TITLE = 'The Agentforce panel could not complete that request.';

/**
 * Opens the native Agentforce side panel and asks CasePriorityRecommender
 * for a priority using the Case already on screen. execute() does not return
 * the agent's reply; that reply is shown in the panel.
 */
export default class CasePriorityLauncher extends LightningElement {
    @api recordId;

    caseRecord;
    isBusy = false;
    isError = false;
    statusMessage = '';

    _botId = '';
    wireError;

    @api
    get botId() {
        return this._botId;
    }

    set botId(value) {
        this._botId = typeof value === 'string' ? value : '';
    }

    @wire(getRecord, { recordId: '$recordId', fields: CASE_FIELDS })
    wiredCase({ data, error }) {
        if (data) {
            this.caseRecord = data;
            this.wireError = undefined;
            return;
        }
        this.caseRecord = undefined;
        this.wireError = error;
    }

    get liveMode() {
        return this.isError ? 'assertive' : 'polite';
    }

    get statusRole() {
        return this.isError ? 'alert' : 'status';
    }

    get hasStatus() {
        return this.statusMessage.length > 0;
    }

    handleBotIdChange(event) {
        this._botId = event.detail.value || '';
    }

    async handleRecommend() {
        if (!this.recordId) {
            this.showGuidance('Open a Case record to recommend a priority.');
            return;
        }
        if (!this.caseRecord && !this.wireError) {
            this.showGuidance('Case details are still loading.');
            return;
        }
        if (this.wireError) {
            this.showFailure(this.wireError);
            return;
        }
        const subject = this.fieldValue(SUBJECT_FIELD);
        if (!subject) {
            this.showGuidance('This Case needs a subject before a priority can be recommended.');
            return;
        }
        const botId = this.normalizedBotId;
        if (!botId) {
            this.showGuidance('Enter the Agentforce bot Id before using the panel.');
            return;
        }

        const description = this.fieldValue(DESCRIPTION_FIELD) || 'No description was provided.';
        const caseNumber = this.fieldValue(CASE_NUMBER_FIELD);
        const utterance =
            `The case number is "${caseNumber}". The case subject is "${subject}". ` +
            `The case description is "${description}". Recommend a priority.`;

        await this.runPanelAction(async () => {
            await open(botId);
            await execute(utterance, botId);
            this.statusMessage =
                'Sent this Case to CasePriorityRecommender. The recommendation appears in the panel.';
        });
    }

    async handleOpen() {
        const botId = this.normalizedBotId;
        if (!botId) {
            this.showGuidance('Enter the Agentforce bot Id before using the panel.');
            return;
        }
        await this.runPanelAction(async () => {
            await open(botId);
            this.statusMessage = 'Opened the Agentforce panel.';
        });
    }

    async handleClose() {
        await this.runPanelAction(async () => {
            await close();
            this.statusMessage = 'Closed the Agentforce panel.';
        });
    }

    get normalizedBotId() {
        return this._botId.trim();
    }

    fieldValue(field) {
        return (getFieldValue(this.caseRecord, field) || '').trim();
    }

    async runPanelAction(work) {
        if (this.isBusy) {
            return;
        }
        this.isBusy = true;
        this.isError = false;
        this.statusMessage = 'Working with the Agentforce panel.';
        try {
            await work();
            this.isError = false;
        } catch (error) {
            this.showFailure(error);
        } finally {
            this.isBusy = false;
        }
    }

    showGuidance(message) {
        this.isError = true;
        this.statusMessage = message;
    }

    showFailure(error) {
        const message = reduceError(error);
        this.isError = true;
        this.statusMessage = message;
        this.dispatchEvent(
            new ShowToastEvent({
                title: ERROR_TITLE,
                message,
                variant: 'error'
            })
        );
    }
}

function reduceError(error) {
    if (Array.isArray(error?.body)) {
        return error.body
            .map((entry) => entry.message)
            .filter(Boolean)
            .join(', ');
    }
    if (typeof error?.body?.message === 'string') {
        return error.body.message;
    }
    if (typeof error?.message === 'string') {
        return error.message;
    }
    return ERROR_TITLE;
}
