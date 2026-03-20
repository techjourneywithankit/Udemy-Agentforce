public with sharing class BookLeadAction {


    public class RequestWrapper {
        @InvocableVariable(required=true)
        public LeadBooking.LeadRequest request;
    }

    public class ResponseWrapper {
        @InvocableVariable
        public LeadBooking.LeadDTO result;
        //constructor
        public ResponseWrapper(LeadBooking.LeadDTO result) {
            this.result = result;
        }
    }

     @InvocableMethod(
       label='Book Lead'
       description='Books a lead and returns a confirmation DTO.'
    )
    public static List<ResponseWrapper> book(List<RequestWrapper> inputs){
        List<ResponseWrapper> outputs = new List<ResponseWrapper>();
        for(RequestWrapper wrapper : inputs){
            LeadBooking.LeadRequest req = wrapper.request;
            //business logic to create lead and return DTO
            String leadId = generateLeadId();

            //get the output ready
             LeadBooking.LeadDTO dto = new LeadBooking.LeadDTO(
                leadId,
                req.country,
                req.firstName,
                req.lastName,
                req.email,
                req.phone,
                req.companyName,
                req.title,
                'SUBMITTED'
            );
            outputs.add(new ResponseWrapper(dto));

        }
        return outputs;
    }

    private static String generateLeadId() {
        String randRaw = String.valueOf(Math.abs(Crypto.getRandomInteger()));
        String randPart = (randRaw.length() >= 8)
        ? randRaw.left(8)
        : (String.valueOf('00000000' + randRaw)).right(8);
        return 'LEAD-' + randPart;
   }
}