//both inputs and output structure.
public with sharing class LeadBooking {
    
    public class LeadRequest {
    @AuraEnabled
    public String country;
    @AuraEnabled
    public String firstName;
    @AuraEnabled
    public String lastName;
    @AuraEnabled
    public String email;
    @AuraEnabled
    public String phone;
    @AuraEnabled
    public String companyName;
    @AuraEnabled
    public String title;

    //constructor
    public LeadRequest() {}
    public LeadRequest(
      String country,
      String firstName,
      String lastName,
      String email,
      String phone,
      String companyName,
      String title
    ) {
      this.country = country;
      this.firstName = firstName;
      this.lastName = lastName;
      this.email = email;
      this.phone = phone;
      this.companyName = companyName;
      this.title = title;
    }
  }

   public class LeadDTO {
    @AuraEnabled
    public String leadId;
    @AuraEnabled
    public String country;
    @AuraEnabled
    public String firstName;
    @AuraEnabled
    public String lastName;
    @AuraEnabled
    public String email;
    @AuraEnabled
    public String phone;
    @AuraEnabled
    public String companyName;
    @AuraEnabled
    public String title;
    @AuraEnabled
    public String status;

    //constructor
    public LeadDTO() {}
    public LeadDTO(
      String leadId,
      String country,
      String firstName,
      String lastName,
      String email,
      String phone,
      String companyName,
      String title,
      String status
    ) {
      this.leadId = leadId;
      this.country = country;
      this.firstName = firstName;
      this.lastName = lastName;
      this.email = email;
      this.phone = phone;
      this.companyName = companyName;
      this.title = title;
      this.status = status;
    }
  }
}