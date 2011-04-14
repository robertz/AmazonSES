component hint = "The application" {
	this.name = "amazonSES";
 	this.applicationTimeout = createTimeSpan(1,0,0,0);
 	this.sessionTimeout = createTimeSpan(0,1,0,0);
 	this.clientManagement = true;
 	this.loginStorage = "session";
 	this.sessionManagement = true;
 	this.setClientCookies = true;
 	this.setDomainCookies = false;
 	this.scriptProtect = "all";

	public boolean function onApplicationStart() {
  		application.sesGateway = new com.kisdigital.amazonSES(expandPath('/') & "AwsCredentials.properties");
  		return true;
 	}
 
 	public boolean function onRequest(required String TargetPage) output="true" {
  		include arguments.TargetPage;
  		return true;
 	}
 
 	public boolean function onRequestStart(required String thePage) output="false" {
  		if(structKeyExists(url, 'flush')) onApplicationStart();
  		return true;
 	}
 
}