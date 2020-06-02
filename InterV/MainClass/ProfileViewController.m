//
//  ProfileViewController.m
//  InterV
//
//  Created by HungLe on 10/4/16.
//  Copyright © 2016 HungLe. All rights reserved.
//

#import "ProfileViewController.h"
#import "NSDictionary+Profile.h"

@interface ProfileViewController (){
    NSDictionary *dictProfile;
}

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIImage *imgRight = [UIImage imageNamed:@"IconLogout"];
    UIButton *btnRight = [UIButton buttonWithType:UIButtonTypeCustom];
    btnRight.bounds = CGRectMake(0, 0, imgRight.size.width, imgRight.size.height);
    [btnRight setImage:imgRight forState:UIControlStateNormal];
    [btnRight addTarget:self action:@selector(touchLogout) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *itemRight = [[UIBarButtonItem alloc] initWithCustomView:btnRight];
    self.navigationItem.rightBarButtonItem = itemRight;
    
    dictProfile = [[NSDictionary alloc] init];
    
    self.navigationController.navigationBar.barTintColor = [Settings setColorBG];
    self.navigationController.navigationBar.translucent = NO;
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[Settings setColorText]}];
    
    _viewTop.backgroundColor = [Settings setColorBG];
    
    _btnEditProfile.layer.cornerRadius = 5.0;
    _btnEditProfile.clipsToBounds = YES;
    
    _btnChangePassword.layer.cornerRadius = 5.0;
    _btnChangePassword.clipsToBounds = YES;
    
    _viewBGAvatar.layer.cornerRadius = _viewBGAvatar.frame.size.height/2;
    _viewBGAvatar.clipsToBounds = YES;
    
    _imgAvatar.layer.cornerRadius = _imgAvatar.frame.size.height/2;
    _imgAvatar.clipsToBounds = YES;
    
    [_scrollViewProfile setContentSize:CGSizeMake([[UIScreen mainScreen] bounds].size.width, _scrollViewProfile.frame.size.height + 400)];
    _lblVersion.text = [Settings getVersion];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[AppDelegate shareInstance] showProgressHub];
    [self performSelectorInBackground:@selector(getProfile) withObject:nil];

//    NSString *source = @"31/54,65";
//
//        // Matches anything that looks like a Cocoa type:
//        // UIButton, NSCharacterSet, NSURLSession, etc.
//    NSString *typePattern = @"[1-9/]{2,}[1-9,]{2,}[0-9]{2,}+";
//    NSRange typeRange = [source rangeOfString:typePattern
//                                      options:NSRegularExpressionSearch];
//
//    if (typeRange.location != NSNotFound) {
//        NSLog(@"First type: %@", [source substringWithRange:typeRange]);
//            // First type: NSSet
//    }else{
//        NSLog(@"gweg");
//    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    NSLog(@"frame = %@", NSStringFromCGRect(_scrollViewProfile.frame));

    // call api imediate calendar
    [[CalendarViewController ShareInstance] getListCalendar];
//    [self performSelectorInBackground:@selector(getListCalendar) withObject:nil];
    ;
    // end call api imediate calendar
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchLogout{
    [[CalendarViewController ShareInstance] touchLogout];
}

- (void)getProfile{
    NSDictionary *dictAccount = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultLogin];
    NSString *strLinkCalendar = [NSString stringWithFormat:@"%@%@", kLink, kProfile];
    NSURL *url = [NSURL URLWithString:strLinkCalendar];
    
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.HTTPAdditionalHeaders = @{@"token":[dictAccount valueForKey:@"token"]};
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:url sessionConfiguration:config];
    [manager.requestSerializer setTimeoutInterval:kMaxTimeOut];
    [manager GET:[NSString stringWithFormat:@"?id=%@", [[[Settings EnCryptionString:[dictAccount valueForKey:@"PatientId"]] dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength]] parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = responseObject;
        NSLog(@"responseObject = %@", responseObject);
        if ([[dict valueForKey:@"success"] intValue] == 1) {
            dictProfile = [Settings DeCryptionData:[dict valueForKey:@"response"]];
//            dictProfile = (NSDictionary*)responseObject;
            NSDictionary *dictTemp = [Settings DeCryptionData:[dict valueForKey:@"response"]];
            [self performSelectorOnMainThread:@selector(refreshGUI:) withObject:dictTemp waitUntilDone:YES];
        }else{
            UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:@"Information" message:[dict objectForKey:@"message"] preferredStyle:UIAlertControllerStyleAlert];
            [alertControl addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [alertControl dismissViewControllerAnimated:YES completion:nil];
            }]];
            [[AppDelegate shareInstance] hideProgressHub];
            [self presentViewController:alertControl animated:YES completion:nil];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error = %@", error);
        UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:@"Warning!" message:@"Please check internet and try again." preferredStyle:UIAlertControllerStyleAlert];
        [alertControl addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [alertControl dismissViewControllerAnimated:YES completion:nil];
        }]];
        [[AppDelegate shareInstance] hideProgressHub];
        [self presentViewController:alertControl animated:YES completion:nil];
        
    }];
}

- (void)refreshGUI : (id)response{
//    img
    
    NSDictionary *dict = response;//[(NSDictionary *)response results];
    
    _lblFullName.text = [dict fname];
    _lblAddress.text = [dict address];
    _lblState.text = [dict state];
    _lblCity.text = [dict city];
    _lblHomePhone.text = [dict homephone];
    _lblCellPhone.text = [dict cellphone];
    _lblZipCode.text = [dict zipcode];
    _lblHip.text = [[dict executed] boolValue] == YES ? @"Yes": @"No";
    _lblFirstName.text = [dict fname];
    _lblLastName.text = [dict lname];
    _lblMiddleName.text = [dict mname];
    _lblEmail.text = [dict re_email];
    _lblRelationship.text = [dict relationship];
    _lblFirstNameSecond.text = [dict re_firstname];
    _lblLastNameSecond.text = [dict re_lastname];
    _lblPhone.text = [dict re_phone];
    NSString *strLink = [NSString stringWithFormat:@"%@%@", kLinkAvatar, [dict avatar]];
    NSArray *arr = [[dict avatar] componentsSeparatedByString:@"/"];
    NSString *strName = [arr objectAtIndex:arr.count-1];
    NSFileManager *manager = [[NSFileManager alloc] init];
    bool checkExist = [manager fileExistsAtPath:[NSString stringWithFormat:@"%@/%@", docDir, strName]];
    if (!checkExist) {
        NSURL *URL = [NSURL URLWithString:strLink];
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        [_imgAvatar setImageWithURLRequest:request placeholderImage:[UIImage imageNamed:@"IconAvatar"] success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
            _imgAvatar.image = image;
            
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *appFile = [documentsDirectory stringByAppendingPathComponent:strName];
            [UIImageJPEGRepresentation(image, 0.5) writeToFile:appFile atomically:YES];
            [[AppDelegate shareInstance] hideProgressHub];
        } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
            [[AppDelegate shareInstance] hideProgressHub];
        }];
    }else{
        _imgAvatar.image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", docDir, strName]];
        [[AppDelegate shareInstance] hideProgressHub];
    }
}

- (IBAction)touchEditProfile:(id)sender {
    EditProfileViewController *editProfile = [[EditProfileViewController alloc] initWithNibName:@"EditProfileViewController" bundle:nil];
    editProfile.dict = dictProfile;//[dictProfile results];
    [self.navigationController pushViewController:editProfile animated:YES];
}
- (IBAction)touchChangePassword:(id)sender {
    UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:@"Change Password" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertControl addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Old Password";
        textField.secureTextEntry = YES;
    }];
    [alertControl addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"New Password";
        textField.secureTextEntry = YES;
    }];
    [alertControl addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Confirm Password";
        textField.secureTextEntry = YES;
    }];
    UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [alertControl dismissViewControllerAnimated:YES completion:nil];
        if ([alertControl.textFields[1].text isEqualToString:alertControl.textFields[2].text]) {
            [[AppDelegate shareInstance] showProgressHub];
            NSDictionary *dictTemp = @{
                                       @"oldPass":alertControl.textFields[0].text,
                                       @"newPass":alertControl.textFields[1].text
                                       };
            [self performSelectorInBackground:@selector(changePassword:) withObject:dictTemp];
        }else{
            UIAlertController *alertControl1 = [UIAlertController alertControllerWithTitle:@"Warning!" message:@"New Password and Confirm Password not match." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *actionOk1 = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [alertControl1 dismissViewControllerAnimated:YES completion:nil];
            }];
            [alertControl1 addAction:actionOk1];
            [self presentViewController:alertControl1 animated:YES completion:nil];
        }
    }];
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [alertControl dismissViewControllerAnimated:YES completion:nil];
    }];
    [alertControl addAction:actionOk];
    [alertControl addAction:actionCancel];
    [self presentViewController:alertControl animated:YES completion:nil];
}

- (void)changePassword:(NSDictionary *)dictInfo{
    NSDictionary *dictAccount = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultLogin];
    NSString *strLinkCalendar = [NSString stringWithFormat:@"%@%@", kLink, kChangePassword];
    NSURL *url = [NSURL URLWithString:strLinkCalendar];
    NSDictionary *parameter = @{
                                @"patientid":[dictAccount valueForKey:@"PatientId"],
                                @"oldpass":[dictInfo objectForKey:@"oldPass"],
                                @"newpass":[dictInfo objectForKey:@"newPass"]
                                };
    // encryption
    NSDictionary *dictParameter = @{
                                    @"parameter" :[Settings EnCryptionDictionary:parameter]
                                    };
    // end encryption
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.HTTPAdditionalHeaders = @{@"token":[dictAccount valueForKey:@"token"]};
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:url sessionConfiguration:config];
    [manager.requestSerializer setTimeoutInterval:kMaxTimeOut];
    [manager PUT:@"" parameters:dictParameter success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"responseObject = %@", responseObject);
        NSString *strTitle = @"";
        NSString *strMessage = @"";
        if ([[responseObject objectForKey:@"success"] intValue] == 1) {
            strTitle = @"Success";
            strMessage = @"Change Password success.";
        }else{
            strTitle = @"Fail";
            strMessage = @"Please try again.";
        }
        UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:strTitle
                                                                              message:strMessage
                                                                       preferredStyle:UIAlertControllerStyleAlert];
        [alertControl addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [alertControl dismissViewControllerAnimated:YES completion:nil];
        }]];
        [[AppDelegate shareInstance] hideProgressHub];
        [self presentViewController:alertControl animated:YES completion:nil];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:@"Warning!" message:@"Please check internet and try again." preferredStyle:UIAlertControllerStyleAlert];
        [alertControl addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [alertControl dismissViewControllerAnimated:YES completion:nil];
        }]];
        [[AppDelegate shareInstance] hideProgressHub];
        [self presentViewController:alertControl animated:YES completion:nil];

    }];
}

@end
