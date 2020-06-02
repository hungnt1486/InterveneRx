//
//  LoginViewController.h
//  InterV
//
//  Created by HungLe on 10/5/16.
//  Copyright © 2016 HungLe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface LoginViewController : UIViewController<UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>{
    NSArray *arrLinkServer;
    // array account test
    NSArray *arrLinkServerTest;
}
@property (weak, nonatomic) IBOutlet UITextField *txtUserName;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
- (IBAction)touchLogin:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnSignIn;
@property (weak, nonatomic) IBOutlet UIButton *btnForgetPass;
@property (weak, nonatomic) IBOutlet UIView *viewTop;
@property (weak, nonatomic) IBOutlet UIView *viewCreateNewUser;
- (IBAction)touchForgetPass:(id)sender;
- (IBAction)touchCreateAccount:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *txtEmail;
@property (weak, nonatomic) IBOutlet UITextField *txtDOB;
@property (weak, nonatomic) IBOutlet UITextField *txtUserNameNew;
@property (weak, nonatomic) IBOutlet UITextField *txtPasswordNew;
@property (weak, nonatomic) IBOutlet UITextField *txtConfirmPasswordNew;
- (IBAction)touchCreateNewUser:(id)sender;
- (IBAction)touchCancelNewUser:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *viewDatePicker;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
- (IBAction)touchCancelDatePicker:(id)sender;
- (IBAction)touchDoneDatePicker:(id)sender;
- (IBAction)touchDOB:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *viewChangeLinkServer;
@property (weak, nonatomic) IBOutlet UITableView *tableViewLinkServer;
- (IBAction)touchLogout:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lblVersion;


@end
