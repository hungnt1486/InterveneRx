//
//  ProfileViewController.h
//  InterV
//
//  Created by HungLe on 10/4/16.
//  Copyright © 2016 HungLe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileViewController : UIViewController{

}
@property (weak, nonatomic) IBOutlet UILabel *lblAddress;
@property (weak, nonatomic) IBOutlet UILabel *lblState;
@property (weak, nonatomic) IBOutlet UILabel *lblCity;
@property (weak, nonatomic) IBOutlet UILabel *lblHomePhone;
@property (weak, nonatomic) IBOutlet UILabel *lblCellPhone;
@property (weak, nonatomic) IBOutlet UILabel *lblZipCode;
@property (weak, nonatomic) IBOutlet UILabel *lblHip;
@property (weak, nonatomic) IBOutlet UILabel *lblFirstName;
@property (weak, nonatomic) IBOutlet UILabel *lblLastName;
@property (weak, nonatomic) IBOutlet UILabel *lblEmail;
@property (weak, nonatomic) IBOutlet UIView *viewBGAvatar;
@property (weak, nonatomic) IBOutlet UILabel *lblFullName;
@property (weak, nonatomic) IBOutlet UIButton *btnEditProfile;
@property (weak, nonatomic) IBOutlet UILabel *lblMiddleName;
@property (weak, nonatomic) IBOutlet UILabel *lblRelationship;
@property (weak, nonatomic) IBOutlet UILabel *lblFirstNameSecond;
@property (weak, nonatomic) IBOutlet UILabel *lblLastNameSecond;
@property (weak, nonatomic) IBOutlet UILabel *lblPhone;
- (IBAction)touchEditProfile:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnChangePassword;
- (IBAction)touchChangePassword:(id)sender;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewProfile;
@property (weak, nonatomic) IBOutlet UIImageView *imgAvatar;
@property (weak, nonatomic) IBOutlet UIView *viewTop;
@property (weak, nonatomic) IBOutlet UILabel *lblVersion;

@end
