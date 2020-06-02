//
//  LoginViewController.m
//  InterV
//
//  Created by HungLe on 10/5/16.
//  Copyright © 2016 HungLe. All rights reserved.
//

#import "LoginViewController.h"
#import "CryptLib.h"
#import "NSData+Base64.h"

@interface LoginViewController (){
    StringEncryption *libr;
}

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // encryption
    libr = [[StringEncryption alloc] init];
    // end encryption

    UIView *vUser = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, _txtUserName.frame.size.height)];
    UIImageView *imgLeftUserName = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IconUser"]];
    imgLeftUserName.contentMode = UIViewContentModeScaleAspectFit;
    [vUser addSubview:imgLeftUserName];
    _txtUserName.leftViewMode = UITextFieldViewModeAlways;
    _txtUserName.leftView = vUser;
    
    UIView *vPass = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, _txtPassword.frame.size.height)];
    UIImageView *imgLeftPassword = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IconPassword"]];
    imgLeftPassword.contentMode = UIViewContentModeScaleAspectFit;
    [vPass addSubview:imgLeftPassword];
    _txtPassword.leftViewMode = UITextFieldViewModeAlways;
    _txtPassword.leftView = vPass;
    
    _viewTop.backgroundColor = [Settings setColorBG];
    
    _btnSignIn.layer.cornerRadius = 5.0;
    _btnSignIn.clipsToBounds = YES;
    _btnSignIn.backgroundColor = [Settings setColorBG];
    
    // fix keyboard on ipad
    // register notification keyboard
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardDidHideNotification object:nil];
    
     _datePicker.datePickerMode = UIDatePickerModeDate;
    _datePicker.maximumDate = [NSDate date];
//    [[AppDelegate shareInstance] strLinkServer] = @"fa";
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    NSString * version = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
    _lblVersion.text = [Settings getVersion];//[NSString stringWithFormat:@"InterveneRx, Version %@", version];
    
    arrLinkServer = [NSArray arrayWithObjects:
                     @"https://sd.intervenerx.com",
                     @"https://sandbox.intervenerx.com",
                     @"https://demo.intervenerx.com",
                     @"https://dev.intervenerx.com",
                     @"https://qa.intervenerx.com",
                     @"https://pre-sd.intervenerx.com",
                     nil];

    // link server test
    arrLinkServerTest = [NSArray arrayWithObjects:@"https://thanhduc.intervenerx.com", @"https://huynhhung.intervenerx.com", @"https://tanhung.intervenerx.com", nil];
    
    [Settings setBottomTF:_txtUserName];
    [Settings setBottomTF:_txtPassword];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MM/dd/yyyy";
    [_datePicker setDate:[NSDate date]];
    
//    [[NSUserDefaults standardUserDefaults] objectForKey:kLinkServerAPI];
//    NSLog(@"gewg = %@", [[NSUserDefaults standardUserDefaults] objectForKey:kLinkServerAPI]);
//    if ([[NSUserDefaults standardUserDefaults] objectForKey:kLinkServerAPI] == NULL) {
//        NSLog(@"dc ko");
//    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)keyboardWillHide:(NSNotification*)notification{
    NSLog(@"notification = %@", [notification userInfo]);
//    self.view.center = CGPointMake(self.view.center.x, self.view.frame.size.height/2);
    [UIView animateWithDuration:0.5 animations:^{
        self.view.center = CGPointMake(self.view.center.x, self.view.frame.size.height/2);
    } completion:^(BOOL finished) {
    }];

}

- (IBAction)touchLogin:(id)sender {
    
    // check account super and account test
    if (([_txtUserName.text isEqualToString:@"super"] && [_txtPassword.text isEqualToString:@"super"]) ||
        ([_txtUserName.text isEqualToString:@"test"] && [_txtPassword.text isEqualToString:@"test"])
        ) {
        [UIView animateWithDuration:0.5 animations:^{
            self.view.center = CGPointMake(self.view.center.x, self.view.frame.size.height/2);
            [self.view endEditing:YES];
        } completion:^(BOOL finished) {
            
        }];
        _viewChangeLinkServer.hidden = NO;
        [_tableViewLinkServer reloadData];
        return;
    }
    // end check account super
    
    if (_txtUserName.text.length > 0 && _txtPassword.text.length > 0) {
        [UIView animateWithDuration:0.5 animations:^{
            self.view.center = CGPointMake(self.view.center.x, self.view.frame.size.height/2);
            [self.view endEditing:YES];
        } completion:^(BOOL finished) {
            
        }];
        [[AppDelegate shareInstance] showProgressHub];
        NSString *strLink = [NSString stringWithFormat:@"%@%@", kLink,kAccount];
        NSURL *url = [NSURL URLWithString:strLink];
        NSDictionary *parameter = @{
                                    @"UserName":_txtUserName.text,
                                    @"Password":_txtPassword.text
                                    };
        
        // encryption data
        NSLog(@"parameter = %@", parameter);
        
//        NSError *err;
//        NSData *jsonData = [NSJSONSerialization  dataWithJSONObject:parameter options:0 error:&err];
//        
//        NSString *strTemp = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//        
//        NSString *key = SecretKey;
//        key = [[StringEncryption alloc] sha256:key length:31];
//        
//        NSData *encryptData = [[StringEncryption alloc] encrypt:[strTemp dataUsingEncoding:NSUTF8StringEncoding] key:key iv:IVKey];
//
//        NSString *strEncrypt = [encryptData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
        
        NSDictionary *para = @{
                               @"parameter":[Settings EnCryptionDictionary:parameter]
                               };
        
        // end encryption data
        
        NSLog(@"para = %@", para);
        
        AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:url];
        [manager.requestSerializer setTimeoutInterval:kMaxTimeOut];

        [manager POST:@"" parameters:para progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"responseObject = %@", responseObject);
            NSDictionary *dict = responseObject;
            
            // decryption initWithBase64EncodedString
//            NSData *dataResponse = [[NSData alloc] initWithBase64EncodedString:[dict valueForKey:@"response"] options:NSUTF8StringEncoding];
//            NSString *strKey = [[StringEncryption alloc] sha256:SecretKey length:31];
//
//            NSError *er = nil;
//            NSData *dataDecrypt = [[StringEncryption alloc] decrypt:dataResponse key:strKey iv:IVKey];
//            NSDictionary *dt = [NSJSONSerialization JSONObjectWithData:dataDecrypt options:NSJSONReadingMutableContainers error:&er];
//            NSLog(@"dt = %@", dt);
//            NSString *strDecrypt = [[NSString alloc] initWithData:dataDecrypt encoding:NSUTF8StringEncoding];
//            NSLog(@"strDecrypt = %@", strDecrypt);
            // end decryption
            
            if ([[dict valueForKey:@"success"] intValue] == 1) {
                NSDictionary *dictDescrypt = [Settings DeCryptionData:[dict valueForKey:@"response"]];
                NSLog(@"token = %@", [dictDescrypt valueForKey:@"token"]);
                [[NSUserDefaults standardUserDefaults] setObject:dictDescrypt forKey:kUserDefaultLogin];
                [[NSUserDefaults standardUserDefaults] synchronize];
                dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    dispatch_async(dispatch_get_main_queue(), ^(void){
                        //Run UI Updates
                        [[AppDelegate shareInstance] LoginSuccess];
                    });
                
                });
            }else{
                UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:@"Warning!" message:@"Please check UserName or Password" preferredStyle:UIAlertControllerStyleAlert];
                [alertControl addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [alertControl dismissViewControllerAnimated:YES completion:nil];
                }]];
                [self presentViewController:alertControl animated:YES completion:nil];
                [[AppDelegate shareInstance] hideProgressHub];
            }

        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"error = %@", error);
            [[AppDelegate shareInstance] hideProgressHub];
        }];
    }else{
        UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:@"Warning!" message:@"Please input UserName or Password" preferredStyle:UIAlertControllerStyleAlert];
        [alertControl addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [alertControl dismissViewControllerAnimated:YES completion:nil];
        }]];
        [self presentViewController:alertControl animated:YES completion:nil];
    }
}

- (IBAction)touchForgetPass:(id)sender {
    UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:@"Forgot Password" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertControl addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Please input your email";
        textField.keyboardType = UIKeyboardTypeEmailAddress;
    }];
    [alertControl addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [alertControl dismissViewControllerAnimated:YES completion:nil];
    }]];
    [alertControl addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[AppDelegate shareInstance] showProgressHub];
        
//        [self touchForgotPassword:[alertControl.textFields objectAtIndex:0].text];
        [self performSelectorInBackground:@selector(touchForgotPassword:) withObject:[alertControl.textFields objectAtIndex:0].text];
        [alertControl dismissViewControllerAnimated:YES completion:nil];
    }]];
    [self presentViewController:alertControl animated:YES completion:nil];
}

- (IBAction)touchCreateAccount:(id)sender {
    [self.view endEditing:YES];
    
    [self performSelector:@selector(showViewCreateAccount) withObject:NULL afterDelay:0.75];
    
}

- (void)showViewCreateAccount{
    _viewCreateNewUser.hidden = NO;
}

- (void)touchForgotPassword : (NSString *)strEmail{
    
    NSString *strLink = [NSString stringWithFormat:@"%@%@?email=%@", kLink,kAccount, [Settings EnCryptionString:strEmail]];
    NSURL *url = [NSURL URLWithString:strLink];
//    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:url];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.HTTPAdditionalHeaders = @{@"token":@"abifzfoigrejgh"};
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:url sessionConfiguration:config];
    [manager.requestSerializer setTimeoutInterval:kMaxTimeOut];
    [manager GET:@"" parameters:NULL progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"responseObject = %@", responseObject);
        NSDictionary *dict = (NSDictionary*)responseObject;
        if ([[dict objectForKey:@"success"] isEqualToString:@"1"]) {
            UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:@"Successful!" message:[dict objectForKey:@"message"] preferredStyle:UIAlertControllerStyleAlert];
            [alertControl addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [alertControl dismissViewControllerAnimated:YES completion:nil];
            }]];
            [self presentViewController:alertControl animated:YES completion:nil];
        }
        
        [[AppDelegate shareInstance] hideProgressHub];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:@"Fail!" message:@"Please try again." preferredStyle:UIAlertControllerStyleAlert];
        [alertControl addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [alertControl dismissViewControllerAnimated:YES completion:nil];
        }]];
        [self presentViewController:alertControl animated:YES completion:nil];
        [[AppDelegate shareInstance] hideProgressHub];
    }];
}

#pragma mark UITextField Delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
//    if (textField.tag == 111) {
//        [self.view endEditing:YES];
//        _viewDatePicker.hidden = NO;
//        [textField resignFirstResponder];
//        [textField respondsToSelector:@selector(abc)];
////        [textField r]
//    }
    if (textField.tag<110) {
        
    
    [UIView animateWithDuration:0.5 animations:^{
//        if (textField.frame.origin.y > self.view.frame.size.height/2) {
            self.view.center = CGPointMake(self.view.center.x, self.view.frame.size.height - textField.frame.origin.y - 20);
//        }
    } completion:^(BOOL finished) {
        
    }];
    }
    return true;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSInteger nextTag = textField.tag + 1;
    UIResponder *respone = [textField.superview viewWithTag:nextTag];
    if (respone != nil) {
        [respone becomeFirstResponder];
        if (nextTag == 111) {
//            [respone resignFirstResponder];
            [self.view endEditing:YES];
            _viewDatePicker.hidden = NO;
        }
    }else{
        [UIView animateWithDuration:0.5 animations:^{
            self.view.center = CGPointMake(self.view.center.x, self.view.frame.size.height/2);
            [textField resignFirstResponder];
        } completion:^(BOOL finished) {
            
        }];
    }
    return true;
}

- (IBAction)touchCreateNewUser:(id)sender {
    _viewCreateNewUser.hidden = YES;
    [self.view endEditing:YES];
    if (![_txtConfirmPasswordNew.text isEqualToString:_txtPasswordNew.text]) {
        UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:@"Warning!"
                                                                              message:@"Password is not match confirm password"
                                                                       preferredStyle:UIAlertControllerStyleAlert];
        [alertControl addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [alertControl dismissViewControllerAnimated:YES completion:nil];
        }]];
        [self presentViewController:alertControl animated:YES completion:nil];
        return;
    }
    [[AppDelegate shareInstance] showProgressHub];
    
    NSString *strLinkCalendar = [NSString stringWithFormat:@"%@%@", kLink, kCreateAccount];
    NSURL *url = [NSURL URLWithString:strLinkCalendar];
    NSDictionary *parameter = @{
                                @"email":_txtEmail.text,
                                @"Dob":_txtDOB.text,
                                @"username":_txtUserNameNew.text,
                                @"password":_txtPasswordNew.text
                                };
    // encryption
    NSDictionary *dictParameter = @{
                                    @"parameter" :[Settings EnCryptionDictionary:parameter]
                                    };
    // end encryption

    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.HTTPAdditionalHeaders = @{@"token":@"gheioghewghw"};
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:url sessionConfiguration:config];
    [manager.requestSerializer setTimeoutInterval:kMaxTimeOut];
    [manager PUT:@"" parameters:dictParameter success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"responseObject = %@", responseObject);
        NSString *strTitle = @"";
        NSString *strMessage = @"";
//        if ([[responseObject objectForKey:@"success"] intValue] == 1) {
//            strTitle = @"Success";
//            strMessage = @"Create new account successful.";
//        }else{
//            strTitle = @"Fail";
//            strMessage = @"Please try again.";
//        }
        
        switch ([[responseObject objectForKey:@"success"] intValue]) {
            case 0:
                strTitle = @"Fail";
                strMessage = @"The username is already in use.  Please choose a different username.";
                break;
            case 1:
                strTitle = @"Success";
                strMessage = @"Create new account successful.";
                break;
            case -1:
                strTitle = @"Fail";
                strMessage = @"Please try again.";
                break;
            case -2:
                strTitle = @"Fail";
                strMessage = @"Error system. code 003";
                break;
            case -3:
                strTitle = @"Fail";
                strMessage = @"Error system. code 002";
                break;
            case -4:
                strTitle = @"Fail";
                strMessage = @"This account already exists. If you forgot your password, please click Forgot Password";
                break;
            case -5:
                strTitle = @"Fail";
                strMessage = @"Email or Date of Birth does not match your account information.";
                break;
            default:
                break;
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

- (IBAction)touchCancelNewUser:(id)sender {
//    _viewDatePicker.hidden = YES;
    [self.view endEditing:YES];
    _viewCreateNewUser.hidden = YES;
    
}

- (IBAction)touchCancelDatePicker:(id)sender {
    _viewDatePicker.hidden = YES;
}

- (IBAction)touchDoneDatePicker:(id)sender {
    _viewDatePicker.hidden = YES;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MM/dd/yyyy";
    _txtDOB.text = [dateFormatter stringFromDate:_datePicker.date];
//    [_txtUserName becomeFirstResponder];
    
//    [self.view becomeFirstResponder];
    [_txtUserNameNew becomeFirstResponder];
}

- (IBAction)touchDOB:(id)sender {
    [self.view endEditing:YES];
    _viewDatePicker.hidden = NO;
}
- (IBAction)touchLogout:(id)sender {
    _txtUserName.text = @"";
    _txtPassword.text = @"";
    _viewChangeLinkServer.hidden = YES;
    [[NSUserDefaults standardUserDefaults] setObject:[[AppDelegate shareInstance] strLinkServer] forKey:kUserDefaultLinkServerAPI];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark UITableView Delegate & DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_txtUserName.text isEqualToString:@"super"] ? arrLinkServer.count : arrLinkServerTest.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"linkServerTableViewCell";
    linkServerTableViewCell *cell = (linkServerTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == NULL) {
        NSArray *arrNib = [[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil];
        cell = [arrNib lastObject];
    }
    cell.lblLinkServer.text = [_txtUserName.text isEqualToString:@"super"] ? [arrLinkServer objectAtIndex:indexPath.row] : [arrLinkServerTest objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [AppDelegate shareInstance].strLinkServer = [_txtUserName.text isEqualToString:@"super"] ? [arrLinkServer objectAtIndex:indexPath.row] : [arrLinkServerTest objectAtIndex:indexPath.row];
}

@end
