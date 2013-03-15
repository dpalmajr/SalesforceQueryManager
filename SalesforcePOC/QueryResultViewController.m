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

@implementation QueryResultViewController {
    UIToolbar *_customToolbar;
}

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

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self addToolBar];
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    if (!self.queryMode){
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Unable to continue with nil queryMode" userInfo:nil];
    }

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
    _jsonResponse = [jsonResponse copy];

    switch(self.queryMode){
        case Query:{
            id recordsFromResponse = [_jsonResponse objectForKey:@"records"];
            _records =recordsFromResponse;
            [self displayRecordsForResponse:_records];
            break;
        }
        case Describe:{
            self.textViewOutlet.text = [_jsonResponse description];
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

/*
* This method will add a tool bar to the queryResultsViewControllers view.
* */
- (void)addToolBar {
    self.hidesBottomBarWhenPushed = NO;

        UIToolbar *customToolbar = [[UIToolbar alloc] init];

    //make sure we don't add this view to it's parent twice
    [customToolbar removeFromSuperview];

    CGRect toolbarFrame = CGRectMake(0, self.view.bounds.size.height - 44,self.view.bounds.size.width, 44);

    [customToolbar setFrame:toolbarFrame];

    UIBarButtonItem *emailTo = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(emailResults)];

    UIBarButtonItem *flexibleBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];

    [customToolbar setItems:[NSArray arrayWithObjects:flexibleBarButtonItem, emailTo, nil]];

    [self.view addSubview:customToolbar];
}

/*
* This method will present a 'compose email' modally and allow the user to send
* query results through the native mail app.
* */
- (void)emailResults {
   if ([MFMailComposeViewController canSendMail]){
       MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
       mailComposeViewController.mailComposeDelegate = self;
       
       switch (self.queryMode){
           case Query:{
               [mailComposeViewController setSubject:@"SOQL Query Results"];
               break;
           }
           case Describe:{
               [mailComposeViewController setSubject:@"Object MetaData Describe Results"];
               break;
           }
       }
        [mailComposeViewController setMessageBody:[_jsonResponse description] isHTML:NO];
       
       [self presentViewController:mailComposeViewController animated:YES completion:nil];
   }
}

#pragma mark - MFMailComposeViewControllerDelegate Methods

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    
    //regardless of the reason, the MFMailComposeViewController should be dismissed.
    [controller dismissViewControllerAnimated:YES completion:nil];
    
}
@end
