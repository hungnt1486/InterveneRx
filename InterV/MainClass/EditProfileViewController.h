//
//  EditProfileViewController.h
//  InterV
//
//  Created by HungLe on 10/25/16.
//  Copyright © 2016 HungLe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSDictionary+Profile.h"

@interface EditProfileViewController : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate>{
    UIImagePickerController *imgPicker;
    
    NSDictionary *dict;

    int intCheckStatusState;
}

@property (strong, nonatomic) NSDictionary *dict;

@property (weak, nonatomic) IBOutlet UIView *viewTop;
@property (weak, nonatomic) IBOutlet UIView *viewBGAvatar;
@property (weak, nonatomic) IBOutlet UIImageView *imgAvatar;
@property (weak, nonatomic) IBOutlet UILabel *lblFullName;
@property (weak, nonatomic) IBOutlet UIButton *btnUploadAvatar;
- (IBAction)touchUploadAvatar:(id)sender;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollEditProfile;
@property (weak, nonatomic) IBOutlet UITextField *txtAddres;
@property (weak, nonatomic) IBOutlet UITextField *txtState;
@property (weak, nonatomic) IBOutlet UITextField *txtCity;
@property (weak, nonatomic) IBOutlet UITextField *txtHomePhone;
@property (weak, nonatomic) IBOutlet UITextField *txtCellPhone;
@property (weak, nonatomic) IBOutlet UITextField *txtZipCode;
@property (weak, nonatomic) IBOutlet UITextField *txtFirstName;
@property (weak, nonatomic) IBOutlet UITextField *txtLastName;
@property (weak, nonatomic) IBOutlet UITextField *txtEmail;
@property (weak, nonatomic) IBOutlet UITextField *txtMiddleName;
@property (weak, nonatomic) IBOutlet UISwitch *switchHip;
@property (weak, nonatomic) IBOutlet UITextField *txtRelationship;
@property (weak, nonatomic) IBOutlet UITextField *txtFirstNameSecond;
@property (weak, nonatomic) IBOutlet UITextField *txtLastNameSecond;
@property (weak, nonatomic) IBOutlet UITextField *txtPhone;
- (IBAction)switchChanged:(id)sender;

@end
