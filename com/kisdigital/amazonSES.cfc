component output = "false" hint = "I am a gateway to the Amazon Simple Email Service" {
 /*
 *  Copyright 2011 by Robert Zehnder
 *  This program is distributed under the terms of the GNU General Public License <http://www.gnu.org>
 * 
 *  AmazonSES Reference: http://docs.amazonwebservices.com/AWSJavaSDK/latest/javadoc/com/amazonaws/services/simpleemail/AmazonSimpleEmailService.html
 *  
 *  Version 0.1.3
 *     Set Reply-To in the message header if specified
 *  Version 0.1.2
 *     Modified functions to return structs to make it easier to include status and error messages in responses
 *     Added function getSendStatistics
 *  Version 0.1.1
 *     Require the full path to the AwsCredentials.properties file on init
 *     Updated function comments to reflect javadoc descriptions <http://docs.amazonwebservices.com/AWSJavaSDK/latest/javadoc/index.html>
 *     Added function setEndPoint to override the default endpoint
 *     Added function getSendQuota to view your daily statistics
 *     Added function deleteVerifiedEmailAddress to delete the specified email address from the list of verified addresses
 *  Version 0.1.0:
 *     Initial release
 *     Added function listVerifiedEmailAddresses
 *     Added function verifyEmailAddress
 *     Added function sendEmail
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
 *  Modified: Robert Zehnder, Date: 04/02/2011, Purpose: Return a struct with the api status instead of void
 */
 public struct function setEndPoint(required String endPoint) hint = "Overrides the default endpoint" {
  var result = {'apiStatus':'0','apiMessage':'SUCCESS'};
  try{
   instance.emailService.setEndPoint(arguments.endPoint);
  }
  catch(any e){
   result = {'apiStatus':'-1','apiMessage':'Method setEndPoint: '& e.message};
  }
  return result;
 }
  
 /*
 *  Author: Robert Zehnder, Date: 04/01/2011, Purpose: Returns the user's current activity limits.
 *  Modified: Robert Zehnder, Date: 04/02/2011, Purpose: Return a struct with the api status instead of void
 */
 public struct function getSendQuota() hint = "Returns your quota from from the SES service" {
  var result = {'apiStatus':'0','apiMessage':'SUCCESS'};
  result['max24HourSend'] = "";
  result['getMaxSendRate'] = "";
  result['getSentLast24Hours'] = "";
  try{
   result['max24HourSend'] = instance.emailService.getSendQuota().getMax24HourSend();
   result['getMaxSendRate'] = instance.emailService.getSendQuota().getMaxSendRate();
   result['getSentLast24Hours'] = instance.emailService.getSendQuota().getSentLast24Hours();
  }
  catch(any e){
   result['apiStatus'] = "-1";
   result['apiMessage'] = "Method getSendQuota: " & e.message;
  }
  return result;
 }

 /*
 *  Author: Robert Zehnder, Date: 04/02/2011, Purpose: Returns the user's sending statistics. The result is a list of data points, representing the last two weeks of sending activity.
 *  Modified: Robert Zehnder, Date: 04/02/2011, Purpose: Return a struct with the api status 
 */
 public struct function getSendStatistics() hint = "Returns the user's sending statistics. The result is a list of data points, representing the last two weeks of sending activity." {
  var result = {'apiStatus':'0','apiMessage':'SUCCESS'};
  var dataPoints = instance.emailService.GetSendStatistics().getSendDataPoints();
  var i = 0;
  var tempStruct = "";
  try{
   result['dataPoints'] = arrayNew(1);
   for(i = 1; i <= arrayLen(dataPoints); i++){
    tempStruct = {};
    tempStruct['TimeStamp'] = dataPoints[i].getTimeStamp().toString();
    tempStruct['DeliveryAttempts'] = dataPoints[i].getDeliveryAttempts().toString();
    tempStruct['Bounces'] = dataPoints[i].getBounces().toString();
    tempStruct['Complaints'] = dataPoints[i].getComplaints().toString();
    tempStruct['Rejects'] = dataPoints[i].getRejects().toString();
    arrayAppend(result.dataPoints, tempStruct);
   }
  }
  catch(any e){
    result = {'apiStatus':'-1','apiMessage':'Method getSendStatistics: '& e.message};
  }
  return result;
 }
 
 /*
 *  Author: Robert Zehnder, Date: 04/01/2011, Purpose: Deletes the specified email address from the list of verified addresses.
 *  Modified: Robert Zehnder, Date: 04/02/2011, Purpose: Chained email address to the request constructor, updated return with apiStatus
 */
 public struct function deleteVerifiedEmailAddress(required String email) hint = "Deletes the specified email address from the list of verified addresses." {
  var result = {'apiStatus':'0','apiMessage':'SUCCESS'};
  var awsRequest = createObject("java", "com.amazonaws.services.simpleemail.model.DeleteVerifiedEmailAddressRequest").withEmailAddress(arguments.email);
  try{
   instance.emailService.deleteVerifiedEmailAddress(awsRequest);    
  }
  catch(any e){
   result = {'apiStatus':'-1','apiMessage':'Method deleteVerifiedEmailAddress: '& e.message};
  }
  return result;
 }
 
 /*
 *  Author: Robert Zehnder, Date: 03/31/2011, Purpose: Returns a list containing all of the email addresses that have been verified. <ArrayList>
 *  Modified: Robert Zehnder, Date: 04/02/2011, Purpose: Return a struct with the api status
 */
 public struct function listVerifiedEmailAddresses() hint = "Returns a list containing all of the email addresses that have been verified." {
  var result = {'apiStatus':'0','apiMessage':'SUCCESS'};
  try{
   result['verifiedList'] = instance.emailService.ListVerifiedEmailAddresses().getVerifiedEmailAddresses();
  }
  catch(any e){
   result = {'apiStatus':'-1','apiMessage':'Method listVerifiedEmailAddress: '& e.message};
  }
  return result;
 }

 /*
 *  Author: Robert Zehnder, Date: 03/31/2011, Purpose: Verifies an email address.
 *  Modified: Robert Zehnder, Date: 04/01/2011, Purpose: Wrapped in try/catch block to catch any errors
 *  Modified: Robert Zehnder, Date: 04/02/2011, Purpose: Return a struct with the api status
 */
 public struct function verifyEmailAddress(required String email) hint = "Verifies an email address." {
  var result = {'apiStatus':'0','apiMessage':'SUCCESS'};
  var verifyRequest = createObject("java", "com.amazonaws.services.simpleemail.model.VerifyEmailAddressRequest").withEmailAddress(arguments.email);
  try{
   instance.emailService.verifyEmailAddress(verifyRequest);
  }
  catch (any e){
   result = {'apiStatus':'-1','apiMessage':'Method verifyEmailAddress: '& e.message};
  }
 }

 /*
 *  Author: Robert Zehnder, Date: 03/31/2011, Purpose: Composes an email message based on input data, and then immediately queues the message for sending.
 *  Modified: Robert Zehnder, Date: 04/01/2011, Purpose: Corrected name to match javadoc. Allow sending recipients, cc, and bcc fields as a csv list
 *  Modified: Robert Zehnder, Date: 04/03/2011, Purpose: Set Reply-To header, if specified
 */
 public struct function sendEMail(required String from, required String recipient, required String subject, required String messageBody, String cc = "", String bcc = "", String replyTo = "") hint = "Composes an email message based on input data, and then immediately queues the message for sending." {
  var result = {'apiStatus':'0','apiMessage':'SUCCESS'};
  var mailSession = createObject("java", "javax.mail.Session").getInstance(instance.props);
  var mailTransport = createObject("java", "com.amazonaws.services.simpleemail.AWSJavaMailTransport").init(mailSession, JavaCast("null", 0));
  var messageObj = createObject("java", "javax.mail.internet.MimeMessage").init(mailSession);
  var messageRecipientType = createObject("java", "javax.mail.Message$RecipientType");
  var messageFrom = createObject("java", "javax.mail.internet.InternetAddress").init(arguments.from);
  var messageTo = listToArray(arguments.recipient);
  var messageCC = listToArray(arguments.cc);
  var messageBCC = listToArray(arguments.bcc);
  var messageReplyTo = createObject("java", "javax.mail.internet.InternetAddress").init(arguments.replyTo);
  var messageSubject = arguments.subject;
  var messageBody = arguments.messageBody;
  var verified = arrayToList(listVerifiedEmailAddresses().verifiedList).contains(arguments.from);
  var i = 0;
  
  try {
   if(!verified){
    verifyEmailAddress(arguments.from);
    throw("Email address has not been validated.  Please check the email on account " & arguments.from & " to complete validation.");
   }
   if(len(arguments.replyTo)){
    messageObj.addHeader("Reply-To", messageReplyTo.toString());
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
    result = {'apiStatus':'-1','apiMessage':'Method sendEMail: '& e.message};
  }
  return result;
 }
}