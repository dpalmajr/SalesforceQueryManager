//
//  QueryResultViewController.m
//  SalesforcePOC
//
//  Created by Donovan Palma Jr on 2013-01-22.
//  Copyright (c) 2013 Donovan Palma Jr. All rights reserved.
//

#import "QueryResultViewController.h"

@interface QueryResultViewController ()

@end

@implementation QueryResultViewController{
    BOOL _displayingRecords;
    NSArray *_records;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _displayingRecords = NO;
        _records =[[NSArray alloc]init];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    switch(self.queryMode){
        case Query:{
            //add barbutton item to toggle between fields and result
            UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Fields" style:UIBarButtonItemStyleBordered target:self action:@selector(barButtonItemPressed:)];
            
            self.navigationItem.rightBarButtonItem = barButtonItem;

            [self issueQuery:self.queryString];
            break;
        }
        case Describe:{
            [self issueRequestForObjectMetaData:self.object];
            break;
        }
    }
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - rest request delegate

- (void)request:(SFRestRequest *)request didLoadResponse:(id)jsonResponse{
    switch(self.queryMode){
        case Query:{
            _records = [jsonResponse objectForKey:@"records"];
            _displayingRecords = YES;
            [self displayRecordsForResponse:_records];
            break;
        }
        case Describe:{
            self.textViewOutlet.text = [jsonResponse description];
            break;
        }
    }
}

- (void)request:(SFRestRequest *)request didFailLoadWithError:(NSError*)error{
    self.textViewOutlet.text = [error description];
}

#pragma mark - private methods
-(void)issueQuery:(NSString *)incomingQuery{
    
    NSString *query=nil;
    query = incomingQuery;
    
    SFRestRequest *records = [[SFRestAPI sharedInstance] requestForQuery:query];
    NSLog(@"API Version:%@", records.path);
    NSLog(@"Issuing query: %@", incomingQuery);
    
    [[SFRestAPI sharedInstance] send:records delegate:self];
}

- (void)issueRequestForObjectMetaData:(NSString *)objectName {
    /*Sample object names
     * Tech_Asset__c
     * Incident__c
     * User
     * */
    
    NSLog(@"Issuing metadata request for object: %@", objectName);
    
    SFRestRequest *metaData = [[SFRestAPI sharedInstance] requestForDescribeWithObjectType:objectName];
    
    
    [[SFRestAPI sharedInstance] send:metaData delegate:self];
}

-(void) barButtonItemPressed:(id)sender{
    
    if (_displayingRecords){
        _displayingRecords = NO;
        
        //clear the text view and repopulate with the list of field names
        self.textViewOutlet.text = @"";
        [self displayFieldNamesForResponse:_records];
    }
    else{
        _displayingRecords = YES;
        //clear the text view and repopulatea with the list of records
        self.textViewOutlet.text = @"";
        [self displayRecordsForResponse:_records];
    }
}

-(void) displayFieldNamesForResponse:(NSArray *)records{
    NSMutableString *fieldNames = [[NSMutableString alloc]init];
    for(NSDictionary *item in records){
        NSString *objectName =[[item objectForKey:@"name"]description];
        
        [fieldNames appendFormat:@"%@\n", objectName];
    }
    
    self.textViewOutlet.text = fieldNames;
}

-(void) displayRecordsForResponse:(NSArray *)records{
    NSMutableString *recordData = [[NSMutableString alloc]init];
    for (id item in records){
        [recordData appendFormat:@"%@\n", [item description]];
    }
    self.textViewOutlet.text = recordData;
}

@end
