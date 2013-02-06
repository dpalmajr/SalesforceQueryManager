//
//  QueryViewController.h
//  SalesforcePOC
//
//  Created by Donovan Palma Jr on 2013-01-22.
//  Copyright (c) 2013 Donovan Palma Jr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFRestAPI.h"

@interface QueryViewController : UIViewController<UITextViewDelegate, UITextFieldDelegate, SFRestDelegate>

@property(strong, nonatomic) IBOutlet UITextView *textViewOutlet;
@property(strong, nonatomic) IBOutlet UITextField *textFieldOutlet;

-(IBAction)executeQuery:(id)sender;
-(IBAction)executeObjectMetaDataRequest:(id)sender;
-(IBAction)updateGroupMember:(id)sender;
    
@end
