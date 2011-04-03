component output = "false" hint = "I am a gateway to the Amazon Simple Email Service" {
 /*
 *  Copyright 2011 by Robert Zehnder
 *  This program is distributed under the terms of the GNU General Public License <http://www.gnu.org>
 * 
 *  AmazonSES Reference: http://docs.amazonwebservices.com/AWSJavaSDK/latest/javadoc/com/amazonaws/services/simpleemail/AmazonSimpleEmailService.html
 *  
 *  Version 0.1.0:
 *     Initial release
 *     Added function listVerifiedEmailAddresses
 *     Added function verifyEmailAddress
 *     Added function sendEmail
 *  Version 0.1.1
 *     Require the full path to the AwsCredentials.properties file on init
 *     Updated function comments to reflect javadoc descriptions <http://docs.amazonwebservices.com/AWSJavaSDK/latest/javadoc/index.html>
 *     Added function setEndPoint to override the default endpoint
 *     Added function getSendQuota to view your daily statistics
 *     Added function deleteVerifiedEmailAddress to delete the specified email address from the list of verified addresses
 */
 var instance = {};

 /*
 * Author: Robert Zehnder, Date: 03/31/2011, Purpose: Initialize our object
 * Modified: Robert Zehnder, Data: 04/01/2011, Purpose: Require passing credentials path when component is initialized
 */
 public any function init(required String pathToCredentials) hint = "I initialize the gateway" {
  instance['awsCredentials'] = createObject("java", "java.io.File").init(arguments.pathToCredentials);
  instance['credentials'] = createObject("java", "com.amazonaws.auth.PropertiesCredentials").init(instance.awsCredentials);
  instance['emailService'] = createObject("java", "com.amazonaws.services.simpleemail.AmazonSimpleEmailServiceClient").init(instance.credentials);
  instance['props'] = createObject("java", "java.util.Properties");  
  instance.props.setProperty("mail.transport.protocol", "aws");
  instance.props.setProperty("mail.aws.user", instance.credentials.getAWSAccessKeyId());
  instance.props.setProperty("mail.aws.password", instance.credentials.getAWSSecretKey());
  return this;
 }
 
 /*
 *  Author: Robert Zehnder, Date: 04/01/2011, Purpose: Overrides the default endpoint for this client ("https://email.us-east-1.amazonaws.com").
 */
 public void function setEndPoint(required String endPoint) hint = "Overrides the default endpoint" {
  var validateEndPoint = "";
  try{
   instance.emailService.setEndPoint(arguments.endPoint);
  }
  catch(any e){
   writeDump("Method setEndPoint: " & e.message);
  }
 }
  
 /*
 *  Author: Robert Zehnder, Date: 04/01/2011, Purpose: Returns the user's current activity limits.
 */
 public struct function getSendQuota() hint = "Returns your quota from from the SES service" {
  var result = {};
  try{
   result['max24HourSend'] = instance.emailService.getSendQuota().getMax24HourSend();
   result['getMaxSendRate'] = instance.emailService.getSendQuota().getMaxSendRate();
   result['getSentLast24Hours'] = instance.emailService.getSendQuota().getSentLast24Hours();
  }
  catch(any e){
   writeDump("Method getSendQuota: " & e.message);
  }
  return result;
 }
 
 /*
 *  Author: Robert Zehnder, Date: 04/01/2011, Purpose: Deletes the specified email address from the list of verified addresses.
 *  Modified: Robert Zehnder, Date: 04/02/2011, Purpose: Chained email address to the request constructor
 */
 public void function deleteVerifiedEmailAddress(required String email) hint = "Deletes the specified email address from the list of verified addresses." {
  var awsRequest = createObject("java", "com.amazonaws.services.simpleemail.model.DeleteVerifiedEmailAddressRequest").withEmailAddress(arguments.email);
  try{
   instance.emailService.deleteVerifiedEmailAddress(awsRequest);    
  }
  catch(any e){
   writeDump("Method deleteVerifiedEmailAddress: " & e.message);
  }
 }
 
 /*
 *  Author: Robert Zehnder, Date: 03/31/2011, Purpose: Returns a list containing all of the email addresses that have been verified. <ArrayList>
 */
 public array function listVerifiedEmailAddresses() hint = "Returns a list containing all of the email addresses that have been verified." {
  return instance.emailService.ListVerifiedEmailAddresses().getVerifiedEmailAddresses();
 }

 /*
 *  Author: Robert Zehnder, Date: 03/31/2011, Purpose: Verifies an email address.
 *  Modified: Robert Zehnder, Date: 04/01/2011, Purpose: Wrapped in try/catch block to catch any errors
 */
 public void function verifyEmailAddress(required String email) hint = "Verifies an email address." {
  var verifyRequest = createObject("java", "com.amazonaws.services.simpleemail.model.VerifyEmailAddressRequest").withEmailAddress(arguments.email);
  try{
   instance.emailService.verifyEmailAddress(verifyRequest);
  }
  catch (any e){
   writeDump("Method verifyEmailAddress: " & e.message);
  }
 }

 /*
 *  Author: Robert Zehnder, Date: 03/31/2011, Purpose: Composes an email message based on input data, and then immediately queues the message for sending.
 *  Modified: Robert Zehnder, Date: 04/01/2011, Purpose: Corrected name to match javadoc. Allow sending recipients, cc, and bcc fields as a csv list
 */
 public void function sendEMail(required String from, required String recipient, required String subject, required String messageBody, String cc = "", String bcc = "") hint = "Composes an email message based on input data, and then immediately queues the message for sending." {
  var mailSession = createObject("java", "javax.mail.Session").getInstance(instance.props);
  var mailTransport = createObject("java", "com.amazonaws.services.simpleemail.AWSJavaMailTransport").init(mailSession, JavaCast("null", 0));
  var messageObj = createObject("java", "javax.mail.internet.MimeMessage").init(mailSession);
  var messageRecipientType = createObject("java", "javax.mail.Message$RecipientType");
  var messageFrom = createObject("java", "javax.mail.internet.InternetAddress").init(arguments.from);
  var messageTo = listToArray(arguments.recipient);
  var messageCC = listToArray(arguments.cc);
  var messageBCC = listToArray(arguments.bcc);
  var messageSubject = arguments.subject;
  var messageBody = arguments.messageBody;
  var verified = arrayToList(listVerifiedEmailAddresses()).contains(arguments.from);
  var i = 0;
  
  try {
   if(!verified){
    verifyEmailAddress(arguments.from);
    throw("Email address has not been validated.  Please check the email on account " & arguments.from & " to complete validation.");
   }
   mailTransport.connect();

   messageObj.setFrom(messageFrom);
   for(i = 1; i <= arrayLen(messageTo); i++){
    messageObj.addRecipient(messageRecipientType.TO, createObject("java", "javax.mail.internet.InternetAddress").init(trim(messageTo[i])));
   }
   if(arrayLen(messageCC)){
    for(i = 1; i <= arrayLen(messageCC); i++){
     messageObj.addRecipient(messageRecipientType.CC, createObject("java", "javax.mail.internet.InternetAddress").init(trim(messageCC[i])));
    }
   }
   if(arrayLen(messageBCC)){
    for(i = 1; i <= arrayLen(messageBCC); i++){
     messageObj.addRecipient(messageRecipientType.BCC, createObject("java", "javax.mail.internet.InternetAddress").init(trim(messageBCC[i])));
    }
   }
   messageObj.setSubject(messageSubject);
   messageObj.setContent(messageBody, "text/html");
   messageObj.saveChanges();

   mailTransport.sendMessage(messageObj, JavaCast("null", 0));

   mailTransport.close();
  }
  catch (Any e){
    writeDump("Method sendEMail: " & e.Message);
  }
 }
}
