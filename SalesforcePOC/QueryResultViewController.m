//
//  QueryResultViewController.m
//  SalesforcePOC
//
//  Created by Donovan Palma Jr on 2013-01-22.
//  Copyright (c) 2013 Donovan Palma Jr. All rights reserved.
//

#import "QueryResultViewController.h"

@interface QueryResultViewController ()
{
    BOOL _displayingAllObjectMetaData;
    NSArray *_records;
    NSDictionary *_jsonResponse;
}

@end

@implementation QueryResultViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
      _displayingAllObjectMetaData = YES;
        _records =[[NSArray alloc]init];
        _jsonResponse = [[NSDictionary alloc]init];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    switch(self.queryMode){
        case Query:{
            [self issueQuery:self.queryString];
            break;
        }
        case Describe:{
            //add barbutton item to toggle between fields and result
            UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Fields" style:UIBarButtonItemStyleBordered target:self action:@selector(barButtonItemPressed:)];
            
            self.navigationItem.rightBarButtonItem = barButtonItem;

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

#pragma mark - IBActions

-(void) barButtonItemPressed:(id)sender{

    if (_displayingAllObjectMetaData == YES){
        _displayingAllObjectMetaData = NO;

        //clear the text view and repopulate with the list of field names
        self.textViewOutlet.text = @"";
        [self displayFieldNamesForResponse:_jsonResponse];
        self.navigationItem.rightBarButtonItem.title = @"Response";
    }
    else{
        _displayingAllObjectMetaData = YES;
        //clear the text view and repopulatea with the list of records
        self.textViewOutlet.text = @"";
            self.textViewOutlet.text = [_jsonResponse description];
        self.navigationItem.rightBarButtonItem.title = @"Fields";
    }
}

#pragma mark - rest request delegate

- (void)request:(SFRestRequest *)request didLoadResponse:(id)jsonResponse{
    switch(self.queryMode){
        case Query:{
            id recordsFromResponse = [jsonResponse objectForKey:@"records"];
            _records =recordsFromResponse;
            [self displayRecordsForResponse:_records];
            break;
        }
        case Describe:{
            _jsonResponse = [jsonResponse copy];
            self.textViewOutlet.text = [jsonResponse description];
            _displayingAllObjectMetaData = YES;
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
    
    NSLog(@"Issuing metadata request for object: %@", objectName);
    
    SFRestRequest *metaData = [[SFRestAPI sharedInstance] requestForDescribeWithObjectType:objectName];
    
    
    [[SFRestAPI sharedInstance] send:metaData delegate:self];
}

-(void)displayFieldNamesForResponse:(NSDictionary *)response {
    NSMutableString *fieldNames = [[NSMutableString alloc]init];

    id fields = [response objectForKey:@"fields"];
    
    if (!fields || ![fields isKindOfClass:[NSArray class]]){
        return;
    }
    
    for (NSDictionary *currentField in fields){
        [fieldNames appendFormat:@"Field Name: %@\t Field Type:%@\n",
         [currentField objectForKey:@"name"],
         [currentField objectForKey:@"type"]];
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
