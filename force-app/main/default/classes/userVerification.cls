public without sharing class userVerification {
    public class VerificationException extends Exception {}

    @InvocableMethod(
        Label='Send Email With Verification Code'
        Description='Finds the user by email, or username  and emails them a one-time verification code.'
        Category='Agentforce'
    )
    public static List<Response> invoke(List<String> emailsOrUserids) {
        Response r = new Response();
        r.userFound = false;
        String input = (emailsOrUserids != null && !emailsOrUserids.isEmpty())
            ? emailsOrUserids[0] : null;

        if (String.isBlank(input)) {
            r.message = 'Please provide a valid email or userid.';
            return new List<Response>{ r };
        }
        input = input.trim();

        List<User> users = [
            SELECT Id, Email, Name FROM User
            WHERE (Email = :input OR Username = :input) AND IsActive = true
            LIMIT 1
        ];

        if (users.isEmpty()) {
            r.message = 'Please provide a valid email or userid.';
            return new List<Response>{ r };
        }

        User u = users[0];
        String code = String.valueOf(Math.mod(Math.abs(Crypto.getRandomInteger()), 900000) + 100000);

        Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
        msg.setTargetObjectId(u.Id);
        msg.setSaveAsActivity(false);
        msg.setSubject('Your verification code');
        msg.setPlainTextBody('Your one-time verification code is: ' + code);
        try {
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ msg });
        } catch (Exception e) {
            throw new VerificationException('Could not send the verification email: ' + e.getMessage());
        }

        r.userFound = true;
        r.customerId = u.Id;
        r.authenticationKey = code;
        r.message = 'Please check your email and type the one time password.';
        return new List<Response>{ r };
    }

    public class Response {
        @InvocableVariable(Label='Message' Description='Status message for the agent to speak back')
        public String message;
        @InvocableVariable(Label='User Found' Description='True when a matching user was found and the code was sent')
        public Boolean userFound;
        @InvocableVariable(Label='Customer Id' Description='Salesforce User Id of the matched user')
        public String customerId;
         @InvocableVariable(Label='Authentication Key' Description='The verification code that was emailed; the agent stores this to validate later')
        public String authenticationKey;
    }
}