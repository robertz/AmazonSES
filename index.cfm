<cfscript>
 application.amazonCreds = "/path/to/AwsCredentials.properties";
 sesGateway = new com.kisdigital.amazonSES().init(application.amazonCreds);
 sesGateway.setEndPoint("https://email.us-east-1.amazonaws.com");
 
 writeDump(var = sesGateway, label="sesGateway object");
 writeDump(var = sesGateway.listVerifiedEmailAddresses(), label="Verified Senders");
 writeDump(var = sesGateway.getSendQuota(), label = "Send Quota");
 writeDump(var = sesGateway.getSendStatistics(), label = "Send Statistics");
 //sesGateway.deleteVerifiedEmailAddress("some@dude.com");
 //sesGateway.sendEMail(from="robert.zehnder@usarmyphysicaltherapyalumni.com", recipient="robert.zehnder@usarmyphysicaltherapyalumni.com,alumnimembership@usarmyphysicaltherapyalumni.com", subject="Testing the gateway", messageBody="This is just a test");

</cfscript>