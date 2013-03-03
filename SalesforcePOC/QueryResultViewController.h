//
//  QueryResultViewController.h
//  SalesforcePOC
//
//  Created by Donovan Palma Jr on 2013-01-22.
//  Copyright (c) 2013 Donovan Palma Jr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFRestAPI.h"
#import <MessageUI/MessageUI.h>

typedef enum{
    Query,
    Describe
}QueryMode;

@interface QueryResultViewController : UIViewController<SFRestDelegate, MFMailComposeViewControllerDelegate>

@property(nonatomic) QueryMode queryMode;
@property(copy, nonatomic) NSString *queryString;
@property(copy, nonatomic) NSString *object;

@property(nonatomic, strong) IBOutlet UITextView *textViewOutlet;
@property(nonatomic, strong) IBOutlet UIToolbar *toolbarOutlet;

@end
