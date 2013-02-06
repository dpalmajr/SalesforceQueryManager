//
//  QueryViewController.m
//  SalesforcePOC
//
//  Created by Donovan Palma Jr on 2013-01-22.
//  Copyright (c) 2013 Donovan Palma Jr. All rights reserved.
//

#import "QueryViewController.h"
#import "QueryResultViewController.h"

static const NSInteger kTextFieldOffset = 120;

@interface QueryViewController ()

@end

@implementation QueryViewController{
    NSString *_queryString;
    NSString *_objectName;
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    [textView resignFirstResponder];
    return YES;
    
}
- (void)textViewDidEndEditing:(UITextView *)textView{
    _queryString = textView.text;
    [textView resignFirstResponder];
    [self resignFirstResponder];
}

- (BOOL)textView:(UITextView *)textView
shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
    }
    return YES;
}


#pragma mark - UITextFieldDelegate
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    //offset the view to accomodate for the onscreen keyboard
    [UIView animateWithDuration:0.3 animations:^(){
        CGRect frame = self.view.frame;
        frame.origin.y -= kTextFieldOffset;
        self.view.frame = frame;
    }];
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}// called when 'return' key pressed. return NO to ignore.

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField{

    [UIView animateWithDuration:0.3 animations:^(){
        CGRect frame = self.view.frame;
        frame.origin.y += kTextFieldOffset;
        self.view.frame = frame;
    }];
   
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    _objectName = textField.text;
    [textField resignFirstResponder];
}

#pragma mark - IBActions
-(IBAction)executeQuery:(id)sender{
    //save the value from the active UITextView
    _queryString = self.textViewOutlet.text;
    [self.textViewOutlet resignFirstResponder];
    
    if (!_queryString)
        return;
    
    QueryResultViewController *resultsVC = [[QueryResultViewController alloc]initWithNibName:@"QueryResultViewController" bundle:nil];
    resultsVC.queryMode = Query;
    resultsVC.queryString = _queryString;
    [self.navigationController pushViewController:resultsVC animated:YES];
    [resultsVC release];
}

-(IBAction)executeObjectMetaDataRequest:(id)sender{
    
    _objectName = self.textFieldOutlet.text;
    [self.textFieldOutlet resignFirstResponder];
    
    if (!_objectName)
        return;
    
    QueryResultViewController *resultsVC = [[QueryResultViewController alloc]initWithNibName:@"QueryResultViewController" bundle:nil];
    resultsVC.queryMode = Describe;
    resultsVC.object = _objectName;
    [self.navigationController pushViewController:resultsVC animated:YES];
    
    [resultsVC release];
    
}

-(IBAction)updateGroupMember:(id)sender{
    SFRestAPI *instance = [SFRestAPI sharedInstance];
    NSDictionary *updateValue = [[NSDictionary alloc]initWithObjectsAndKeys:@"00Gd0000001ZjzbEAC",
                                 @"GroupId",
                                 @"005d0000001m2VIAAY",
                                 @"UserOrGroupId",
                                 nil];
    
    SFRestRequest *request = [instance requestForCreateWithObjectType:@"GroupMember" fields:updateValue];

    [instance send:request delegate:self];
    
}

- (void)request:(SFRestRequest *)request didLoadResponse:(id)jsonResponse{
    
    NSLog(@"%@",jsonResponse);
    [request release];
}

- (void)request:(SFRestRequest *)request didFailLoadWithError:(NSError*)error{
    NSLog(@"%@",[error description]);
}
@end
