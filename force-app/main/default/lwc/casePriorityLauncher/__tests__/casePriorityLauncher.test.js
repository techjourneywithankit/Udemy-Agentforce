import { createElement } from '@lwc/engine-dom';
import { getRecord } from 'lightning/uiRecordApi';
import CasePriorityLauncher from 'c/casePriorityLauncher';
import { close, execute, open } from 'lightning/accApi';

const BOT_ID = '0Xx000000000001AAA';
const SUBJECT = 'Cannot access billing portal';
const DESCRIPTION = 'Customer locked out after password reset, finance close is today.';
const CASE_NUMBER = '00001042';

jest.mock(
    'lightning/accApi',
    () => ({
        open: jest.fn(() => Promise.resolve()),
        close: jest.fn(() => Promise.resolve()),
        execute: jest.fn(() => Promise.resolve())
    }),
    { virtual: true }
);

function flushPromises() {
    return new Promise((resolve) => {
        setTimeout(resolve, 0);
    });
}

function utterance(caseNumber, subject, description) {
    return (
        `The case number is "${caseNumber}". The case subject is "${subject}". ` +
        `The case description is "${description}". Recommend a priority.`
    );
}

function createComponent({ recordId = '500000000000001AAA', botId = BOT_ID } = {}) {
    const element = createElement('c-case-priority-launcher', {
        is: CasePriorityLauncher
    });
    element.recordId = recordId;
    element.botId = botId;
    document.body.appendChild(element);
    return element;
}

function emitCase({ subject = SUBJECT, description = DESCRIPTION, caseNumber = CASE_NUMBER } = {}) {
    getRecord.emit({
        apiName: 'Case',
        fields: {
            Subject: { value: subject },
            Description: { value: description },
            CaseNumber: { value: caseNumber }
        }
    });
}

function button(element, action) {
    return element.shadowRoot.querySelector(`[data-action="${action}"]`);
}

function statusText(element) {
    return element.shadowRoot.querySelector('[data-id="status"]')?.textContent;
}

describe('c-case-priority-launcher', () => {
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        jest.clearAllMocks();
    });

    it('renders the panel actions', () => {
        const element = createComponent();

        expect(button(element, 'recommend').label).toBe('Recommend priority');
        expect(button(element, 'open').label).toBe('Open panel');
        expect(button(element, 'close').label).toBe('Close');
    });

    it('sends the current Case to the selected agent', async () => {
        const element = createComponent();
        emitCase();
        await flushPromises();

        button(element, 'recommend').click();
        await flushPromises();

        expect(open).toHaveBeenCalledWith(BOT_ID);
        expect(execute).toHaveBeenCalledWith(utterance(CASE_NUMBER, SUBJECT, DESCRIPTION), BOT_ID);
        expect(open.mock.invocationCallOrder[0]).toBeLessThan(execute.mock.invocationCallOrder[0]);
        expect(statusText(element)).toBe(
            'Sent this Case to CasePriorityRecommender. The recommendation appears in the panel.'
        );
    });

    it('tells the agent when the Case has no description', async () => {
        const element = createComponent();
        emitCase({ description: '   ' });
        await flushPromises();

        button(element, 'recommend').click();
        await flushPromises();

        expect(execute).toHaveBeenCalledWith(
            utterance(CASE_NUMBER, SUBJECT, 'No description was provided.'),
            BOT_ID
        );
    });

    it('asks for an agent Id before opening or recommending', async () => {
        const element = createComponent();
        element.botId = '   ';
        emitCase();
        await flushPromises();

        button(element, 'recommend').click();
        await flushPromises();

        expect(statusText(element)).toBe('Enter the Agentforce bot Id before using the panel.');
        expect(execute).not.toHaveBeenCalled();

        button(element, 'open').click();
        await flushPromises();

        expect(open).not.toHaveBeenCalled();
        expect(statusText(element)).toBe('Enter the Agentforce bot Id before using the panel.');
    });

    it('asks for a subject before recommending', async () => {
        const element = createComponent();
        emitCase({ subject: '' });
        await flushPromises();

        button(element, 'recommend').click();
        await flushPromises();

        expect(statusText(element)).toBe('This Case needs a subject before a priority can be recommended.');
        expect(execute).not.toHaveBeenCalled();
    });

    it('asks for a Case when the page has no record', async () => {
        const element = createComponent({ recordId: null });

        button(element, 'recommend').click();
        await flushPromises();

        expect(statusText(element)).toBe('Open a Case record to recommend a priority.');
        expect(execute).not.toHaveBeenCalled();
    });

    it('opens and closes the panel', async () => {
        const element = createComponent();

        button(element, 'open').click();
        await flushPromises();
        expect(open).toHaveBeenCalledWith(BOT_ID);
        expect(statusText(element)).toBe('Opened the Agentforce panel.');

        button(element, 'close').click();
        await flushPromises();
        expect(close).toHaveBeenCalledTimes(1);
        expect(statusText(element)).toBe('Closed the Agentforce panel.');
    });

    it('ignores a second click while a panel request is still running', async () => {
        let finishOpen;
        open.mockImplementation(
            () =>
                new Promise((resolve) => {
                    finishOpen = resolve;
                })
        );
        const element = createComponent();

        button(element, 'open').click();
        button(element, 'open').click();

        expect(open).toHaveBeenCalledTimes(1);
        finishOpen();
        await flushPromises();
        expect(statusText(element)).toBe('Opened the Agentforce panel.');
    });

    it('reports a panel failure', async () => {
        open.mockRejectedValue(new Error('Panel unavailable'));
        const element = createComponent();
        const handler = jest.fn();
        element.addEventListener('lightning__showtoast', handler);

        button(element, 'open').click();
        await flushPromises();

        expect(statusText(element)).toBe('Panel unavailable');
        expect(handler).toHaveBeenCalled();
        expect(element.shadowRoot.querySelector('[data-id="status"]').getAttribute('role')).toBe('alert');
    });
});
