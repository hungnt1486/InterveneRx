//
//  EditProfileViewController.m
//  InterV
//
//  Created by HungLe on 10/25/16.
//  Copyright © 2016 HungLe. All rights reserved.
//

#import "EditProfileViewController.h"


@interface EditProfileViewController (){
    CGSize keyboardSize;
}

@end

@implementation EditProfileViewController

@synthesize dict;

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationController.navigationBar.barTintColor = [Settings setColorBG];
    self.navigationController.navigationBar.translucent = NO;
    
    self.navigationController.navigationBar.tintColor = [Settings setColorText];
//    [[UINavigationBar appearance] setTintColor:[Settings setColorText]];
    
    self.navigationItem.title = @"Edit Profile";

    intCheckStatusState = 1;
    
    UIBarButtonItem *itemSave = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(touchSave)];
    [itemSave setTintColor:[Settings setColorText]];
    self.navigationItem.rightBarButtonItem = itemSave;
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[Settings setColorText]}];
    _viewTop.backgroundColor = [Settings setColorBG];
    
    _viewBGAvatar.layer.cornerRadius = _viewBGAvatar.frame.size.height/2;
    _viewBGAvatar.clipsToBounds = YES;
    
    _imgAvatar.layer.cornerRadius = _imgAvatar.frame.size.height/2;
    _imgAvatar.clipsToBounds = YES;
    
    _btnUploadAvatar.layer.cornerRadius = 5.0;
    
    switch ((int)[UIScreen mainScreen].bounds.size.height) {
        case kIP5H:
        {
            [_scrollEditProfile setContentSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, _scrollEditProfile.frame.size.height + 450)];
        }
            break;
        case kIP6H:
            [_scrollEditProfile setContentSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, _scrollEditProfile.frame.size.height + 400)];
            break;
        case kIP6PH:
            [_scrollEditProfile setContentSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, _scrollEditProfile.frame.size.height + 400)];
            break;
        default:
            break;
    }
    
//    [_scrollEditProfile setContentSize:CGSizeMake(_scrollEditProfile.frame.size.width, _scrollEditProfile.frame.size.height + 300)];
    
    imgPicker = [[UIImagePickerController alloc] init];
    imgPicker.delegate = self;
    
    [self createInputAccessori];
    
    // add keyboard notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    
    // import data
    
    _lblFullName.text = [dict fname];
    NSLog(@"dict = %@", dict);
    _txtAddres.text = [dict address];
    _txtState.text = [dict state];
    _txtCity.text = [dict city];
    _txtHomePhone.text = [dict homephone];
    _txtCellPhone.text = [dict cellphone];
    _txtZipCode.text = [dict zipcode];
    [[dict executed] boolValue] == YES ? [_switchHip setOn:YES]:[_switchHip setOn:NO];
    _txtFirstName.text = [dict fname];
    _txtLastName.text = [dict lname];
    _txtMiddleName.text = [dict mname];
    _txtEmail.text = [dict re_email];
    _txtPhone.text = [dict re_phone];
    _txtFirstNameSecond.text = [dict re_firstname];
    _txtLastNameSecond.text = [dict re_lastname];
    _txtRelationship.text = [dict relationship];

    self.txtState.userInteractionEnabled = NO;
    self.txtCity.userInteractionEnabled = NO;
    
    NSArray *arr = [[dict avatar] componentsSeparatedByString:@"/"];
    NSString *strName = [arr objectAtIndex:arr.count-1];
    _imgAvatar.image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", docDir, strName]];
}

-(void)keyboardDidShow:(NSNotification*)aNotification{
    NSDictionary* info = [aNotification userInfo];
    keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated{

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchSave{
    [self hideKeyboard];

    // check state
    if (self.txtZipCode.text.length < 5) {
        UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:@"Warning" message:@"Zip code entered is less than 5 digits. Please re-enter your zip code." preferredStyle:UIAlertControllerStyleAlert];
        [alertControl addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [alertControl dismissViewControllerAnimated:YES completion:nil];
        }]];

        [self presentViewController:alertControl animated:YES completion:nil];
        return;
    }else if (intCheckStatusState != 1){
        UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:@"Warning" message:@"Zip code entered is not valid. Please re-enter your zip code." preferredStyle:UIAlertControllerStyleAlert];
        [alertControl addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [alertControl dismissViewControllerAnimated:YES completion:nil];
        }]];

        [self presentViewController:alertControl animated:YES completion:nil];
        return;
    }
    // end check state

    [[AppDelegate shareInstance] showProgressHub];
    NSDictionary *dictAccount = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultLogin];
    NSString *strLinkCalendar = [NSString stringWithFormat:@"%@%@", kLink, kProfile];
    NSURL *url = [NSURL URLWithString:strLinkCalendar];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.HTTPAdditionalHeaders = @{@"token":[dictAccount valueForKey:@"token"]};
    
    NSDictionary *parameter = @{
                                @"patientid":[dictAccount valueForKey:@"PatientId"],
                                @"fname":_txtFirstName.text,
                                @"lname":_txtLastName.text,
                                @"mname":_txtMiddleName.text,
                                @"homephone":_txtHomePhone.text,
                                @"cellphone":_txtCellPhone.text,
                                @"address":_txtAddres.text,
                                @"city":_txtCity.text,
                                @"state":_txtState.text,
                                @"zipcode":_txtZipCode.text,
                                @"relationship":_txtRelationship.text,
                                @"executed":_switchHip.on?@"Yes":@"No",
                                @"re_firstname":_txtFirstNameSecond.text,
                                @"re_lastname":_txtLastNameSecond.text,
                                @"re_phone":_txtPhone.text,
                                @"re_email":_txtEmail.text
                                };

    // convert dictionary object to string json
    NSError *err = NULL;
    NSData *data = [NSJSONSerialization dataWithJSONObject:parameter options:NSJSONWritingPrettyPrinted error:&err];
    NSString *strData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    // end convert dictionary object to string json

    // encryption
    NSDictionary *dictParameter = @{
                                    @"parameter":[[[Settings EnCryptionString:strData] dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed]
                                    };
    // end encryption
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:url
                                                             sessionConfiguration:config];
    [manager.requestSerializer setTimeoutInterval:kMaxTimeOut];
    
    [manager PUT:@"" parameters:dictParameter success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"responseObject = %@", responseObject);
        NSDictionary *dict = responseObject;
        if ([[dict valueForKey:@"success"] intValue] == 1) {
            UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:@"Success" message:@"Update profile success." preferredStyle:UIAlertControllerStyleAlert];
            [alertControl addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [alertControl dismissViewControllerAnimated:YES completion:nil];
            }]];
            [[AppDelegate shareInstance] hideProgressHub];
            [self presentViewController:alertControl animated:YES completion:nil];
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

- (void)getStateCity{
    NSDictionary *dictAccount = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultLogin];
    NSString *strLinkCalendar = [NSString stringWithFormat:@"%@%@", kLink, kState];
    NSURL *url = [NSURL URLWithString:strLinkCalendar];

    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.HTTPAdditionalHeaders = @{@"token":[dictAccount valueForKey:@"token"]};

    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:url sessionConfiguration:config];

    [manager.requestSerializer setTimeoutInterval:kMaxTimeOut];
    [manager GET:[NSString stringWithFormat:@"?id=%@", self.txtZipCode.text] parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"responseObject  t calendar = %@", responseObject);

        NSDictionary *dict = (NSDictionary *)responseObject;
        intCheckStatusState = [[dict valueForKey:@"success"] intValue];
        if ([[dict valueForKey:@"success"] intValue] == 1) {
            [self performSelectorOnMainThread:@selector(refreshStateCity:) withObject:dict waitUntilDone:YES];
        }
        else{
            UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:@"Information" message:[dict objectForKey:@"message"] preferredStyle:UIAlertControllerStyleAlert];
            [alertControl addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [alertControl dismissViewControllerAnimated:YES completion:nil];
            }]];
            [[AppDelegate shareInstance] hideProgressHub];
            [self presentViewController:alertControl animated:YES completion:nil];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:@"Warning!" message:@"Please check internet and try again." preferredStyle:UIAlertControllerStyleAlert];
        [alertControl addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [alertControl dismissViewControllerAnimated:YES completion:nil];
        }]];
        [[AppDelegate shareInstance] hideProgressHub];
        [self presentViewController:alertControl animated:YES completion:nil];
    }];
}

- (void)refreshStateCity : (NSDictionary *)dict{
    [[AppDelegate shareInstance] hideProgressHub];
    self.txtCity.text = [[dict objectForKey:@"response"] objectForKey:@"PrimaryCity"];
    self.txtState.text = [[dict objectForKey:@"response"] objectForKey:@"StateCode"];
}

- (void)createInputAccessori{
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    toolbar.backgroundColor = [UIColor whiteColor];
    toolbar.tintColor = [UIColor whiteColor];
    
    toolbar.barTintColor = [UIColor whiteColor];
    
    UIBarButtonItem *btnDone = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(hideKeyboard)];
    btnDone.tintColor = [Settings setColorText];
    UIBarButtonItem *flexible = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    NSMutableArray *arr = [NSMutableArray arrayWithObjects:flexible, btnDone, nil];
    toolbar.items = arr;
    
    _txtCity.inputAccessoryView = toolbar;
    _txtEmail.inputAccessoryView = toolbar;
    _txtState.inputAccessoryView = toolbar;
    _txtAddres.inputAccessoryView = toolbar;
    _txtZipCode.inputAccessoryView = toolbar;
    _txtLastName.inputAccessoryView = toolbar;
    _txtFirstName.inputAccessoryView = toolbar;
    _txtMiddleName.inputAccessoryView = toolbar;
    _txtCellPhone.inputAccessoryView = toolbar;
    _txtHomePhone.inputAccessoryView = toolbar;
    _txtFirstNameSecond.inputAccessoryView = toolbar;
    _txtLastNameSecond.inputAccessoryView = toolbar;
    _txtPhone.inputAccessoryView = toolbar;
    _txtRelationship.inputAccessoryView = toolbar;
}

- (void)hideKeyboard{
    switch ((int)[UIScreen mainScreen].bounds.size.height) {
        case kIP5H:
        {
            [_scrollEditProfile setContentSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, _scrollEditProfile.frame.size.height + 450)];
        }
            break;
        case kIP6H:
            [_scrollEditProfile setContentSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, _scrollEditProfile.frame.size.height + 400)];
            break;
        case kIP6PH:
            [_scrollEditProfile setContentSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, _scrollEditProfile.frame.size.height + 400)];
            break;
        default:
            break;
    }
    [self.view endEditing:YES];
    [UIView animateWithDuration:0.5 animations:^{
        self.view.center = CGPointMake(self.view.center.x, ([UIScreen mainScreen].bounds.size.height + 64)/2);
    }];
}

- (IBAction)touchUploadAvatar:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NULL message:NULL preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Take Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imgPicker.allowsEditing = YES;
        imgPicker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        [self presentViewController:imgPicker animated:YES completion:nil];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Choose existing photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imgPicker.allowsEditing = YES;
        [self presentViewController:imgPicker animated:YES completion:nil];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [alertController dismissViewControllerAnimated:YES completion:nil];
    }]];
    // for ipad
    if ([UIScreen mainScreen].bounds.size.height > kIP6PH) {
        UIPopoverPresentationController *popPresenter = [alertController
                                                         popoverPresentationController];
        popPresenter.sourceView = _btnUploadAvatar;
        popPresenter.sourceRect = _btnUploadAvatar.bounds;
    }
    // end for ipad
    [self presentViewController:alertController animated:YES completion:^{
        
    }];
}

- (void)uploadAvatar : (UIImage *)img
{
    
    [[AppDelegate shareInstance] showProgressHub];
    NSData *data = UIImageJPEGRepresentation(img, 0.5);
    NSString *encodeImg = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    
    NSDictionary *dictAccount = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultLogin];
    NSString *strLinkCalendar = [NSString stringWithFormat:@"%@%@", kLink, kUploadAvatar];
    NSURL *url = [NSURL URLWithString:strLinkCalendar];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.HTTPAdditionalHeaders = @{@"token":[dictAccount valueForKey:@"token"]};
    
    NSDictionary *parameter = @{
                                @"patientid":[dictAccount valueForKey:@"PatientId"],
                                @"avatar":encodeImg
                                };
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:url
                                                             sessionConfiguration:config];
    [manager.requestSerializer setTimeoutInterval:kMaxTimeOut];
    [manager PUT:@"" parameters:parameter success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"responseObject = %@", responseObject);
        NSLog(@"gegwe = %d", [[responseObject objectForKey:@"success"] intValue]);
        NSString *strTitle = @"";
        NSString *strMessage = @"";
        if ([[responseObject objectForKey:@"success"] intValue] == 1) {
            strTitle = @"Success";
            strMessage = @"Upload Avatar success.";
            _imgAvatar.image = img;
        }else{
            strTitle = @"Fail";
            strMessage = @"Please try again.";
        }
        
        UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:strTitle message:strMessage preferredStyle:UIAlertControllerStyleAlert];
        [alertControl addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [alertControl dismissViewControllerAnimated:YES completion:nil];
        }]];
        [[AppDelegate shareInstance] hideProgressHub];
        [self presentViewController:alertControl animated:YES completion:nil];
        
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

#pragma mark UIImagePickerController Delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    NSLog(@"info = %@", info);
    [imgPicker dismissViewControllerAnimated:YES completion:nil];
//    _imgAvatar.image = [info objectForKey:UIImagePickerControllerEditedImage];
//    [self performSelectorInBackground:@selector(uploadAvatar) withObject:nil];
    [self uploadAvatar:[info objectForKey:UIImagePickerControllerEditedImage]];
}

#pragma mark UITextField Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    [UIView animateWithDuration:0.5 animations:^{
        NSLog(@"textField.frame.origin.y = %f", textField.frame.origin.y);
        switch ((int)[UIScreen mainScreen].bounds.size.height) {
            case kIP5H:
            {
                [_scrollEditProfile setContentSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, _scrollEditProfile.frame.size.height)];
                    self.view.center = CGPointMake(self.view.center.x, self.view.frame.size.height - textField.frame.origin.y - _viewTop.frame.size.height);
            }
                break;
            case kIP6H:
            {
                [_scrollEditProfile setContentSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, _scrollEditProfile.frame.size.height - (kIP6H - kIP5H))];
                self.view.center = CGPointMake(self.view.center.x, self.view.frame.size.height - textField.frame.origin.y - _viewTop.frame.size.height - (kIP6H - kIP5H));
            }
                break;
            case kIP6PH:
            {
                [_scrollEditProfile setContentSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, _scrollEditProfile.frame.size.height - (kIP6PH - kIP5H))];
                self.view.center = CGPointMake(self.view.center.x, self.view.frame.size.height - textField.frame.origin.y - _viewTop.frame.size.height - (kIP6PH - kIP5H));
            }
                break;
            default:
                break;
        }
        NSLog(@"self.view.center = %f", self.view.center.y);
    }];
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField == self.txtZipCode && self.txtZipCode.text.length == 5) {
        [[AppDelegate shareInstance] showProgressHub];
        [self performSelectorInBackground:@selector(getStateCity) withObject:NULL];
    }else if (textField == self.txtZipCode && self.txtZipCode.text.length < 5){
        UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:@"Warning" message:@"Zip code entered is less than 5 digits. Please re-enter your zip code." preferredStyle:UIAlertControllerStyleAlert];
        [alertControl addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [alertControl dismissViewControllerAnimated:YES completion:nil];
        }]];

        [self presentViewController:alertControl animated:YES completion:nil];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSInteger nextTag = textField.tag + 1;
    UIResponder *response = [textField.superview viewWithTag:nextTag];
    if (response != NULL) {
        [response becomeFirstResponder];
    }
    else{
        [self hideKeyboard];
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{

    if (textField == self.txtZipCode) {
        NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        NSError *error = nil;
        NSString *strExpress = @"^([0-9]+)?$";
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:strExpress options:0 error:&error];
        NSInteger numberOfMatch = [regex numberOfMatchesInString:newString options:0 range:NSMakeRange(0, [newString length])];
        if (numberOfMatch == 0)
            return NO;
    }

    if (textField == self.txtCellPhone || textField == self.txtHomePhone || textField == self.txtPhone) {

        NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        NSError *error = nil;
        NSString *strExpress = @"^([0-9-() ]+)?$";
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:strExpress options:0 error:&error];
        NSInteger numberOfMatch = [regex numberOfMatchesInString:newString options:0 range:NSMakeRange(0, [newString length])];
        if (numberOfMatch == 0)
            return NO;

        int length = (int)[self getLength:textField.text];
            //NSLog(@"Length  =  %d ",length);

        if(length == 10){
            if(range.length == 0)
                return NO;
        }

        if(length == 3){
            NSString *num = [self formatNumber:textField.text];
            textField.text = [NSString stringWithFormat:@"(%@) ",num];

            if(range.length > 0)
                textField.text = [NSString stringWithFormat:@"%@",[num substringToIndex:3]];
        }
        else if(length == 6){
            NSString *num = [self formatNumber:textField.text];
                //NSLog(@"%@",[num  substringToIndex:3]);
                //NSLog(@"%@",[num substringFromIndex:3]);
            textField.text = [NSString stringWithFormat:@"(%@) %@-",[num  substringToIndex:3],[num substringFromIndex:3]];

            if(range.length > 0)
                textField.text = [NSString stringWithFormat:@"(%@) %@",[num substringToIndex:3],[num substringFromIndex:3]];
        }
    }
    return YES;
}

- (NSString *)formatNumber:(NSString *)mobileNumber
{
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];

    NSLog(@"%@", mobileNumber);

    int length = (int)[mobileNumber length];
    if(length > 10)
        {
        mobileNumber = [mobileNumber substringFromIndex: length-10];
        NSLog(@"%@", mobileNumber);

        }

    return mobileNumber;
}

- (int)getLength:(NSString *)mobileNumber
{
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];

    int length = (int)[mobileNumber length];

    return length;
}

- (IBAction)switchChanged:(id)sender {
    
}
@end
