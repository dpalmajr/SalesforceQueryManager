SalesforceQueryManager
======================

Salesforce currently supports a few tools to interact with their API. This tool attempts to interact with the Salesforce API through their iOS SDK.

Before you can use this app, you'll have to create a set of credentials in the Salesforce development environment (https://login.salesforce.com.).

Once complete you'll be able to login and begin using the app.

On the home screen you'll notice two areas for input: 

-	Query - Use this text area to type native SOQL queries. For example, to return the list of Names from the Person object your query would look like this: select Names from Person.
-	Object - Use this text area to query object meta data. Be sure to include the native api name for the object you'd like to query.
