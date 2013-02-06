/*
 Copyright (c) 2011, salesforce.com, inc. All rights reserved.
 
 Redistribution and use of this software in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright notice, this list of conditions
 and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of
 conditions and the following disclaimer in the documentation and/or other materials provided
 with the distribution.
 * Neither the name of salesforce.com, inc. nor the names of its contributors may be used to
 endorse or promote products derived from this software without specific prior written
 permission of salesforce.com, inc.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
 IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY
 WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */


#import "RootViewController.h"

#import "SFRestAPI.h"
#import "SFRestRequest.h"

@interface RootViewController()
- (void) selectTopRecords:(NSString *)selectClause from:(NSString *)fromClause where:(NSString *)whereClause;
- (void) issueRequestForObjectMetaData:(NSString *)objectName;
- (void) printFieldName:(NSDictionary *)dictionary;
- (void) printRecordIds:(NSArray *)dictionary;
- (void) issueQuery:(NSString *)incomingQuery;

@end


@implementation RootViewController

#pragma mark Misc

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)dealloc
{
    [super dealloc];
}


#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Mobile SDK Sample App";
    
    //Here we use a query that should work on either Force.com or Database.com
    /*SFRestRequest *request = [[SFRestAPI sharedInstance] requestForQuery:@"SELECT Name FROM User LIMIT 10"];
     
     [[SFRestAPI sharedInstance] send:request delegate:self];*/
//     [self selectTopRecords:@"Actual_Duration__c	, Id" from:@"Case" where:nil];
//    [self issueRequestForObjectMetaData:@"Case"];
    
    SFRestAPI *sharedInstance = [SFRestAPI sharedInstance];
    sharedInstance.apiVersion = @"v26.0";
/*
    NSString *query = @"Select Id, Name, parent_Incident__c, RecordTypeId FROM Incident__c  where RecordTypeId = '012S00000004YmBIAU'  LIMIT 100";
    
        NSString *recordTypequery = @"Select Id, Name FROM RecordType where Name LIKE 'In%' LIMIT 100";
    [self issueQuery:recordTypequery]; */
//    NSString *query = @"select Id, Employment_Website__c, Position__c from Job_Posting__c";
//    
//    NSString *positionQuery = @"select Id, Name from Position__c";
//    NSString *employement = @"select Id, Name from Employment_Website__c";
//    
//    NSString *nestedQuery = @"select Name,Status__c from Incident__c where Id IN (select Incident_Child__c from Incident_to_Incident_connector__c where Incident_Parent__c IN (Select Id from Incident__c where Id='a22S0000000CFgXIAW'))";
//    
//    NSString *subQuerr = @"select Incident_Child__c from Incident_to_Incident_connector__c where Incident_Parent__c IN (Select Id from Incident__c where Id='a22S0000000CFgXIAW')";
//    [self issueQuery:nestedQuery];
//    NSString *query = @"select Id, SM_Date_Time_Opened__c, Tech_Asset__c from Case where Tech_Asset__c IN (select Id from Tech_Asset__c where Id = 'a0Dd000000QMxXMEA1') AND SM_Date_Time_Opened__c > 2012-11-07";
//    NSString *newQuery = @"select Id from Case where SM_Date_Time_Opened__c > 2012-11-07T00:00:00 AND SM_Date_Time_Opened__c < YESTERDAY";
//    NSString *newQuery = @"select Id, Description, IsOwnedByProfile, Label from PermissionSet WHERE IsOwnedByProfile = TRUE";
//    NSString *newQuery = @"select Id, Name from Tech_Asset_Types__c";
//    [self issueQuery:newQuery];
    
//    [self issueRequestForObjectMetaData:@"ObjectPermissions"];
//        [self issueRequestForObjectMetaData:@"Case"];
}

-(void)issueQuery:(NSString *)incomingQuery{
    
    NSString *query=nil;
    query = incomingQuery;
    
    
    SFRestRequest *records = [[SFRestAPI sharedInstance] requestForQuery:query];
    NSLog(@"API Version:%@", records.path);
    
    [[SFRestAPI sharedInstance] send:records delegate:self];
}


- (void)request:(SFRestRequest *)request didLoadResponse:(id)jsonResponse {
    NSArray *records = [jsonResponse objectForKey:@"records"];
    
    NSDictionary *dictionary = (NSDictionary *)jsonResponse;
    
    [self printResponse:jsonResponse];
    
    //print field names
    [self printFieldName:dictionary];
    [self printRecordIds:records];
    
    @try{
        [self printRecordIds:records];
    }
    @catch(NSException *exception){
        NSLog(@"%@", [exception description]);
    }
    
    NSLog(@"request:didLoadResponse: #records: %d", records.count);
}

#pragma mark - Private Methods

-(void)printRecordIds:(NSArray *)records{
    for (NSDictionary *record in records){
        NSLog(@"IR Id:%@", [record objectForKey:@"Id"]);
    }
}

- (void)issueRequestForObjectMetaData:(NSString *)objectName {
    /*Sample object names
     * Tech_Asset__c
     * Incident__c
     * User
     * */
    
    SFRestRequest *metaData = [[SFRestAPI sharedInstance] requestForDescribeWithObjectType:objectName];
    
    
    [[SFRestAPI sharedInstance] send:metaData delegate:self];
}

- (void)selectTopRecords:(NSString *)selectClause from:(NSString *)fromClause where:(NSString *)whereClause{
    /*
     * Sample queries:
     *
     * SELECT RMA_Tech_Asset__c, Id, Owner_Name__c, Name, Status__c, OwnerId, Description__c, Incident_Duration__c, Tech_Asset__c
     * from Incident__c
     * where INCIDENT_SEVERITY__c ='Sev1' AND Name = 'IR-0000022520'
     * ORDER BY Id DESC
     * Limit 1 "
     *
     * "select Tech_Asset__c
     * from Incident__c
     * where Name='IR-0000022530' LIMIT 10"
     *
     *
     * SELECT Id, Incident_Report_Record__c, Tech_Asset__c
     * from Incident_Asset_Connector__c
     * where Tech_Asset__C = 'a0kS0000000ptNzIAI' "];
     *
     * "SELECT Id, Name
     * from Tech_Asset__c
     * where Name='050428692417 / fg /' "
     *
     * "SELECT Incident_Report_Record__c1
     * from Incident_Asset_Connector__c
     * where Tech_Asset__c ='a0kS0000000ptNzIAI' "
     *
     * SELECT Incident_Report_Record__c
     * from Incident_Asset_Connector__c
     * where Tech_Asset__c ='a0kS0000000ptNzIAI' "
     *
     * Select Id, Name, Email, UserType, AccountId
     * FROM User
     * WHERE Id='005S0000003hRrpIAE'
     * */
    
    /*
     * Sample owner Id:'005S0000003hRrpIAE'
     * */
    
    /*
     * Sample tech_Asset hash codes: a0kS0000000ptNzIAI, a22S0000000CEJgIAO
     * */
    
    NSString *query=nil;
    if (whereClause != nil){
        query = [NSString stringWithFormat:@"select %@ from %@ where %@ LIMIT 10", selectClause, fromClause, whereClause];
    }
    else{
        query = [NSString stringWithFormat:@"select %@ from %@ LIMIT 10", selectClause, fromClause];
    }
    
    
    SFRestRequest *topIncidents = [[SFRestAPI sharedInstance] requestForQuery:query];
    
    
    [[SFRestAPI sharedInstance] send:topIncidents delegate:self];
}

-(void)printFieldName:(NSDictionary *)dictionary{
    
    NSArray *fields = [dictionary objectForKey:@"fields"];
    
    for (id field in fields){
        NSDictionary *fieldDictionary = (NSDictionary *)field;
        NSLog(@"Field Name: %@", [fieldDictionary objectForKey:@"name"]);
    }
}

- (void)printResponse:(id)jsonResponse {
    NSLog(@"%@", jsonResponse);
}



#pragma mark - SFRestAPIDelegate

- (void)request:(SFRestRequest*)request didFailLoadWithError:(NSError*)error {
    NSLog(@"request:didFailLoadWithError: %@", error);
    //add your failed error handling here
}

- (void)requestDidCancelLoad:(SFRestRequest *)request {
    NSLog(@"requestDidCancelLoad: %@", request);
    //add your failed error handling here
}

- (void)requestDidTimeout:(SFRestRequest *)request {
    NSLog(@"requestDidTimeout: %@", request);
    //add your failed error handling here
}


@end
