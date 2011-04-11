component output = "false" hint = "I am a gateway to the Amazon Simple Email Service" {
 /*
 *  Copyright 2011 by Robert Zehnder
 *  This program is distributed under the terms of the GNU General Public License <http://www.gnu.org>
 * 
 *  AmazonSES Reference: http://docs.amazonwebservices.com/AWSJavaSDK/latest/javadoc/com/amazonaws/services/simpleemail/AmazonSimpleEmailService.html
 *  
 *  Version 0.1.5
 *     Moving to application scoped component for persistance of settings
 *     Each method now initiates a new email service connection when called
 *  Version 0.1.4
 *     Added sendSingle flag to sendEMail for sending recipients individually
 *     Modified sendEMail to fix hard errors when arguments are present but have no length
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
 **/
 var instance = {};

 public any function init(required String pathToCredentials) hint = "I initialize the gateway" {
  instance['awsCredentials'] = createObject("java", "java.io.File").init(arguments.pathToCredentials);
  instance['credentials'] = createObject("java", "com.amazonaws.auth.PropertiesCredentials").init(instance.awsCredentials);
  instance['props'] = createObject("java", "java.util.Properties");  
  instance.props.setProperty("mail.transport.protocol", "aws");
  instance.props.setProperty("mail.aws.user", instance.credentials.getAWSAccessKeyId());
  instance.props.setProperty("mail.aws.password", instance.credentials.getAWSSecretKey());
  instance['supportedHeaders'] = listToArray("Accept-Language,Bcc,Cc,Comments,Comment-Type,Content-Transfer-Encoding,Content-ID,Content-Description,Content-Disposition,Content-Language,Date,DKIM-Signature,DomainKey-Signature,From,In-Reply-To,Keywords,List-Archive,List-Help,List-Id,List-Owner,List-Post,List-Subscribe,List-Unsubscribe,Message-Id,MIME-Version,Received,References,Reply-To,Return-Path,Sender,Subject,Thread-Index,Thread-Topic,To,User-Agent");
  instance['endPoint'] = "";
  return this;
 }
 
 private boolean function initRequest() {
  instance['emailService'] = createObject("java", "com.amazonaws.services.simpleemail.AmazonSimpleEmailServiceClient").init(instance.credentials);
  if(len(instance.endPoint)) setEndPoint(instance.endPoint);
  return true; 
 }
 
 public struct function deleteVerifiedEmailAddress(required String email) hint = "Deletes the specified email address from the list of verified addresses." {
  var setRequest = initRequest();
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
  
 public struct function getSendQuota() hint = "Returns your quota from from the SES service" {
  var setRequest = initRequest();
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

 public struct function getSendStatistics() hint = "Returns the user's sending statistics. The result is a list of data points, representing the last two weeks of sending activity." {
  var setRequest = initRequest();
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
 
 public array function getSupportedHeaders() {
  return duplicate(instance.supportedHeaders);
 }
 
 public struct function listVerifiedEmailAddresses() hint = "Returns a list containing all of the email addresses that have been verified." {
  var setRequest = initRequest();
  var result = {'apiStatus':'0','apiMessage':'SUCCESS'};
  try{
   result['verifiedList'] = instance.emailService.ListVerifiedEmailAddresses().getVerifiedEmailAddresses();
  }
  catch(any e){
   result = {'apiStatus':'-1','apiMessage':'Method listVerifiedEmailAddress: '& e.message};
  }
  return result;
 }

 public struct function sendEMail(required String from, required String recipient, required String subject, required String messageBody, String cc = "", String bcc = "", String replyTo = "", Boolean sendSingle = false) hint = "Composes an email message based on input data, and then immediately queues the message for sending." {
  var setRequest = initRequest();
  var result = {'apiStatus':'0','apiMessage':'SUCCESS'};
  var mailSession = createObject("java", "javax.mail.Session").getInstance(instance.props);
  var mailTransport = createObject("java", "com.amazonaws.services.simpleemail.AWSJavaMailTransport").init(mailSession, JavaCast("null", 0));
  var messageObj = "";
  var messageFrom = "";
  var verified = "";  
  var messageRecipientType = createObject("java", "javax.mail.Message$RecipientType");
  var messageTo = listToArray(arguments.recipient);
  var messageCC = listToArray(arguments.cc);
  var messageBCC = listToArray(arguments.bcc);
  var messageReplyTo = arguments.replyTo;
  var messageSubject = arguments.subject;
  var messageBody = arguments.messageBody;
  var i = 0;
  var j = 0;
  var loopCnt = 1;
  
  try {
   messageFrom = createObject("java", "javax.mail.internet.InternetAddress").init(arguments.from);
   verified = arrayToList(listVerifiedEmailAddresses().verifiedList).contains(arguments.from);
   if(!verified){
    verifyEmailAddress(arguments.from);
    throw("Email address has not been validated.  Please check the email on account " & arguments.from & " to complete validation.");
   }
   
   mailTransport.connect();
   if(arguments.sendSingle) loopCnt = arrayLen(messageTo);
    
   for(j = 1; j <= loopCnt; j++){
    messageObj = createObject("java", "javax.mail.internet.MimeMessage").init(mailSession);
    messageObj.addHeader("User-Agent", "CFamazonSES");  
    if(len(trim(arguments.replyTo))){
     messageObj.addHeader("Reply-To", createObject("java", "javax.mail.internet.InternetAddress").init(messageReplyTo).toString());
    }   
   
    messageObj.setFrom(messageFrom);
    if(!arguments.sendSingle){ 
     for(i = 1; i <= arrayLen(messageTo); i++){
      messageObj.addRecipient(messageRecipientType.TO, createObject("java", "javax.mail.internet.InternetAddress").init(trim(messageTo[i])));
     }
    }
    else{
     messageObj.addRecipient(messageRecipientType.TO, createObject("java", "javax.mail.internet.InternetAddress").init(trim(messageTo[j]))); 
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
   }
   mailTransport.close();
  }
  catch (Any e){
    result = {'apiStatus':'-1','apiMessage':'Method sendEMail: '& e.message};
  }
  return result;
 }
 
 public struct function setEndPoint(required String endPoint) hint = "Overrides the default endpoint" {
  var setRequest = initRequest();
  var result = {'apiStatus':'0','apiMessage':'SUCCESS'};
  instance.endPoint = arguments.endPoint;
  return result;
 }
 
 public struct function verifyEmailAddress(required String email) hint = "Verifies an email address." {
  var setRequest = initRequest();
  var result = {'apiStatus':'0','apiMessage':'SUCCESS'};
  var verifyRequest = createObject("java", "com.amazonaws.services.simpleemail.model.VerifyEmailAddressRequest").withEmailAddress(arguments.email);
  try{
   instance.emailService.verifyEmailAddress(verifyRequest);
  }
  catch (any e){
   result = {'apiStatus':'-1','apiMessage':'Method verifyEmailAddress: '& e.message};
  }
  return result;
 }
}