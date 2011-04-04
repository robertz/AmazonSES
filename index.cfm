<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
 <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
 <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.4.3/jquery.min.js"></script>
 <title>AmazonSES Test Page</title> 
 <style>
  BODY {
   font-family: arial;
   font-size: 12px;
  }
  .hidden {
   display: none;
  }
  td.emailLabel {
   text-align: right;
   font-weight: bold;
   padding-right: 8px;
   height: 30px;
  }
  #mailQuota {
   border: 1px solid black; 
   line-height: 24px; 
   font-weight: bold;
   padding: 4px;
   margin-bottom: 8px;
  }
  #apiStatusReport {
   border: 1px solid black; 
   font-weight: bold;
   padding: 4px;
   margin-bottom: 8px;
  }
  .apiSuccess {
   background-color: #CCCCFF;
  }
  .apiFail {
   background-color: #F00;
  }
  #mainForm {
   border: 1px solid black; 
   padding: 4px;
   margin-bottom: 8px;
   background-color: #e6e2d4;
  }
  #navSections {
   border: 1px solid black;
   padding: 4px;
   margin-bottom: 8px;
  }
  .navButton {
   width: 125px;
   align: center;
  }
 </style>
</head>

<body>
 <cfscript>
  sesGateway = new com.kisdigital.amazonSES(expandPath('/') & "AwsCredentials.properties");
  if(structKeyExists(form, 'cmd')){
   if(!structKeyExists(form, "from")) form['from'] = "";
   if(form.cmd eq 1){
    apiResult = sesGateway.sendEmail(from=form.from, recipient=form.to, cc=form.cc, bcc=form.bcc, replyTo=form.replyTo, subject=form.subject, messageBody=form.messageBody);
    apiClass = (apiResult.apiStatus eq 0 ? "apiSuccess" : "apiFail");
   }
   else if(form.cmd eq 2){
    apiResult = sesGateway.deleteVerifiedEmailAddress(form.deleteEmail);
    apiClass = (apiResult.apiStatus eq 0 ? "apiSuccess" : "apiFail");
   }
   else if(form.cmd eq 3){
    apiResult = sesGateway.verifyEmailAddress(form.addEmail);
    apiClass = (apiResult.apiStatus eq 0 ? "apiSuccess" : "apiFail");
   } 
  }
  else{
    form['from'] = "";
    form['to'] = "";
    form['cc'] = "";
    form['bcc'] = "";
    form['subject'] = "";
    form['messageBody'] = "";
    form['replyTo'] = "";
    form['deleteEmail'] = "";
    form['addEmail'] = "";
  }
  //sesGateway.setEndPoint("https://email.us-east-1.amazonaws.com");
 
  //writeDump(var = sesGateway, label="sesGateway object");
  //writeDump(var = sesGateway.listVerifiedEmailAddresses(), label="Verified Senders");
  //writeDump(var = sesGateway.getSendQuota(), label = "Send Quota");
  //writeDump(var = sesGateway.getSendStatistics(), label = "Send Statistics");  
  verifiedSenders = sesGateway.listVerifiedEmailAddresses();
  vList = verifiedSenders.verifiedList;
  sendQuota = sesGateway.getSendQuota();
 </cfscript>
 
<cfoutput>
 <div style="width: 800px;">
  <div id="mailQuota">
   You have sent #sendQuota.getSentLast24Hours# of 
   #sendQuota.max24HourSend# messages in the last 24 hours. 
   #sendQuota.max24HourSend - sendQuota.getSentLast24Hours# 
   messages remain. Max send rate is #sendQuota.getMaxSendRate#.
  </div>
  <cfif structKeyExists(variables, "apiResult")>
    <div id="apiStatusReport" class="#apiClass#">
    <table cellpadding="0" cellspacing="0" border="0" style="width: 100%;">
     <tr>
      <td valign="middle" style="width: 84px;"><strong>API Status:</strong></td>
      <td<cfif apiResult.apiStatus neq 0> style="color: yellow;"</cfif>>#apiResult.apiMessage#</td>
     </tr>
    </table>
   </div>
  </cfif>
  <div id="navSections" align="center">
   <input type="button" class="navButton" onclick="document.location='#CGI.SCRIPT_NAME#';" value="Reset">
   <input type="button" class="navButton" onclick="showDiv('formMessageContainer');" value="Emailer">
   <input type="button" class="navButton" onclick="showDiv('formManageEmails');" value="Manage Senders">
  </div>
  <div id="mainForm">
   <form id="message" method="post">
    <input type="hidden" id="cmd" name="cmd" value="0" />
    <input type="hidden" id="deleteEmail" name="deleteEmail" value="" />
    <div id="formMessageContainer">
     <table cellpadding="0" cellspacing="0" border="0" style="width: 100%;">
      <tr>
       <td class="emailLabel" valign="middle">From</td>
       <td valign="middle">
        <cfif arrayLen(vList)>
         <select id="from" name="from">
          <cfloop from="1" to="#arrayLen(vList)#" index="n">
           <option value="#vList[n]#">#vList[n]#</option>
          </cfloop>
         </select>
        <cfelse>
         <input type="text" name="from" value="#form.from#" style="width: 60%;">
        </cfif>
       </td>
      </tr>
      <tr>
       <td class="emailLabel" valign="middle">To</td>
       <td valign="middle"><input type="text" name="to" value="#form.to#" style="width: 60%;"></td>
      </tr>
      <tr>
       <td class="emailLabel" valign="middle">Reply-To</td>
       <td valign="middle"><input type="text" name="replyTo" value="#form.replyTo#" style="width: 60%;"></td>
      </tr>
      <tr>
       <td class="emailLabel" valign="middle">CC</td>
       <td valign="middle"><input type="text" name="cc" value="#form.cc#" style="width: 60%;"></td>
      </tr>
      <tr>
       <td class="emailLabel" valign="middle">BCC</td>
       <td valign="middle"><input type="text" name="bcc" value="#form.bcc#" style="width: 60%;"></td>
      </tr>
      <tr>
       <td class="emailLabel" valign="middle">Subject</td>
       <td valign="middle"><input type="text" name="subject" value="#form.subject#" style="width: 94%;"></td>
      </tr>
      <tr>
       <td colspan="2">
        <textarea name="messageBody" rows="10" style="width: 95%;">#form.messageBody#</textarea>
       </td>
      </tr>
     </table>
     <br />
     <input type="button" id="sendEmail" value="Send Email" />
    </div>
    
    <div id="formManageEmails" class="hidden">
     <table cellpadding="0" cellspacing="0" style="width: 100%;">
      <cfloop from="1" to="#arrayLen(verifiedSenders.verifiedList)#" index="n">
       <tr>
        <td style="width: 175px; height: 24px;"><input type="button" onclick="removeSender('#verifiedSenders.verifiedList[n]#');" value="Remove Address" /></td>
        <td valign="center">#verifiedSenders.verifiedList[n]#</td>
       </tr>
      </cfloop>
     </table>
     <br /><br />
     <table cellpadding="0" cellspacing="0" style="width: 100%;">
       <tr>
        <td style="width: 100px; height: 24px; padding-right: 8px;" align="right"><strong>Add Email</strong></td>
        <td valign="center">
         <input type="text" id="addEmail" name="addEmail" style="width: 350px;" />
         <input type="button" onclick="addSender();" value="Send Verification">
        </td>
       </tr>
     </table>    
    </div>
    
    
   </form>
  </div>
  <br /><br />
 </div>
</cfoutput>
 <script type="text/javascript">
  $(document).ready(function(){
   $('#from').val('<cfoutput>#form.from#</cfoutput>');
  });
  $('#sendEmail').click(function(){
   $('#cmd').val("1");
   $('#message').submit();
  });
  function showDiv(targetDiv){
   $('[id^=form]').hide();
   $('#' + targetDiv).show();
  }
  function removeSender(email){
   $('#cmd').val("2");
   $('#deleteEmail').val(email);
   $('#message').submit();
  }
  function addSender(){
   $('#cmd').val("3");
   $('#message').submit();
  }
 </script>
</body>
</html>