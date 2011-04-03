<cfscript>

 amazonCredentialsFile = expandPath("/") & "awsCredentials.properties"; //This needs to be the ABSOLUTE PATH to your credentials file
 sesGateway = new com.kisdigital.amazonSES(amazonCredentialsFile);
 sesGateway.setEndPoint("https://email.us-east-1.amazonaws.com"); //This is the default gateway server
 
 writeDump(var = sesGateway, label="sesGateway object", expand = false);
 writeDump(var = sesGateway.listVerifiedEmailAddresses(), label="Verified Senders");
 writeDump(var = sesGateway.getSendQuota(), label = "Send Quota");
 //sesGateway.sendEMail(from="some@dude.com", recipient="another@dude.com,more@dude.com", subject="Testing the gateway", messageBody="This is just a test");

</cfscript>
