//
//  CalendarViewController.m
//  InterV
//
//  Created by HungLe on 10/4/16.
//  Copyright © 2016 HungLe. All rights reserved.
//

#import "CalendarViewController.h"
#import "NSDictionary+Calendar.h"

#import "CLWeeklyCalendarView.h"

#import "CRSpotCheck.h"
#import "CRCreativeSDK.h"

#define E_BODY_DEVICE_INFO_SERVICE_UUID @"180A"       // 180A = Device Information
#define E_BODY_SERVICE_UUID @"FFF0"// @"181D"//@"180D"        // 180D = Heart Rate Service
#define E_BODY_ENABLE_SERVICE_UUID @"FFF4"//@"2A39"
#define E_BODY_NOTIFICATIONS_SERVICE_UUID @"FFF1"//@"2A37"
#define E_BODY_LOCATION_UUID @"FFF2"//@"2A38"
#define E_BODY_MANUFACTURER_NAME_UUID @"2A29"

@interface CalendarViewController ()
<
CLWeeklyCalendarViewDelegate,
UITableViewDelegate,
UITableViewDataSource,
UIGestureRecognizerDelegate,
CreativeDelegate,
SpotCheckDelegate,
CBPeripheralDelegate,
CBCentralManagerDelegate
>
{
    NSString *strDate;
    NSInteger indexTakeMeasurement;
    int spo2, pr;
    
    UIButton *btnCurrendDate;
    
    BOOL checkError;
    
    UIAlertController *alertCo;
    UIAlertAction *actionCoOk;
    UIAlertAction *actionCoInputResultOk;
    NSString *strText;
    
    NSMutableDictionary *dictInputTextSurvey;
    
    /// BLE e-body
    
}
@property (nonatomic, strong) CLWeeklyCalendarView* calendarView;

typedef enum : int{
    BP = 2,
    SpO2 = 4,
    Heart_Rate = 9,
    Temperature = 3,
    SideEffect = 8,
    Survey = -1,
    Weight = 7,
    Self_Monitoring_of_Blood_Glucose = 422,
    FEV1 = 418,
    FEV1FVC = 419,
    FVC = 417,
    // moi them
    CovidLevel1 = 737,
    CovidLevel2 = 738,
    CovidLevel3 = 739,
    // end moi them
} PatientCalendarTypeId;

@end

static CGFloat CALENDER_VIEW_HEIGHT = 90.f;
static CalendarViewController *_instance;
@implementation CalendarViewController{
    // machine
    CreativePeripheral *currentPort;
    NSMutableArray *foundPorts;
    // end machine
}

+ (CalendarViewController*)ShareInstance{
    return _instance;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // for survey
    _btnSurveyReminder.layer.cornerRadius = 5.0;
    _btnSurveyReminder.clipsToBounds = YES;
    _btnSendSurvey.layer.cornerRadius = 5.0;
    _btnSendSurvey.clipsToBounds = YES;
    
    arraySurvey = [[NSMutableArray alloc] init];
    arraySurveyParse = [[NSMutableArray alloc] init];
    arrayQuestion = [[NSMutableArray alloc] init];
    dictInputTextSurvey = [[NSMutableDictionary alloc] init];
    
    arrayIDRegisterPushNotifications = [[NSMutableArray alloc] init];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kArrayIDRegisterPushNotifications] != NULL) {
        arrayIDRegisterPushNotifications = (NSMutableArray*)[[NSUserDefaults standardUserDefaults] objectForKey:kArrayIDRegisterPushNotifications];
    }
    
    _tableViewSurvey.estimatedRowHeight = 150.0f;
    _tableViewSurvey.rowHeight = UITableViewAutomaticDimension;
    [_tableViewSurvey setNeedsLayout];
    [_tableViewSurvey layoutIfNeeded];

    _tableViewCalendar.estimatedRowHeight = 150.0f;
    _tableViewCalendar.rowHeight = UITableViewAutomaticDimension;
    [_tableViewCalendar setNeedsLayout];
    [_tableViewCalendar layoutIfNeeded];

    // end for survey
    alertCo = [UIAlertController alertControllerWithTitle:@"INSTRUCTION" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    actionCoOk = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [alertCo dismissViewControllerAnimated:YES completion:nil];
    }];
    [alertCo addAction:actionCoOk];
    
    arrayCalendar = [[NSMutableArray alloc] init];
    arraySideBar = [[NSMutableArray alloc] init];
    arraySideBarFilter = [[NSMutableArray alloc] init];
    arraySideEffectChoise = [[NSMutableArray alloc] init];
    
    checkError = false;
    _instance = self;
    self.navigationController.navigationBar.barTintColor = [Settings setColorBG];
    self.navigationController.navigationBar.translucent = NO;

    UIView *customTitleView = [[CustomTitleViewNAV alloc] initWithFrame:self.navigationController.navigationBar.bounds];
    self.navigationItem.titleView = customTitleView;

    btnCurrendDate = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.navigationItem.titleView.frame.size.width, self.navigationItem.titleView.frame.size.height)];
    btnCurrendDate.backgroundColor = [UIColor clearColor];
    btnCurrendDate.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
    [btnCurrendDate setTitleColor:[Settings setColorText] forState:UIControlStateNormal];
    [btnCurrendDate addTarget:self action:@selector(getCurrentDate) forControlEvents:UIControlEventTouchUpInside];

    self.navigationItem.titleView = btnCurrendDate;

    NSLog(@"title view = %f", self.navigationItem.titleView.frame.size.width);

    UIImage *imgLeft = [UIImage imageNamed:@"IconCalendarDeActive"];
    UIButton *btnLeft = [UIButton buttonWithType:UIButtonTypeCustom];
    btnLeft.bounds = CGRectMake(0, 0, imgLeft.size.width, imgLeft.size.height);
    [btnLeft setImage:imgLeft forState:UIControlStateNormal];
    [btnLeft addTarget:self action:@selector(showCalendar) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *itemLeft = [[UIBarButtonItem alloc] initWithCustomView:btnLeft];
    
    self.navigationItem.leftBarButtonItem = itemLeft;
    
//    UIImage *imgRight = [UIImage imageNamed:@"IconLogout"];
//    UIButton *btnRight = [UIButton buttonWithType:UIButtonTypeCustom];
//    btnRight.bounds = CGRectMake(0, 0, imgRight.size.width, imgRight.size.height);
//    [btnRight setImage:imgRight forState:UIControlStateNormal];
//    [btnRight addTarget:self action:@selector(touchLogout) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *itemRight = [[UIBarButtonItem alloc] initWithCustomView:btnRight];
//    self.navigationItem.rightBarButtonItem = itemRight;
    
    _datePicker.datePickerMode = UIDatePickerModeDate;
    
    dictCalendar = [[NSDictionary alloc] init];
    
    self.tableViewCalendar.separatorColor = [UIColor clearColor];
    self.tableViewCalendar.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // side effect
    _btnSideEffectOk.layer.cornerRadius = 5.0;
    _btnSideEffectOk.clipsToBounds = YES;
    _btnSideEffectCancel.layer.cornerRadius = 5.0;
    _btnSideEffectCancel.clipsToBounds = YES;
    // end side effect
    
    // machine
    [CRCreativeSDK sharedInstance].delegate = self;
    [CRSpotCheck sharedInstance].delegate = self;
    // end machine
    
    [_txtNameSideEffect addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];

    [Settings setBottomLB:_lblTitleSurveyTouch];
    
    // BLE
//    CBCentralManager *centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];
//    self.centralManager = centralManager;
    // end BLE
}

- (void)viewWillAppear:(BOOL)animated{
    if ([self.calendarView isDescendantOfView:self.view]) {
        [[AppDelegate shareInstance] showProgressHub];
        [self performSelectorInBackground:@selector(getListCalendar) withObject:nil];
    }
//    [self getListSurvey];
    [self.view addSubview:self.calendarView];
    [self.view bringSubviewToFront:_viewPickerDate];
    [self.view bringSubviewToFront:_viewTableView];
    [self.view bringSubviewToFront:_viewSurvey];
    
    // get long polling
    timer = [NSTimer scheduledTimerWithTimeInterval:10.0f target:self selector:@selector(getEventImmediately) userInfo:nil repeats:YES];

//    [self getListSideBar];
    [self performSelectorInBackground:@selector(getListSideBar) withObject:nil];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[Settings setColorText]}];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MM/dd/yyyy";
    [_datePicker setDate:[dateFormatter dateFromString:strDate]];
    
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *eventArray = [app scheduledLocalNotifications];
    NSLog(@"eventArray = %@", eventArray);
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [timer invalidate];
    timer = nil;
    // kill all banner
    [ALAlertBanner forceHideAllAlertBannersInView:self.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getListCalendar{
    NSDictionary *dictAccount = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultLogin];
    NSString *strLinkCalendar = [NSString stringWithFormat:@"%@%@", kLink, kCalendar];
    NSURL *url = [NSURL URLWithString:strLinkCalendar];
//    NSDictionary *parameter = @{
//                                @"id":[dictAccount valueForKey:@"PatientId"],
//                                @"datetime":strDate
//                                };
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.HTTPAdditionalHeaders = @{@"token":[dictAccount valueForKey:@"token"]};
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:url sessionConfiguration:config];
    
    NSLog(@"strDate = %@", strDate);
    NSLog(@"egre = %@", [NSString stringWithFormat:@"?id=%@&datetime=%@", [Settings EnCryptionString:[dictAccount valueForKey:@"PatientId"]], [Settings URLEncodeStringFromString:[Settings EnCryptionString:strDate]]]);
    
    NSLog(@"decryption id = %@", [Settings DeCryptionString:[Settings EnCryptionString:[dictAccount valueForKey:@"PatientId"]]]);
    
    NSString *strTemp = [NSString stringWithFormat:@"?id=%@&datetime=%@", [[[Settings EnCryptionString:[dictAccount valueForKey:@"PatientId"]] dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength], [[[Settings EnCryptionString:strDate] dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength]];
    NSLog(@"strTemp = %@", strTemp);
    
    NSLog(@"gewg = %@", [[[Settings URLEncodeStringFromString:[Settings EnCryptionString:strDate]] dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength]);
    
    [manager.operationQueue cancelAllOperations];
    [manager.requestSerializer setTimeoutInterval:kMaxTimeOut];
    [manager GET:[NSString stringWithFormat:@"?id=%@&datetime=%@", [[[Settings EnCryptionString:[dictAccount valueForKey:@"PatientId"]] dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength], [[[Settings EnCryptionString:strDate] dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength]] parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"responseObject  t calendar = %@", responseObject);
        
        NSDictionary *dict = (NSDictionary *)responseObject;
        if ([[dict valueForKey:@"success"] intValue] == 1) {
            arrayCalendar = [Settings DeCryptionData:[dict valueForKey:@"response"]];
            NSLog(@"dictDescrypt = %@", arrayCalendar);

            // register local push notifications

            NSDate *date = [NSDate date];
            NSDateFormatter *format = [[NSDateFormatter alloc] init];
            [format setDateFormat:@"MM/dd/yyyy"];

            NSNumber *numberSecondsCurrent = [self timeCurrent];

            for (int i = 0; i < arrayCalendar.count; i++) {
                NSDictionary *dictTemp = (NSDictionary *)[arrayCalendar objectAtIndex:i];
                NSLog(@"dictTemp = %@", dictTemp);
                NSNumber *numberSecond = [self timeEvent:dictTemp];
                if ([strDate isEqualToString:[format stringFromDate:date]]){
                    if ([numberSecondsCurrent intValue] < [numberSecond intValue]) {
                        if (![arrayIDRegisterPushNotifications containsObject:[NSString stringWithFormat:@"%@%@", [dictTemp Id], [dictTemp Time]]]) {
                            NSMutableArray *arrTPush = [arrayIDRegisterPushNotifications mutableCopy];
                            [arrTPush addObject:[NSString stringWithFormat:@"%@%@", [dictTemp Id], [dictTemp Time]]];
                            arrayIDRegisterPushNotifications = [NSMutableArray arrayWithArray:arrTPush];
                            [[NSUserDefaults standardUserDefaults] setObject:arrayIDRegisterPushNotifications forKey:kArrayIDRegisterPushNotifications];
                            [[NSUserDefaults standardUserDefaults] synchronize];

                            NSArray *arrTime = [[dictTemp Time] componentsSeparatedByString:@":"];
                            NSInteger hour = [[arrTime objectAtIndex:0] integerValue] - [[dictTemp Earlytimehour] integerValue];
                            NSString *timer = [NSString stringWithFormat:@"%ld:%@", (long)hour, [arrTime objectAtIndex:1]];
                            [self scheduleLocalNotification:timer alertBody:[dictTemp DisplayName]];
                            // schedule local notification for duration time (key time valid)
                            // event time - early time + time valid - 1
                            [self scheduleLocalNotification:[NSString stringWithFormat:@"%d:%@", hour + [[dictTemp timeValid] integerValue] - 1, [arrTime objectAtIndex:1]] alertBody:[dictTemp DisplayName]];
                        }
                    }
                }
            }
//            NSLog(@"count = %d", arrayIDRegisterPushNotifications.count);
            [[NSUserDefaults standardUserDefaults] setObject:arrayIDRegisterPushNotifications forKey:kArrayIDRegisterPushNotifications];
            [[NSUserDefaults standardUserDefaults] synchronize];
            // end register local push notifications
            [self performSelectorOnMainThread:@selector(refreshGUICalendar) withObject:nil waitUntilDone:YES];
        }
        else{
            UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:@"Information" message:[dict objectForKey:@"message"] preferredStyle:UIAlertControllerStyleAlert];
            [alertControl addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [alertControl dismissViewControllerAnimated:YES completion:nil];
            }]];
            [[AppDelegate shareInstance] hideProgressHub];
            [self presentViewController:alertControl animated:YES completion:nil];
        }
//        if ([responseObject count] > 0) {
//            dictCalendar = (NSDictionary*)responseObject;
//            arrayCalendar = (NSMutableArray *)[dictCalendar results];
//            [self performSelectorOnMainThread:@selector(refreshGUICalendar) withObject:nil waitUntilDone:YES];
//        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:@"Warning!" message:@"Please check internet and try again." preferredStyle:UIAlertControllerStyleAlert];
        [alertControl addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [alertControl dismissViewControllerAnimated:YES completion:nil];
        }]];
        [[AppDelegate shareInstance] hideProgressHub];
        [self presentViewController:alertControl animated:YES completion:nil];
    }];
}

- (void)getListSideBar{
    NSDictionary *dictAccount = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultLogin];
    NSString *strLinkCalendar = [NSString stringWithFormat:@"%@%@", kLink, kCalendar];
    NSURL *url = [NSURL URLWithString:strLinkCalendar];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.HTTPAdditionalHeaders = @{@"token":[dictAccount valueForKey:@"token"]};
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:url sessionConfiguration:config];
    [manager.operationQueue cancelAllOperations];
    [manager.requestSerializer setTimeoutInterval:kMaxTimeOut];
    [manager GET:@"" parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        NSDictionary *dict = (NSDictionary *)[responseObject objectForKey:@"results"];
        if ([[responseObject objectForKey:@"success"] intValue] == 1) {
            NSLog(@"gewg = %u", [[responseObject objectForKey:@"results"] count]);
//            NSLog(@"array result = %@", [Settings DeCryptionData:[responseObject objectForKey:@"results"]]);
            NSMutableArray *arrTemp = [responseObject objectForKey:@"results"];
            [arraySideBar removeAllObjects];
            for (int i = 0; i < arrTemp.count; i++) {
                NSLog(@"gewgw %d = %@", i, [Settings DeCryptionString:[arrTemp objectAtIndex:i]]);
                [arraySideBar addObject:[Settings DeCryptionString:[arrTemp objectAtIndex:i]]];
            }
//            arrayCalendar = [Settings DeCryptionData:[dict valueForKey:@"response"]];
//            arraySideBar = (NSMutableArray *)[responseObject objectForKey:@"results"];
//            arraySideBar = [];
            NSLog(@"dictDescrypt = %@", arrayCalendar);
            [self performSelectorOnMainThread:@selector(refreshGUICalendar) withObject:nil waitUntilDone:YES];
        }
//        arraySideBar = (NSMutableArray *)[responseObject objectForKey:@"results"];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:@"Warning!" message:@"Please check internet and try again." preferredStyle:UIAlertControllerStyleAlert];
        [alertControl addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [alertControl dismissViewControllerAnimated:YES completion:nil];
        }]];
        [[AppDelegate shareInstance] hideProgressHub];
        [self presentViewController:alertControl animated:YES completion:nil];
    }];
}

// get new event Immediate
- (void)getEventImmediately{
    NSDictionary *dictAccount = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultLogin];
    NSString *strLinkCalendar = [NSString stringWithFormat:@"%@%@", kLink, kCalendar];
    NSURL *url = [NSURL URLWithString:strLinkCalendar];
//    NSDictionary *parameter = @{
//                                @"id":[dictAccount valueForKey:@"PatientId"]
//                                };
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.HTTPAdditionalHeaders = @{@"token":[dictAccount valueForKey:@"token"]};
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:url sessionConfiguration:config];
    
    [manager.operationQueue cancelAllOperations];
    [manager.requestSerializer setTimeoutInterval:kMaxTimeOut];
    [manager GET:[NSString stringWithFormat:@"?id=%@", [[[Settings EnCryptionString:[dictAccount valueForKey:@"PatientId"]] dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength]] parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([[responseObject objectForKey:@"success"] intValue] == 1) {
            [self performSelectorInBackground:@selector(getListCalendar) withObject:nil];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error = %@", error);
    }];
}

- (void)showCalendar{
    self.navigationController.navigationBarHidden = YES;
    self.tabBarController.tabBar.hidden = YES;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MM/dd/yyyy";
    [_datePicker setDate:[dateFormatter dateFromString:strDate]];
    _viewPickerDate.hidden = NO;
}

- (void)touchLogout{
    UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:@"Warning!" message:@"Do you want to log out?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // register ID local push notifications
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kArrayIDRegisterPushNotifications];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserDefaultLogin];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kReminderSurvey];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kDictInputTextSurvey];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kArraySurvey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[[AppDelegate shareInstance] tabbar] setSelectedIndex:0];
        [[AppDelegate shareInstance] CheckLogin];
        [alertControl dismissViewControllerAnimated:YES completion:nil];
    }];
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [alertControl dismissViewControllerAnimated:YES completion:nil];
    }];
    [alertControl addAction:actionOk];
    [alertControl addAction:actionCancel];
    [self presentViewController:alertControl animated:YES completion:nil];
}

- (void)getCurrentDate{
    [[CLWeeklyCalendarView ShareInstance] redrawToDate:[NSDate new]];
}

- (void)refreshGUICalendar{
    
    [self.tableViewCalendar reloadData];
    [[AppDelegate shareInstance] hideProgressHub];
}

- (NSNumber *)timeEvent : (NSDictionary *)dictTemp{
    NSArray *arrTime = [[dictTemp Time] componentsSeparatedByString:@":"];
    NSInteger hours;
    if ([[arrTime objectAtIndex:1] componentsSeparatedByString:@" "].count > 1) {
        if ([[[[arrTime objectAtIndex:1] componentsSeparatedByString:@" "] objectAtIndex:1].uppercaseString isEqualToString:@"PM"]) {
                //                hours = [[arrTime objectAtIndex:0] integerValue] + 12;

            if ([[arrTime objectAtIndex:0] integerValue] != 12) {
                hours = [[arrTime objectAtIndex:0] integerValue] + 12;
            }else{
                    // 12:00 PM nen minh ko cong them 12h
                hours = [[arrTime objectAtIndex:0] integerValue];
            }
        }else{
                // 12:00 AM nen minh  tru 12h ==> 0h
            if ([[arrTime objectAtIndex:0] integerValue] == 12) {
                hours = [[arrTime objectAtIndex:0] integerValue] - 12;
            }else
                hours = [[arrTime objectAtIndex:0] integerValue];
        }
    }else{
        hours = [[arrTime objectAtIndex:0] integerValue];
    }
    NSInteger minutes = [[[[arrTime objectAtIndex:1] componentsSeparatedByString:@" "] objectAtIndex:0] integerValue];
        //        NSNumber *numberSecondEarlyTime = [NSNumber numberWithInteger:[[dictTemp Earlytimehour] integerValue]*60*60];
    NSNumber *numberSecond = [NSNumber numberWithInteger:hours*60*60 + minutes*60 - [[dictTemp Earlytimehour] integerValue]*60*60];
    return numberSecond;
}

- (NSNumber *)timeCurrent {
    NSDate *date = [NSDate date];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"hh:mm a"];
    NSArray *arrCurentTimeType = [[format stringFromDate:date] componentsSeparatedByString:@" "];
    NSArray *arrCurrentTime;
    NSInteger hoursCurrent;
    NSInteger minutesCurrent;
    [format setDateFormat:@"hh:mm"];
    arrCurrentTime = [[format stringFromDate:date] componentsSeparatedByString:@":"];
    NSLog(@"arrCurentTimeType = %@", arrCurentTimeType);
    if (arrCurentTimeType.count > 1) {
        if ([[[arrCurentTimeType objectAtIndex:1] uppercaseString] isEqualToString:@"PM"]) {
                //                hoursCurrent = [[arrCurrentTime objectAtIndex:0] integerValue] + 12;// PM

            if ([[arrCurrentTime objectAtIndex:0] integerValue] != 12) {
                hoursCurrent = [[arrCurrentTime objectAtIndex:0] integerValue] + 12;// PM
            }else{
                hoursCurrent = [[arrCurrentTime objectAtIndex:0] integerValue];// PM
            }
        }
        else{
                // 12:00 AM nen minh  tru 12h ==> 0h
            if ([[arrCurrentTime objectAtIndex:0] integerValue] == 12) {
                hoursCurrent = [[arrCurrentTime objectAtIndex:0] integerValue] - 12;
            }else
                hoursCurrent = [[arrCurrentTime objectAtIndex:0] integerValue];// AM
        }
        minutesCurrent = [[arrCurrentTime objectAtIndex:1] integerValue];
    }else{
        hoursCurrent = [[arrCurrentTime objectAtIndex:0] integerValue];
        minutesCurrent = [[arrCurrentTime objectAtIndex:1] integerValue];
    }

    NSNumber *numberSecondsCurrent = [NSNumber numberWithInteger:hoursCurrent*60*60 + minutesCurrent*60];
    return numberSecondsCurrent;
}

- (void)showAlertBannerTop : (NSString *)string view : (UIView *)view{
    ALAlertBanner *banner = [ALAlertBanner alertBannerForView:view style:ALAlertBannerStyleNotify position:ALAlertBannerPositionTop title:string subtitle:nil tappedBlock:^(ALAlertBanner *alertBanner) {
        [alertBanner hide];
    }];
    [banner show];
}

#pragma Week Calendar

//Initialize
-(CLWeeklyCalendarView *)calendarView
{
    NSLog(@"_calendarView = %@", _calendarView);
    if(!_calendarView){
        _calendarView = [[CLWeeklyCalendarView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, CALENDER_VIEW_HEIGHT)];
        _calendarView.delegate = self;
    }
    return _calendarView;
}

#pragma mark - CLWeeklyCalendarViewDelegate
-(NSDictionary *)CLCalendarBehaviorAttributes
{
    return @{
             CLCalendarWeekStartDay : @1,                 //Start Day of the week, from 1-7 Mon-Sun -- default 1
             //             CLCalendarDayTitleTextColor : [UIColor yellowColor],
             //             CLCalendarSelectedDatePrintColor : [UIColor greenColor],
             };
}

-(void)dailyCalendarViewDidSelect:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    strDate = [dateFormatter stringFromDate:date];
    [btnCurrendDate setTitle:[self.calendarView dateInfoLabel].text forState:UIControlStateNormal];
    [[AppDelegate shareInstance] showProgressHub];
    [self performSelectorInBackground:@selector(getListCalendar) withObject:nil];
}

// touch up inside input result

- (void)touchInputResult : (id)sender{
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"MM/dd/yyyy"];
    NSDate *dateNow = [NSDate date];
    UIButton *btn = (UIButton *)sender;
//    NSArray *arr = (NSArray*)[dictCalendar results];
    NSDictionary *dictTemp = [arrayCalendar objectAtIndex:btn.tag];
    NSLog(@"dictTemp = %@",dictTemp);
    // moi them
    index = btn.tag;
    // end moi them
    if ([dictTemp.PatientCalendarTypeId intValue] == SideEffect) {
        _btnSideEffectOk.tag = btn.tag;
        self.navigationController.navigationBarHidden = YES;
        self.tabBarController.tabBar.hidden = YES;
        [_txtNameSideEffect becomeFirstResponder];
        _tableViewSideEffect.hidden = YES;
        _viewTableView.hidden = NO;
        [_viewTableView bringSubviewToFront:_tableViewSideEffect];
        [_tableViewSideEffect reloadData];
    }
    else if ([dictTemp.PatientCalendarTypeId intValue] == Survey){
        // if btnreminder survey tag = btn.tag
        // not call api getlistsurvey
        // else call api getlistsurvey
        _btnSendSurvey.tag = btn.tag;
        
        // check save for later
        NSLog(@"kEventIDSurvey = %@", [[NSUserDefaults standardUserDefaults] valueForKey:kEventIDSurvey]);
        NSDictionary *dTemp = [arrayCalendar objectAtIndex:_btnSendSurvey.tag];
        NSLog(@"dTemp = %@", dTemp);
        if ([[dTemp valueForKey:@"Id"] isEqualToString:[[NSUserDefaults standardUserDefaults] valueForKey:kEventIDSurvey]]) {
            if (arraySurveyParse.count > 0) {
                [self performSelectorOnMainThread:@selector(refreshUISurvey) withObject:nil waitUntilDone:YES];
            }else{
                NSMutableArray *arrTemp = [[NSUserDefaults standardUserDefaults] objectForKey:kReminderSurvey];
                arraySurveyParse = [arrTemp mutableCopy];
                NSMutableDictionary *dictTemp = [[NSUserDefaults standardUserDefaults] objectForKey:kDictInputTextSurvey];
                dictInputTextSurvey = [dictTemp mutableCopy];
                NSMutableArray *arrSurveyTemp = [[NSUserDefaults standardUserDefaults] objectForKey:kArraySurvey];
                arraySurvey = [arrSurveyTemp mutableCopy];
                [self performSelectorOnMainThread:@selector(refreshUISurvey) withObject:nil waitUntilDone:YES];
            }
        }
        // end check save for later
        else{
            [[NSUserDefaults standardUserDefaults] setObject:[dTemp valueForKey:@"Id"] forKey:kEventIDSurvey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            if (_btnSurveyReminder.tag != btn.tag) {
    //            [arraySurveyParse removeAllObjects];
                if (arraySurveyParse.count > 0) {
                    [arraySurveyParse removeAllObjects];
                    [_tableViewSurvey reloadData];
                }
    //            SAFE_RELEASE_ARRAY(arraySurveyParse);
    //            [_tableViewSurvey reloadData];
                
                _btnSurveyReminder.tag = -1;
                [[AppDelegate shareInstance] showProgressHub];
                [self performSelectorInBackground:@selector(getListSurvey) withObject:nil];
            }else{
                [self performSelectorOnMainThread:@selector(refreshUISurvey) withObject:nil waitUntilDone:YES];
            }
        }
    }
    else{
        UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:[dictTemp DisplayName] message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alertControl addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.delegate = self;
            textField.keyboardType = UIKeyboardTypeDefault;

            [textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
            if ([dictTemp.PatientCalendarTypeId intValue] == SpO2) {
                NSAttributedString * placeholder = [[NSAttributedString alloc] initWithString:@"Enter format as X,Y for SpO2,Pulse." attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor], NSFontAttributeName : [UIFont systemFontOfSize:12.0]}];
                textField.attributedPlaceholder = placeholder;
                textField.tag = 35;
                textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
            }
            else if ([dictTemp.PatientCalendarTypeId intValue] == BP){

                NSAttributedString * placeholder = [[NSAttributedString alloc] initWithString:@"Enter format as X/Y,Z for Systolic/Diastolic,Pulse." attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor], NSFontAttributeName : [UIFont systemFontOfSize:9.3]}];
                textField.attributedPlaceholder = placeholder;
                textField.tag = 36;
                textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
            }else if ([dictTemp.PatientCalendarTypeId intValue] == Heart_Rate){
                textField.tag = 37;
                textField.keyboardType = UIKeyboardTypeNumberPad;
                textField.placeholder = @"Enter format as X for Pulse.";
            }else if ([dictTemp.PatientCalendarTypeId intValue] == Temperature){
                textField.tag = 38;
                textField.keyboardType = UIKeyboardTypeDecimalPad;
                textField.placeholder = @"Enter format as X for Temperature.";
            }
            else{
                textField.tag = 39;
                textField.placeholder = @"Input";
                if ([dictTemp.InputType intValue] == 2) {
                    textField.keyboardType = UIKeyboardTypeNumberPad;
                }
            }
            textField.text = [dictTemp Value];
        }];
        actionCoInputResultOk = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [alertControl dismissViewControllerAnimated:YES completion:nil];
            
            if ([dictTemp.PatientCalendarTypeId intValue] == BP ||
                [dictTemp.PatientCalendarTypeId intValue] == SpO2 ||
                [dictTemp.PatientCalendarTypeId intValue] == Temperature ||
                [dictTemp.PatientCalendarTypeId intValue] == Heart_Rate
                ) {
                NSDictionary *dictPattern = [Settings checkPattern:[dictTemp.PatientCalendarTypeId intValue] :[alertControl.textFields objectAtIndex:0].text];
                if (![[dictPattern objectForKey:@"status"] boolValue]) {
                    UIAlertController *alertCTR = [UIAlertController alertControllerWithTitle:@"Warning" message:[NSString stringWithFormat:@"%@", [dictPattern objectForKey:@"message"]] preferredStyle:UIAlertControllerStyleAlert];

                    [alertCTR addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                        [alertCTR dismissViewControllerAnimated:YES completion:nil];
                        [self presentViewController:alertControl animated:YES completion:nil];
                    }]];
                    [self presentViewController:alertCTR animated:YES completion:nil];
                    return ;
                }
            }
            if ([dictTemp.PatientCalendarTypeId intValue] == BP ||
                [dictTemp.PatientCalendarTypeId intValue] == SpO2 ||
                [dictTemp.PatientCalendarTypeId intValue] == Heart_Rate ||
                [dictTemp.PatientCalendarTypeId intValue] == Temperature
                ) {
                UIAlertController *alertCTR = [UIAlertController alertControllerWithTitle:@"Confirm" message:[NSString stringWithFormat:@"Please confirm the accuracy of your result:%@", [alertControl.textFields objectAtIndex:0].text] preferredStyle:UIAlertControllerStyleAlert];
                NSMutableAttributedString *attribute = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Please confirm the accuracy of your result:%@", [alertControl.textFields objectAtIndex:0].text]];
                [attribute addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:18.0] range:NSMakeRange(43, [alertControl.textFields objectAtIndex:0].text.length)];
                [alertCTR setValue:attribute forKey:@"attributedMessage"];
                [alertCTR addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    [alertCTR dismissViewControllerAnimated:YES completion:nil];
                    [self presentViewController:alertControl animated:YES completion:nil];
                }]];
                [alertCTR addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [alertCTR dismissViewControllerAnimated:YES completion:nil];
                    [[AppDelegate shareInstance] showProgressHub];
                    NSDictionary *dictAccount = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultLogin];
                    NSDictionary *dictPost = @{
                                               @"patientid":[dictAccount valueForKey:@"PatientId"],
                                               @"results":[alertControl.textFields objectAtIndex:0].text,
                                               @"calendarId":[NSString stringWithFormat:@"%@", [dictTemp Id]],
                                               @"TimeLogId":[NSString stringWithFormat:@"%@", [dictTemp TimeLogId]],
                                               @"calendarTypeId":[NSString stringWithFormat:@"%@", [dictTemp PatientCalendarTypeId]],
                                               @"protocoltype":@"1",
                                               @"datetime":strDate,//[format stringFromDate:dateNow],
                                               @"isbaseline":[dictTemp isBaseline],// == 0 ? @"false" : @"true",
                                               @"isoverride":@"false"
                                               };
                    NSDictionary *dictParameter = @{
                                                    @"parameter":[Settings EnCryptionDictionary:dictPost]
                                                    };
                    // pass dictTemp to postInputResult check if finish event and then remove register local notification for duration time
                    NSDictionary *dPost = @{
                                            @"dictParameter" : dictParameter,
                                            @"dictTemp" : dictTemp
                                            };
//                    [self performSelectorInBackground:@selector(postInputResult:) withObject:dictParameter];
                    [self performSelectorInBackground:@selector(postInputResult:) withObject:dPost];
                }]];
                [self presentViewController:alertCTR animated:YES completion:nil];
            }else{
                [[AppDelegate shareInstance] showProgressHub];
                NSDictionary *dictAccount = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultLogin];
                NSDictionary *dictPost = @{
                                           @"patientid":[dictAccount valueForKey:@"PatientId"],
                                           @"results":[alertControl.textFields objectAtIndex:0].text,
                                           @"calendarId":[NSString stringWithFormat:@"%@", [dictTemp Id]],
                                           @"TimeLogId":[NSString stringWithFormat:@"%@", [dictTemp TimeLogId]],
                                           @"calendarTypeId":[NSString stringWithFormat:@"%@", [dictTemp PatientCalendarTypeId]],
                                           @"protocoltype":@"1",
                                           @"datetime":strDate,//[format stringFromDate:dateNow],
                                           @"isbaseline":[dictTemp isBaseline],// == 0 ? @"false" : @"true",
                                           @"isoverride":@"false"
                                           };
                NSDictionary *dictParameter = @{
                                                @"parameter":[Settings EnCryptionDictionary:dictPost]
                                                };
                // pass dictTemp to postInputResult check if finish event and then remove register local notification for duration time
                NSDictionary *dPost = @{
                                        @"dictParameter" : dictParameter,
                                        @"dictTemp" : dictTemp
                                        };
                //                    [self performSelectorInBackground:@selector(postInputResult:) withObject:dictParameter];
                [self performSelectorInBackground:@selector(postInputResult:) withObject:dPost];
            }
        }];
        [actionCoInputResultOk setEnabled:NO];
        [alertControl addAction:actionCoInputResultOk];
//        [alertControl addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            [alertControl dismissViewControllerAnimated:YES completion:nil];
//            [[AppDelegate shareInstance] showProgressHub];
//            NSDictionary *dictAccount = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultLogin];
//            NSDictionary *dictPost = @{
//                                       @"patientid":[dictAccount valueForKey:@"PatientId"],
//                                       @"results":[alertControl.textFields objectAtIndex:0].text,
//                                       @"calendarId":[NSString stringWithFormat:@"%@", [dictTemp Id]],
//                                       @"TimeLogId":[NSString stringWithFormat:@"%@", [dictTemp TimeLogId]],
//                                       @"calendarTypeId":[NSString stringWithFormat:@"%@", [dictTemp PatientCalendarTypeId]],
//                                       @"protocoltype":@"1",
//                                       @"datetime":[format stringFromDate:dateNow],
//                                       @"isbaseline":[dictTemp isBaseline],// == 0 ? @"false" : @"true",
//                                       @"isoverride":@"false"
//                                       };
//            NSDictionary *dictParameter = @{
//                                            @"parameter":[Settings EnCryptionDictionary:dictPost]
//                                            };
//            [self performSelectorInBackground:@selector(postInputResult:) withObject:dictParameter];
//        }]];
        [alertControl addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [alertControl dismissViewControllerAnimated:YES completion:nil];
        }]];
        [self presentViewController:alertControl animated:YES completion:nil];
    }
}

- (void)postInputResult:(NSDictionary *)parameter{
    NSDictionary *dictAccount = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultLogin];
    NSString *strLinkCalendar = [NSString stringWithFormat:@"%@%@", kLink, kCalendar];
    NSURL *url = [NSURL URLWithString:strLinkCalendar];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.HTTPAdditionalHeaders = @{@"token":[dictAccount valueForKey:@"token"]};
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:url sessionConfiguration:config];
    [manager.requestSerializer setTimeoutInterval:kMaxTimeOut];
    [manager PUT:@"" parameters:[parameter objectForKey:@"dictParameter"] success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *dict = (NSDictionary *)responseObject;
        if ([[dict valueForKey:@"success"] intValue] == 1) {
//            [self performSelectorOnMainThread:@selector(refreshGUICalendar) withObject:nil waitUntilDone:YES];
            // clear register local push notification with time duration when early time complete event
            UIApplication *app = [UIApplication sharedApplication];
            NSArray *eventArray = [app scheduledLocalNotifications];
            NSLog(@"eventArray = %@", eventArray);
//            hour + [[dictTemp timeValid] integerValue] - 1
            NSArray *arrTime = [[[parameter objectForKey:@"dictTemp"] Time] componentsSeparatedByString:@":"];
            NSInteger hour = [[arrTime objectAtIndex:0] integerValue] - [[[parameter objectForKey:@"dictTemp"] Earlytimehour] integerValue];
            
//            [self scheduleLocalNotification:[NSString stringWithFormat:@"%d:%@", hour + [[[parameter objectForKey:@"dictTemp"] timeValid] integerValue] - 1, [arrTime objectAtIndex:1]] alertBody:[[parameter objectForKey:@"dictTemp"] DisplayName]];
            NSString *strRemoveNotifications = [NSString stringWithFormat:@"%d:%@%@",hour + [[[parameter objectForKey:@"dictTemp"] timeValid] integerValue] - 1, [arrTime objectAtIndex:1], [[parameter objectForKey:@"dictTemp"] DisplayName]];
            for (int i=0; i<[eventArray count]; i++)
            {
                UILocalNotification* oneEvent = [eventArray objectAtIndex:i];
                NSDictionary *userInfoCurrent = oneEvent.userInfo;
                NSString *uid=[NSString stringWithFormat:@"%@",[userInfoCurrent valueForKey:@"info"]];
                NSLog(@"uid = %@", uid);
                NSLog(@"gewg = %@", [parameter objectForKey:@"dictTemp"]);
                if ([uid isEqualToString:strRemoveNotifications])
                {
                    //Cancelling local notification
                    [app cancelLocalNotification:oneEvent];
                    break;
                }
            }
            // end clear register local push notification with time duration when early time complete event
            [self performSelectorInBackground:@selector(getListCalendar) withObject:nil];
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

- (void)touchDone : (id)sender{
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"MM/dd/yyyy"];
    NSDate *dateNow = [NSDate date];
    UIButton *btn = (UIButton *)sender;
    NSDictionary *dictTemp = [arrayCalendar objectAtIndex:btn.tag];
    [[AppDelegate shareInstance] showProgressHub];
    NSDictionary *dictAccount = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultLogin];
    NSDictionary *dictPost = @{
                               @"patientid":[dictAccount valueForKey:@"PatientId"],
                               @"results":@"other",
                               @"calendarId":[NSString stringWithFormat:@"%@", [dictTemp Id]],
                               @"TimeLogId":[NSString stringWithFormat:@"%@", [dictTemp TimeLogId]],
                               @"calendarTypeId":[NSString stringWithFormat:@"%@", [dictTemp PatientCalendarTypeId]],
                               @"protocoltype":@"1",
                               @"datetime":strDate,//[format stringFromDate:dateNow],
                               @"isbaseline":@"false",
                               @"isoverride":@"false"
                               };
    NSDictionary *dictParameter = @{
                                    @"parameter":[Settings EnCryptionDictionary:dictPost]
                                    };
    [self performSelectorInBackground:@selector(takeMedicine:) withObject:dictParameter];
}

- (void)takeMedicine:(NSDictionary *)parameter{
    NSDictionary *dictAccount = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultLogin];
    NSString *strLinkCalendar = [NSString stringWithFormat:@"%@%@", kLink, kCalendar];
    NSURL *url = [NSURL URLWithString:strLinkCalendar];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.HTTPAdditionalHeaders = @{@"token":[dictAccount valueForKey:@"token"]};
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:url sessionConfiguration:config];
    [manager.requestSerializer setTimeoutInterval:kMaxTimeOut];
    [manager PUT:@"" parameters:parameter success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
//        NSDictionary *dict = (NSDictionary *)responseObject;
//        if ([[dict valueForKey:@"success"] intValue] == 1) {
//            //            [self performSelectorOnMainThread:@selector(refreshGUICalendar) withObject:nil waitUntilDone:YES];
//            [self performSelectorInBackground:@selector(getListCalendar) withObject:nil];
//        }
//        else{
//            UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:@"Information" message:[dict objectForKey:@"message"] preferredStyle:UIAlertControllerStyleAlert];
//            [alertControl addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//                [alertControl dismissViewControllerAnimated:YES completion:nil];
//            }]];
//            [[AppDelegate shareInstance] hideProgressHub];
//            [self presentViewController:alertControl animated:YES completion:nil];
//        }
        NSDictionary *dict = (NSDictionary *)responseObject;
        if ([[dict valueForKey:@"success"] intValue] == 1) {
            [self performSelectorInBackground:@selector(getListCalendar) withObject:nil];
        }
        else{
            UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:@"Information" message:[dict objectForKey:@"message"] preferredStyle:UIAlertControllerStyleAlert];
            [alertControl addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [alertControl dismissViewControllerAnimated:YES completion:nil];
            }]];
            [[AppDelegate shareInstance] hideProgressHub];
            [self presentViewController:alertControl animated:YES completion:nil];
        }
        
//        [self performSelectorInBackground:@selector(getListCalendar) withObject:nil];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:@"Warning!" message:@"Please check internet and try again." preferredStyle:UIAlertControllerStyleAlert];
        [alertControl addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [alertControl dismissViewControllerAnimated:YES completion:nil];
        }]];
        [[AppDelegate shareInstance] hideProgressHub];
        [self presentViewController:alertControl animated:YES completion:nil];
    }];
}

- (void)showPopupValuesDevice{
    [self presentViewController:alertCo animated:YES completion:nil];
}

- (void)touchTakeMeasurement : (id)sender{
    UIButton *btn = (UIButton *)sender;
    indexTakeMeasurement = btn.tag;
    NSDictionary *dictTemp = [arrayCalendar objectAtIndex:indexTakeMeasurement];
    if ([[CRCreativeSDK sharedInstance] GetPortState]) {
        NSLog(@"exist");
        [actionCoOk setEnabled:YES];

        NSString *strType;
        if (BP == [dictTemp.PatientCalendarTypeId intValue]) {
            strType = @"BP and Pulse Measurement";
            [self showAlertInstructionBP:strType];
        }else if (SpO2 == [dictTemp.PatientCalendarTypeId intValue]){
            strType = @"Take SpO2 and HR Measurement";
            [self showAlertInstructionSPO2:strType];
        }else if (Temperature == [dictTemp.PatientCalendarTypeId intValue]){
            strType = @"Temperature Measurement";
            [self showAlertInstructionTemperature:strType];
        }else if (Heart_Rate == [dictTemp.PatientCalendarTypeId intValue]){
            strType = @"Heart Rate Measurement";
            [self showAlertInstruction:strType];
        }

//         take BP
        if (BP == [dictTemp.PatientCalendarTypeId intValue]){
            alertCo.message = @"BP Cuff: 0";
            [self showPopupValuesDevice];
            [[CRSpotCheck sharedInstance] SetNIBPAction:TRUE port:currentPort];
        }
        // Take Spo2
        else if (SpO2 == [dictTemp.PatientCalendarTypeId intValue]){
            alertCo.message = @"Spo2: 0, PR: 0";
            [self showPopupValuesDevice];
        }
        // Temperature
        else if (Temperature == [dictTemp.PatientCalendarTypeId intValue]){
            alertCo.message = @"C: 0";
            [self showPopupValuesDevice];
        }
        // Heart Rate
        else if (Heart_Rate == [dictTemp.PatientCalendarTypeId intValue]){
            alertCo.message = @"PR: 0";
            [self showPopupValuesDevice];
        }
    }else{
        NSString *strType;
        if (BP == [dictTemp.PatientCalendarTypeId intValue]) {
            strType = @"BP and Pulse Measurement";
            [self showAlertInstructionBP:strType];
        }else if (SpO2 == [dictTemp.PatientCalendarTypeId intValue]){
            strType = @"SPO2 Measurement";
            [self showAlertInstructionSPO2:strType];
        }else if (Temperature == [dictTemp.PatientCalendarTypeId intValue]){
            strType = @"Temperature Measurement";
            [self showAlertInstructionTemperature:strType];
        }else if (Heart_Rate == [dictTemp.PatientCalendarTypeId intValue]){
            strType = @"Heart Rate Measurement";
            [self showAlertInstruction:strType];
        }
        UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:@"INSTRUCTION" message:[NSString stringWithFormat:@"%@: Turn on device, wait for confirmation of connection between device and tablet. Strap arm-band and click START below to start taking measurements.", strType] preferredStyle:UIAlertControllerStyleAlert];
        [alertControl addAction:[UIAlertAction actionWithTitle:@"START" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[AppDelegate shareInstance] showProgressHub];
            [foundPorts removeAllObjects];

            [[CRCreativeSDK sharedInstance] startScan:10.0];
            [alertControl dismissViewControllerAnimated:YES completion:nil];
        }]];
        [self presentViewController:alertControl animated:YES completion:nil];
    }
}

// for Bp and Pulse
- (void)showAlertInstructionBP:(NSString *)strType{
    UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:@"INSTRUCTION" message:[NSString stringWithFormat:@"%@: \n 1. Insert the BP probe into the Spot Monitor. \n 2. Place the BP cuff on your upper arm following artery indicator on cuff. \n 3. Click \"Take Measurement\" on smart device (phone or tablet). \n 4. BP cuff will begin to inflate. \n 5. When BP cuff has deflated, result will appear on smart device. \n 6. Follow instructions on smart device to accept results.", strType] preferredStyle:UIAlertControllerStyleAlert];
    [alertControl addAction:[UIAlertAction actionWithTitle:@"START" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[AppDelegate shareInstance] showProgressHub];
        [foundPorts removeAllObjects];
        
//        [[CRCreativeSDK sharedInstance] startScan:10.0];
        [alertControl dismissViewControllerAnimated:YES completion:nil];
    }]];
    [alertControl addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [alertControl dismissViewControllerAnimated:YES completion:nil];
    }]];
    [self presentViewController:alertControl animated:YES completion:nil];
}

// for SPO2, Temperature, Heart Rate
- (void)showAlertInstruction : (NSString *)strType{
    
//    Temperature Measurement: Turn on Oximeter device, wait for confirmation of connection between Oximeter device and tablet/smartphone. After successful confirmation, click START below completion the connection. Next, use the temperature probe to start measuring your body temperature.
//    NSString *strTypeLower = strType;
//    strTypeLower = [strTypeLower lowercaseString];
    UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:@"INSTRUCTION" message:[NSString stringWithFormat:@"%@ : \n 1. Insert the heart rate/pulse oximeter probe into the Spot Monitor. \n 2. Attach the clip to the end of your finger to begin reading. \n 3. Click the “Take Measurement” button on smart device (phone or tablet). \n 4. Results will appear on the smart device. \n 5. Keep the clip on for at least 30 seconds. \n 6. Remove clip from finger. \n 7. Follow instructions on smart device to accept results.", strType] preferredStyle:UIAlertControllerStyleAlert];
    [alertControl addAction:[UIAlertAction actionWithTitle:@"START" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[AppDelegate shareInstance] showProgressHub];
        [foundPorts removeAllObjects];
        
//        [[CRCreativeSDK sharedInstance] startScan:10.0];
        [alertControl dismissViewControllerAnimated:YES completion:nil];
    }]];
    [alertControl addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [alertControl dismissViewControllerAnimated:YES completion:nil];
    }]];
    [self presentViewController:alertControl animated:YES completion:nil];
}
// for temperature
- (void)showAlertInstructionTemperature : (NSString *)strType{
//    NSString *strTypeLower = strType;
//    strTypeLower = [strTypeLower lowercaseString];

    UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:@"INSTRUCTION" message:[NSString stringWithFormat:@"%@ : \n 1. Insert the temperature probe into the Spot Monitor. \n 2. Click \"Take Measurement\" on smart device (phone or tablet). \n 3. When “Connection” displays insert thermometer in your ear. \n 4. Press button on back of thermometer and wait for beep. \n 5. Follow instructions on smart device to accept results", strType] preferredStyle:UIAlertControllerStyleAlert];
    [alertControl addAction:[UIAlertAction actionWithTitle:@"START" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[AppDelegate shareInstance] showProgressHub];
        [foundPorts removeAllObjects];

//        [[CRCreativeSDK sharedInstance] startScan:10.0];
        [alertControl dismissViewControllerAnimated:YES completion:nil];
    }]];
    [alertControl addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [alertControl dismissViewControllerAnimated:YES completion:nil];
    }]];
    [self presentViewController:alertControl animated:YES completion:nil];
}

    // for SPO2
- (void)showAlertInstructionSPO2 : (NSString *)strType{
//    NSString *strTypeLower = strType;
//    strTypeLower = [strTypeLower lowercaseString];

    UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:@"INSTRUCTION" message:[NSString stringWithFormat:@"%@ : \n 1. Insert the pulse oximeter probe into the Spot Monitor. \n 2. Attach the clip to the end of your finger to begin reading. \n 3. Click the \"Take Measurement\" button on smart device (phone or tablet). \n 4. Results will appear on the smart device. \n 5. Keep the clip on for at least 30 seconds. \n 6. Remove clip from finger. \n 7. Follow instructions on smart device to accept result.", strType] preferredStyle:UIAlertControllerStyleAlert];
    [alertControl addAction:[UIAlertAction actionWithTitle:@"START" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[AppDelegate shareInstance] showProgressHub];
        [foundPorts removeAllObjects];

//        [[CRCreativeSDK sharedInstance] startScan:10.0];
        [alertControl dismissViewControllerAnimated:YES completion:nil];
    }]];
    [alertControl addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [alertControl dismissViewControllerAnimated:YES completion:nil];
    }]];
    [self presentViewController:alertControl animated:YES completion:nil];
}

- (void)deleteCellSideEffect : (UIButton *)btn{
    [arraySideEffectChoise removeObjectAtIndex:btn.tag];
    [_tableViewSelectedSideEffect reloadData];
}

- (void)showAlertWhenAppActive{

    // show banner top
//    ALAlertBanner *banner = [ALAlertBanner alertBannerForView:self.view style:randomStyle position:ALAlertBannerPositionTop title:@"Lorem ipsum dolor sit amet, consectetur adipiscing elit." subtitle:[AppDelegate randomLoremIpsum] tappedBlock:^(ALAlertBanner *alertBanner) {
//        NSLog(@"tapped!");
//        [alertBanner hide];
//    }];
//    [banner show];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"hh:mm a"];
    NSDate *dateCurrent = [NSDate date];
    NSString *strCurrent = [format stringFromDate:dateCurrent];
    NSArray *arrCurrent = [strCurrent componentsSeparatedByString:@" "];
    int iTimeCurrent;
    if ([[arrCurrent objectAtIndex:1] isEqualToString:@"AM"]) {
        NSArray *arrTimeCurrent = [[arrCurrent objectAtIndex:0] componentsSeparatedByString:@":"];
        iTimeCurrent = [[arrTimeCurrent objectAtIndex:0] intValue]*60*60 + [[arrTimeCurrent objectAtIndex:1] intValue]*60;
    }else{
        NSArray *arrTimeCurrent = [[arrCurrent objectAtIndex:0] componentsSeparatedByString:@":"];
        if ([[arrTimeCurrent objectAtIndex:0] intValue] != 12) {
            iTimeCurrent = ([[arrTimeCurrent objectAtIndex:0] intValue] + 12)*60*60 + [[arrTimeCurrent objectAtIndex:1] intValue]*60;
        }else{
            iTimeCurrent = [[arrTimeCurrent objectAtIndex:0] intValue]*60*60 + [[arrTimeCurrent objectAtIndex:1] intValue]*60;
        }
    }
    for (int i = 0; i < arrayCalendar.count; i++) {
        NSDictionary *dictTemp = [arrayCalendar objectAtIndex:i];
        if ([[dictTemp Value] isEqualToString:@""]) {
            NSArray *arrTime = [[dictTemp Time] componentsSeparatedByString:@":"];
            NSInteger hours;
            if ([[arrTime objectAtIndex:1] componentsSeparatedByString:@" "].count > 1) {
                if ([[[[arrTime objectAtIndex:1] componentsSeparatedByString:@" "] objectAtIndex:1] isEqualToString:@"PM"]) {

                    if ([[arrTime objectAtIndex:0] integerValue] != 12) {
                        hours = [[arrTime objectAtIndex:0] integerValue] + 12;
                    }else{
                            // 12:00 PM nen minh ko cong them 12h
                        hours = [[arrTime objectAtIndex:0] integerValue];
                    }

                }else{
                    hours = [[arrTime objectAtIndex:0] integerValue];
                }
            }else{
                hours = [[arrTime objectAtIndex:0] integerValue];
            }
            NSInteger minutes = [[[[arrTime objectAtIndex:1] componentsSeparatedByString:@" "] objectAtIndex:0] integerValue];
            NSNumber *numberSecond = [NSNumber numberWithInteger:hours*60*60 + minutes*60];
            if ((iTimeCurrent >= [numberSecond intValue]) && ((iTimeCurrent - [numberSecond intValue]) <= 60*60) && [[dictTemp InProgress] boolValue]) {
                NSMutableDictionary *NSDictTemp = [[NSMutableDictionary alloc] init];
                [NSDictTemp addEntriesFromDictionary:dictTemp];
                [NSDictTemp setObject:@"False" forKey:@"InProgress"];
                // take medicine
                [NSDictTemp setObject:@"True" forKey:@"StatusDetailDone"];
                // end take medicine
                NSMutableArray *arr1 = [[NSMutableArray alloc] init];
                arr1 = [arrayCalendar mutableCopy];
                [arr1 replaceObjectAtIndex:i withObject:NSDictTemp];
                if (arrayCalendar.count - i > 1) {
                    NSDictionary *dictTemp1 = [arrayCalendar objectAtIndex:i + 1];
                    NSMutableDictionary *NSDictTemp1 = [[NSMutableDictionary alloc] init];
                    [NSDictTemp1 addEntriesFromDictionary:dictTemp1];
                    [NSDictTemp1 setObject:@"True" forKey:@"InProgress"];
                    [arr1 replaceObjectAtIndex:i+1 withObject:NSDictTemp1];
                }
                arrayCalendar = arr1;
                [_tableViewCalendar reloadData];
                break;
            }
        }
    }
}

- (void)scheduleLocalNotification:(NSString *)strTime alertBody : (NSString *)alertBody{
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"MM/dd/yyyy hh:mm a"];
    NSDate *date = [[NSDate alloc] init];
    date = [format dateFromString:[NSString stringWithFormat:@"%@ %@", strDate, strTime]];
    NSLog(@"date schedule = %@", date);
//    NSLog(@"strTime = %@", strTime);
//    NSLog(@"date local notification = %@", date);
//    NSLog(@"date local notification111 = %@", [format stringFromDate:date]);
    // Schedule the notification
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = date;
    localNotification.alertBody = alertBody;
    localNotification.soundName = @"alarm_of_old_clock.mp3";
    localNotification.userInfo = @{@"info": [NSString stringWithFormat:@"%@%@", strTime, alertBody]};
//    localNotification.soundName = UILocalNotificationDefaultSoundName
//    localNotification.alertAction = @"Show me the item";
//    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    localNotification.timeZone = [NSTimeZone systemTimeZone];
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];

//    UIApplication *app = [UIApplication sharedApplication];
//    NSArray *eventArray = [app scheduledLocalNotifications];
//    NSLog(@"eventArray = %@", eventArray);
}

#pragma mark UITableView Delegate & Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == _tableViewCalendar)
        return arrayCalendar.count;//[dictCalendar results].count;
    else if (tableView == _tableViewSideEffect)
        return arraySideBarFilter.count;
    else if (tableView == _tableViewSelectedSideEffect)
        return arraySideEffectChoise.count;
    else{
        return arraySurveyParse.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier;
    if (tableView == _tableViewCalendar) {
        cellIdentifier = @"CalendarTableViewCell";
        CalendarTableViewCell *cell = (CalendarTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == NULL) {
            NSArray *arrNib = [[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil];
            cell = [arrNib lastObject];
        }
        NSDictionary *dictTemp = [arrayCalendar objectAtIndex:indexPath.row];
        cell.lblTimer.text = [dictTemp Time];
        cell.lblTitle.text = [dictTemp DisplayName];
        
        // btn input result
        cell.btnInputResult.tag = indexPath.row;
        [cell.btnInputResult addTarget:self action:@selector(touchInputResult:) forControlEvents:UIControlEventTouchUpInside];
        
        // btn done take medicine
        cell.btnDone.tag = indexPath.row;
        [cell.btnDone addTarget:self action:@selector(touchDone:) forControlEvents:UIControlEventTouchUpInside];
        
        // btn take measurement
        cell.btnTakeMeasurement.tag = indexPath.row;
        [cell.btnTakeMeasurement addTarget:self action:@selector(touchTakeMeasurement:) forControlEvents:UIControlEventTouchUpInside];
        
//        NSArray *arrTime = [[dictTemp Time] componentsSeparatedByString:@":"];
//        NSInteger hours;
//        if ([[arrTime objectAtIndex:1] componentsSeparatedByString:@" "].count > 1) {
//            if ([[[[arrTime objectAtIndex:1] componentsSeparatedByString:@" "] objectAtIndex:1].uppercaseString isEqualToString:@"PM"]) {
////                hours = [[arrTime objectAtIndex:0] integerValue] + 12;
//
//                if ([[arrTime objectAtIndex:0] integerValue] != 12) {
//                    hours = [[arrTime objectAtIndex:0] integerValue] + 12;
//                }else{
//                        // 12:00 PM nen minh ko cong them 12h
//                    hours = [[arrTime objectAtIndex:0] integerValue];
//                }
//            }else{
//                // 12:00 AM nen minh  tru 12h ==> 0h
//                if ([[arrTime objectAtIndex:0] integerValue] == 12) {
//                    hours = [[arrTime objectAtIndex:0] integerValue] - 12;
//                }else
//                    hours = [[arrTime objectAtIndex:0] integerValue];
//            }
//        }else{
//            hours = [[arrTime objectAtIndex:0] integerValue];
//        }
//        NSInteger minutes = [[[[arrTime objectAtIndex:1] componentsSeparatedByString:@" "] objectAtIndex:0] integerValue];
////        NSNumber *numberSecondEarlyTime = [NSNumber numberWithInteger:[[dictTemp Earlytimehour] integerValue]*60*60];
//        NSNumber *numberSecond = [NSNumber numberWithInteger:hours*60*60 + minutes*60 - [[dictTemp Earlytimehour] integerValue]*60*60];

        NSNumber *numberSecond = [self timeEvent:dictTemp];

        // current time
        NSDate *date = [NSDate date];
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"hh:mm a"];
//        NSArray *arrCurentTimeType = [[format stringFromDate:date] componentsSeparatedByString:@" "];
//        NSArray *arrCurrentTime;
//        NSInteger hoursCurrent;
//        NSInteger minutesCurrent;
//        [format setDateFormat:@"hh:mm"];
//        arrCurrentTime = [[format stringFromDate:date] componentsSeparatedByString:@":"];
//        NSLog(@"arrCurentTimeType = %@", arrCurentTimeType);
//        if (arrCurentTimeType.count > 1) {
//            if ([[[arrCurentTimeType objectAtIndex:1] uppercaseString] isEqualToString:@"PM"]) {
////                hoursCurrent = [[arrCurrentTime objectAtIndex:0] integerValue] + 12;// PM
//
//                if ([[arrCurrentTime objectAtIndex:0] integerValue] != 12) {
//                    hoursCurrent = [[arrCurrentTime objectAtIndex:0] integerValue] + 12;// PM
//                }else{
//                    hoursCurrent = [[arrCurrentTime objectAtIndex:0] integerValue];// PM
//                }
//            }
//            else{
//                    // 12:00 AM nen minh  tru 12h ==> 0h
//                if ([[arrCurrentTime objectAtIndex:0] integerValue] == 12) {
//                    hoursCurrent = [[arrCurrentTime objectAtIndex:0] integerValue] - 12;
//                }else
//                    hoursCurrent = [[arrCurrentTime objectAtIndex:0] integerValue];// AM
//            }
//            minutesCurrent = [[arrCurrentTime objectAtIndex:1] integerValue];
//        }else{
//            hoursCurrent = [[arrCurrentTime objectAtIndex:0] integerValue];
//            minutesCurrent = [[arrCurrentTime objectAtIndex:1] integerValue];
//        }
//
//        NSNumber *numberSecondsCurrent = [NSNumber numberWithInteger:hoursCurrent*60*60 + minutesCurrent*60];

        NSNumber *numberSecondsCurrent = [self timeCurrent];
        NSLog(@"numberSecondsCurrent = %@", numberSecondsCurrent);

        if ([[dictTemp PatientCalendarTypeId] compare:[NSNumber numberWithInteger:1]] == NSOrderedSame) {
            // take medicine with PatientCalendarTypeId = 1
            [format setDateFormat:@"MM/dd/yyyy"];
            if ([strDate isEqualToString:[format stringFromDate:date]]){
                if ([numberSecondsCurrent intValue] >= [numberSecond intValue]) {
                    cell.btnDone.hidden = NO;
                    cell.btnNext.hidden = YES;
                    // remove ID register Local Push Notifications
                    if ([arrayIDRegisterPushNotifications containsObject:[NSString stringWithFormat:@"%@%@", [dictTemp Id], [dictTemp Time]]]) {
                        NSMutableArray *arrTPush = [arrayIDRegisterPushNotifications mutableCopy];
                        [arrTPush removeObject:[NSString stringWithFormat:@"%@%@", [dictTemp Id], [dictTemp Time]]];
                        arrayIDRegisterPushNotifications = [NSMutableArray arrayWithArray:arrTPush];
                        [[NSUserDefaults standardUserDefaults] setObject:arrayIDRegisterPushNotifications forKey:kArrayIDRegisterPushNotifications];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                    }
                    switch ([[dictTemp Status] integerValue]) {
                        case 1:
                            // done
                            cell.btnDone.hidden = YES;
                            cell.imgMissed.hidden = YES;
                            cell.imgStatus.hidden = NO;
                            [cell.imgStatus setImage:[UIImage imageNamed:@"IconLaugh"]];
                            break;
                        case 2:
                            cell.btnDone.hidden = NO;
                            cell.imgMissed.hidden = YES;
                            cell.imgStatus.hidden = YES;
                            // progressing
                            break;
                        case 3:
                            // future
                            break;
                        case 4:
                            // miss
                            cell.imgMissed.hidden = NO;
                            cell.imgStatus.hidden = YES;
                            cell.btnDone.hidden = YES;
                            [cell.imgMissed setImage:[UIImage imageNamed:@"Icon#"]];
                            break;
                        case 5:
                            // next
                            break;
                        default:
                            break;
                    }
                }
                else{
                    // local notification
                    if (![arrayIDRegisterPushNotifications containsObject:[NSString stringWithFormat:@"%@%@", [dictTemp Id], [dictTemp Time]]]) {
                        NSMutableArray *arrTPush = [arrayIDRegisterPushNotifications mutableCopy];
                        [arrTPush addObject:[NSString stringWithFormat:@"%@%@", [dictTemp Id], [dictTemp Time]]];
                        arrayIDRegisterPushNotifications = [NSMutableArray arrayWithArray:arrTPush];
                        [[NSUserDefaults standardUserDefaults] setObject:arrayIDRegisterPushNotifications forKey:kArrayIDRegisterPushNotifications];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        
                        NSArray *arrTime = [[dictTemp Time] componentsSeparatedByString:@":"];
                        NSInteger hour = [[arrTime objectAtIndex:0] integerValue] - [[dictTemp Earlytimehour] integerValue];
                        NSString *timer = [NSString stringWithFormat:@"%ld:%@", (long)hour, [arrTime objectAtIndex:1]];
                        [self scheduleLocalNotification:timer alertBody:[dictTemp DisplayName]];
                    }
                    if ([[dictTemp Status] integerValue] == 5) {
                        cell.btnNext.hidden = NO;
                    }
                }
            }else{//} if ([date timeIntervalSinceReferenceDate] > [[format dateFromString:strDate] timeIntervalSinceReferenceDate]) {
                switch ([[dictTemp Status] integerValue]) {
                    case 1:
                        // done
                        cell.btnDone.hidden = YES;
                        cell.imgMissed.hidden = YES;
                        cell.imgStatus.hidden = NO;
                        [cell.imgStatus setImage:[UIImage imageNamed:@"IconLaugh"]];
                        break;
                    case 2:
                        cell.btnDone.hidden = NO;
                        cell.imgMissed.hidden = YES;
                        cell.imgStatus.hidden = YES;
                        // progressing
                        break;
                    case 3:
                        // future
                        break;
                    case 4:
                        // miss
                        cell.imgMissed.hidden = NO;
                        cell.imgStatus.hidden = YES;
                        cell.btnDone.hidden = YES;
                        [cell.imgMissed setImage:[UIImage imageNamed:@"Icon#"]];
                        break;
                    case 5:
                        // next
                        break;
                    default:
                        break;
                }
            }
        }else if ([[dictTemp PatientCalendarTypeId] compare:[NSNumber numberWithInteger:-1]] == NSOrderedSame){
            // survey
            [format setDateFormat:@"MM/dd/yyyy"];
            if ([strDate isEqualToString:[format stringFromDate:date]]){
                if ([numberSecondsCurrent intValue] >= [numberSecond intValue]) {
                    cell.btnInputResult.hidden = NO;
//                    cell.btnTakeMeasurement.hidden = NO;
                    // remove ID register Local Push Notifications
                    if ([arrayIDRegisterPushNotifications containsObject:[NSString stringWithFormat:@"%@%@", [dictTemp Id], [dictTemp Time]]]) {
                        NSMutableArray *arrTPush = [arrayIDRegisterPushNotifications mutableCopy];
                        [arrTPush removeObject:[NSString stringWithFormat:@"%@%@", [dictTemp Id], [dictTemp Time]]];
                        arrayIDRegisterPushNotifications = [NSMutableArray arrayWithArray:arrTPush];
                        [[NSUserDefaults standardUserDefaults] setObject:arrayIDRegisterPushNotifications forKey:kArrayIDRegisterPushNotifications];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                    }
                    if ([[dictTemp Status] compare:[NSNumber numberWithInteger:1]] == NSOrderedSame) {
                        cell.imgMissed.hidden = YES;
                        cell.imgStatus.hidden = NO;
                        [cell.imgStatus setImage:[[dictTemp isNormal] intValue] == -1 ? [UIImage imageNamed:@"IconCheckRed"] : [UIImage imageNamed:@"IconCheck"]];
                        cell.btnTakeMeasurement.hidden = YES;
                        [cell.btnInputResult setTitle:[dictTemp Value] forState:UIControlStateNormal];
                        cell.btnInputResult.userInteractionEnabled = NO;
                    }
                    cell.btnNext.hidden = YES;
                }
                else{
                    // local notification
                    if (![arrayIDRegisterPushNotifications containsObject:[NSString stringWithFormat:@"%@%@", [dictTemp Id], [dictTemp Time]]]) {
                        NSMutableArray *arrTPush = [arrayIDRegisterPushNotifications mutableCopy];
                        [arrTPush addObject:[NSString stringWithFormat:@"%@%@", [dictTemp Id], [dictTemp Time]]];
                        arrayIDRegisterPushNotifications = [NSMutableArray arrayWithArray:arrTPush];
                        [[NSUserDefaults standardUserDefaults] setObject:arrayIDRegisterPushNotifications forKey:kArrayIDRegisterPushNotifications];
                        [[NSUserDefaults standardUserDefaults] synchronize];

                        NSArray *arrTime = [[dictTemp Time] componentsSeparatedByString:@":"];
                        NSInteger hour = [[arrTime objectAtIndex:0] integerValue] - [[dictTemp Earlytimehour] integerValue];
                        NSString *timer = [NSString stringWithFormat:@"%ld:%@", (long)hour, [arrTime objectAtIndex:1]];
                        [self scheduleLocalNotification:timer alertBody:[dictTemp DisplayName]];
                    }
                    if ([[dictTemp Status] integerValue] == 5) {
                        cell.btnNext.hidden = NO;
                    }
                }
            }else{//} if ([date timeIntervalSinceReferenceDate] > [[format dateFromString:strDate] timeIntervalSinceReferenceDate]) {
                switch ([[dictTemp Status] integerValue]) {
                    case 1:
                        // done
                        cell.btnInputResult.hidden = NO;
                        [cell.btnInputResult setTitle:[dictTemp Value] forState:UIControlStateNormal];
                        cell.btnInputResult.userInteractionEnabled = NO;
                        cell.btnTakeMeasurement.hidden = YES;
                        cell.imgMissed.hidden = YES;
                        cell.imgStatus.hidden = NO;
                        [cell.imgStatus setImage:[[dictTemp isNormal] intValue] == -1 ? [UIImage imageNamed:@"IconCheckRed"] : [UIImage imageNamed:@"IconCheck"]];
                        break;
                    case 2:
                        cell.btnInputResult.hidden = NO;
                        // progressing
                        break;
                    case 3:
                        // future
                        break;
                    case 4:
                        // miss
                        cell.btnInputResult.hidden = NO;
                        cell.btnTakeMeasurement.hidden = YES;
                        cell.imgStatus.hidden = YES;
                        cell.imgMissed.hidden = NO;
                        [cell.imgMissed setImage:[UIImage imageNamed:@"Icon#"]];
                        break;
                    case 5:
                        // next
                        break;
                    default:
                        break;
                }
            }
        }
        else{
            [format setDateFormat:@"MM/dd/yyyy"];
            if ([strDate isEqualToString:[format stringFromDate:date]]){
                if ([numberSecondsCurrent intValue] >= [numberSecond intValue]) {
                    cell.btnInputResult.hidden = NO;
                    cell.btnTakeMeasurement.hidden = NO;
                    // remove ID register Local Push Notifications
                    if ([arrayIDRegisterPushNotifications containsObject:[NSString stringWithFormat:@"%@%@", [dictTemp Id], [dictTemp Time]]]) {
                        NSMutableArray *arrTPush = [arrayIDRegisterPushNotifications mutableCopy];
                        [arrTPush removeObject:[NSString stringWithFormat:@"%@%@", [dictTemp Id], [dictTemp Time]]];
                        arrayIDRegisterPushNotifications = [NSMutableArray arrayWithArray:arrTPush];
                        [[NSUserDefaults standardUserDefaults] setObject:arrayIDRegisterPushNotifications forKey:kArrayIDRegisterPushNotifications];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                    }
                    switch ([[dictTemp Status] integerValue]) {
                        case 1:
                            // done
                            cell.imgMissed.hidden = YES;
                            cell.imgStatus.hidden = NO;
                            [cell.imgStatus setImage:[[dictTemp isNormal] intValue] == -1 ? [UIImage imageNamed:@"IconCheckRed"] : [UIImage imageNamed:@"IconCheck"]];
                            cell.btnTakeMeasurement.hidden = YES;
                            [cell.btnInputResult setTitle:[dictTemp Value] forState:UIControlStateNormal];
                            cell.btnInputResult.userInteractionEnabled = NO;
                            break;
                        case 2:
                            // progressing
                            break;
                        case 3:
                            // future
                            break;
                        case 4:
                            // miss
                            cell.btnInputResult.hidden = NO;
                            cell.btnTakeMeasurement.hidden = YES;
                            cell.imgStatus.hidden = YES;
                            cell.imgMissed.hidden = NO;
                            [cell.imgMissed setImage:[UIImage imageNamed:@"Icon#"]];
                            break;
                        case 5:
                            // next
                            break;
                        default:
                            break;
                    }
                    cell.btnNext.hidden = YES;
                }
                else{
                    // local notification
                    if (![arrayIDRegisterPushNotifications containsObject:[NSString stringWithFormat:@"%@%@", [dictTemp Id], [dictTemp Time]]]) {
                        NSMutableArray *arrTPush = [arrayIDRegisterPushNotifications mutableCopy];
                        [arrTPush addObject:[NSString stringWithFormat:@"%@%@", [dictTemp Id], [dictTemp Time]]];
                        arrayIDRegisterPushNotifications = [NSMutableArray arrayWithArray:arrTPush];
                        [[NSUserDefaults standardUserDefaults] setObject:arrayIDRegisterPushNotifications forKey:kArrayIDRegisterPushNotifications];
                        [[NSUserDefaults standardUserDefaults] synchronize];

                        NSArray *arrTime = [[dictTemp Time] componentsSeparatedByString:@":"];
                        NSInteger hour = [[arrTime objectAtIndex:0] integerValue] - [[dictTemp Earlytimehour] integerValue];
                        NSString *timer = [NSString stringWithFormat:@"%ld:%@", (long)hour, [arrTime objectAtIndex:1]];
                        [self scheduleLocalNotification:timer alertBody:[dictTemp DisplayName]];
                    }
                    if ([[dictTemp Status] integerValue] == 5) {
                        cell.btnNext.hidden = NO;
                    }
                }
            }
            else{//} if ([date timeIntervalSinceReferenceDate] > [[format dateFromString:strDate] timeIntervalSinceReferenceDate]) {
                switch ([[dictTemp Status] integerValue]) {
                    case 1:
                        // done
                        cell.btnInputResult.hidden = NO;
                        [cell.btnInputResult setTitle:[dictTemp Value] forState:UIControlStateNormal];
                        cell.btnInputResult.userInteractionEnabled = NO;
                        cell.btnTakeMeasurement.hidden = YES;
                        cell.imgMissed.hidden = YES;
                        cell.imgStatus.hidden = NO;
                        [cell.imgStatus setImage:[[dictTemp isNormal] intValue] == -1 ? [UIImage imageNamed:@"IconCheckRed"] : [UIImage imageNamed:@"IconCheck"]];
                        break;
                    case 2:
                        cell.btnInputResult.hidden = NO;
                        cell.btnTakeMeasurement.hidden = NO;
                        // progressing
                        break;
                    case 3:
                        // future
                        break;
                    case 4:
                        // miss
                        cell.btnInputResult.hidden = NO;
                        cell.btnTakeMeasurement.hidden = YES;
                        cell.imgStatus.hidden = YES;
                        cell.imgMissed.hidden = NO;
                        [cell.imgMissed setImage:[UIImage imageNamed:@"Icon#"]];
                        break;
                    case 5:
                        // next
                        break;
                    default:
                        break;
                }
            }
            // side effect
//            BP = 2,
//            SpO2 = 4,
//            Heart_Rate = 9,
//            Temperature = 3,
            if (BP != [[dictTemp PatientCalendarTypeId] intValue] &&
                SpO2 != [[dictTemp PatientCalendarTypeId] intValue] &&
                Heart_Rate != [[dictTemp PatientCalendarTypeId] intValue] &&
                Temperature != [[dictTemp PatientCalendarTypeId] intValue]) {
                cell.btnTakeMeasurement.hidden = YES;
            }
//            if (SideEffect == [[dictTemp PatientCalendarTypeId] intValue] ||
//                Self_Monitoring_of_Blood_Glucose == [[dictTemp PatientCalendarTypeId] intValue] ||
//                Weight == [[dictTemp PatientCalendarTypeId] intValue] ||
//                FVC == [[dictTemp PatientCalendarTypeId] intValue] ||
//                FEV1 == [[dictTemp PatientCalendarTypeId] intValue] ||
//                // moi them
//                CovidLevel1 == [[dictTemp PatientCalendarTypeId] intValue] ||
//                CovidLevel2 == [[dictTemp PatientCalendarTypeId] intValue] ||
//                CovidLevel3 == [[dictTemp PatientCalendarTypeId] intValue] ||
//                // end moi them
//                FEV1FVC == [[dictTemp PatientCalendarTypeId] intValue]
//                ) {
//                cell.btnTakeMeasurement.hidden = YES;
//            }
        }
        return cell;
    } else if (tableView == _tableViewSideEffect){
        cellIdentifier = @"SideEffectTableViewCell";
        SideEffectTableViewCell *cell = (SideEffectTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == NULL) {
            NSArray *arrNib = [[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil];
            cell = [arrNib lastObject];
        }
        cell.lblName.text = [arraySideBarFilter objectAtIndex:indexPath.row];
        return cell;
    }else if (tableView == _tableViewSelectedSideEffect){
        cellIdentifier = @"SideEffectSelectedTableViewCell";
        SideEffectSelectedTableViewCell *cell = (SideEffectSelectedTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == NULL) {
            NSArray *arrNib = [[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil];
            cell = [arrNib lastObject];
        }
        cell.lblName.text = [arraySideEffectChoise objectAtIndex:indexPath.row];
        cell.btnDelete.tag = indexPath.row;
        [cell.btnDelete addTarget:self action:@selector(deleteCellSideEffect:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }else{
        cellIdentifier = @"SurveyTableViewCell";
        SurveyTableViewCell *cell = (SurveyTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            NSArray *arrNib = [[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil];
            cell = [arrNib lastObject];
        }
        NSDictionary *dRoot = [arraySurveyParse objectAtIndex:indexPath.row];
        NSLog(@"dRoot = %@", dRoot);
        if ([dRoot objectForKey:@"Data"]) {
            [cell setIndentationLevel:[[[dRoot objectForKey:@"Data"] valueForKey:@"Level"] intValue]];
            cell.indentationWidth = 10;
            cell.imgStatus.hidden = YES;
            cell.lblTitle.hidden = YES;
            cell.txtName.hidden = YES;
            cell.lblQuestionName.hidden = NO;
            cell.lblQuestionName.text = [[dRoot objectForKey:@"Data"] valueForKey:@"QuestionName"];
        }else{
            if ([[dRoot objectForKey:@"QuestionType"] isEqualToString:@"2"]) {
                cell.imgStatus.hidden = YES;
                cell.lblTitle.hidden = YES;
                cell.txtName.hidden = NO;
                cell.lblQuestionName.hidden = YES;
                [cell.txtName addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
                cell.txtName.tag = 50 + [[dRoot objectForKey:@"Id"] integerValue];
//                cell.txtName.text = strText;
                cell.txtName.text = [dictInputTextSurvey valueForKey:[NSString stringWithFormat:@"key%ld", (long)cell.txtName.tag]];
                [cell.txtName setPlaceholder:[dRoot objectForKey:@"AnswerName"]];
            }else if ([[dRoot objectForKey:@"QuestionType"] isEqualToString:@"4"]){
                //(![[dRoot objectForKey:@"AnswerName"] isEqualToString:@"Yes"] && ![[dRoot objectForKey:@"AnswerName"] isEqualToString:@"No"]){
                NSLog(@"droot123 = %@", [dRoot valueForKey:@"Status"]);
                cell.imgStatus.image = [UIImage imageNamed:@"IconUncheckedBox"];
                if ([[dRoot objectForKey:@"Status"] isEqualToString:@"Active"]) {
                    cell.imgStatus.image = [UIImage imageNamed:@"IconCheckedBox"];
                }
                cell.imgStatus.hidden = NO;
                cell.lblTitle.hidden = NO;
                cell.txtName.hidden = YES;
                cell.lblQuestionName.hidden = YES;
                cell.lblTitle.text = [dRoot objectForKey:@"AnswerName"];
            }
            else{
                if ([[dRoot objectForKey:@"Status"] isEqualToString:@"Active"]) {
                    cell.imgStatus.image = [UIImage imageNamed:@"IconChecked"];
                }
                cell.imgStatus.hidden = NO;
                cell.lblTitle.hidden = NO;
                cell.txtName.hidden = YES;
                cell.lblQuestionName.hidden = YES;
                cell.lblTitle.text = [dRoot objectForKey:@"AnswerName"];
            }
            [cell setIndentationLevel:[[dRoot valueForKey:@"Level"] intValue]];
            cell.indentationWidth = 10;
        }
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (tableView == _tableViewCalendar) {
        NSDictionary *dictTemp = [arrayCalendar objectAtIndex:indexPath.row];
        if ([[dictTemp PatientCalendarTypeId] intValue] == SideEffect && [dictTemp Value].length > 0) {
            UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"Infomation" message:[dictTemp Value] preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *act = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [alertC dismissViewControllerAnimated:YES completion:nil];
            }];
            [alertC addAction:act];
            [self presentViewController:alertC animated:YES completion:nil];
        }
//        else if ([[dictTemp PatientCalendarTypeId] intValue] == Survey){
//            [[AppDelegate shareInstance] showProgressHub];
//            [self performSelectorInBackground:@selector(getListSurvey) withObject:nil];
//        }
    }
    else if (tableView == _tableViewSideEffect) {
        _txtNameSideEffect.text = @"";
        [_txtNameSideEffect resignFirstResponder];
        _tableViewSideEffect.hidden = YES;
        [arraySideEffectChoise addObject:[arraySideBarFilter objectAtIndex:indexPath.row]];
        [_viewTableView bringSubviewToFront:_tableViewSideEffect];
        [_tableViewSelectedSideEffect reloadData];
    }
    // table survey
    else if (tableView == _tableViewSurvey){
//        [[dRoot objectForKey:@"QuestionType"] isEqualToString:@"2"]
        NSLog(@"gwegwiu = %@", [arraySurveyParse objectAtIndex:indexPath.row]);
        NSLog(@"gewhgiuweh = %@", [[arraySurveyParse objectAtIndex:indexPath.row] valueForKey:@"AnswerName"]);
        if ([[[arraySurveyParse objectAtIndex:indexPath.row] valueForKey:@"QuestionType"] isEqualToString:@"1"]) {
            if ([[[arraySurveyParse objectAtIndex:indexPath.row] valueForKey:@"isShowChild"] intValue] == 1 && [[[arraySurveyParse objectAtIndex:indexPath.row] valueForKey:@"Status"] isEqualToString:@""]) {
                if ([[arraySurveyParse objectAtIndex:indexPath.row] valueForKey:@"Id"]) {
                    NSArray *arr;
                    if ([[[arraySurveyParse objectAtIndex:indexPath.row] valueForKey:@"Level"] intValue] == 0) {
                        arr = [[arraySurvey objectAtIndex:[[[arraySurveyParse objectAtIndex:indexPath.row] valueForKey:@"Position"] intValue]] objectForKey:@"questions"];
                    }else if ([[[arraySurveyParse objectAtIndex:indexPath.row] valueForKey:@"Level"] intValue] == 1){
                        if ([[[[arraySurvey objectAtIndex:[[[arraySurveyParse objectAtIndex:indexPath.row] valueForKey:@"Position"] intValue]] objectForKey:@"questions"] valueForKey:@"questions"] count] > 0) {
                            arr = [[[arraySurvey objectAtIndex:[[[arraySurveyParse objectAtIndex:indexPath.row] valueForKey:@"Position"] intValue]] objectForKey:@"questions"] valueForKey:@"questions"];
                            arr = [NSArray arrayWithArray:[arr objectAtIndex:[[[arraySurveyParse objectAtIndex:indexPath.row] valueForKey:@"indexAnswer"] intValue]]];
                        }
                    }else if ([[[arraySurveyParse objectAtIndex:indexPath.row] valueForKey:@"Level"] intValue] == 2){
                        if ([[[[arraySurvey objectAtIndex:[[[arraySurveyParse objectAtIndex:indexPath.row] valueForKey:@"Level"] intValue]] objectForKey:@"questions"] valueForKey:@"questions"] count] > 0) {
                            arr = [[[arraySurvey objectAtIndex:[[[arraySurveyParse objectAtIndex:indexPath.row] valueForKey:@"Level"] intValue]] objectForKey:@"questions"] valueForKey:@"questions"];
                            arr = [NSArray arrayWithArray:[arr objectAtIndex:0]];
                        }
                    }
                    // set status for row
                    NSDictionary *dStatus;// = [arraySurveyParse objectAtIndex:indexPath.row];
//                    [dStatus setValue:@"Active" forKey:@"Status"];
//                    [arraySurveyParse removeObjectAtIndex:indexPath.row];
//                    [arraySurveyParse insertObject:dStatus atIndex:indexPath.row];
//                    dStatus = [arraySurveyParse objectAtIndex:indexPath.row + 1];
//                    [dStatus setValue:@"" forKey:@"Status"];
//                    [arraySurveyParse removeObjectAtIndex:indexPath.row + 1];
//                    [arraySurveyParse insertObject:dStatus atIndex:indexPath.row + 1];
                    int intTotalAnswer = [[[arraySurveyParse objectAtIndex:indexPath.row] valueForKey:@"TotalAnswer"] intValue];
                    int intPositionAnswer = [[[arraySurveyParse objectAtIndex:indexPath.row] valueForKey:@"PositionAnswer"] intValue];
                    NSDictionary *dT;
                    for (int k = 0; k < intTotalAnswer; k++) {
                        dT = [arraySurveyParse objectAtIndex:indexPath.row - intPositionAnswer + k];
                        dStatus = [dT mutableCopy];
                        [dStatus setValue:@"" forKey:@"Status"];
                        [arraySurveyParse removeObjectAtIndex:indexPath.row - intPositionAnswer + k];
                        [arraySurveyParse insertObject:dStatus atIndex:indexPath.row - intPositionAnswer + k];
                    }
                    dT = [arraySurveyParse objectAtIndex:indexPath.row];
                    dStatus = [dT mutableCopy];
                    [dStatus setValue:@"Active" forKey:@"Status"];
                    [arraySurveyParse removeObjectAtIndex:indexPath.row];
                    [arraySurveyParse insertObject:dStatus atIndex:indexPath.row];
                    // end set status for row
                    if ([arr count] > 0) {
                        NSMutableArray *arrTemp123 = [arraySurveyParse mutableCopy];
                        NSMutableArray *arrTemp1 = [[NSMutableArray alloc] init];
                        for (int i = 0; i < arr.count; i++) {
                            NSDictionary *dTemp = [arr objectAtIndex:i];
                            NSMutableDictionary *dTempArr = [[NSMutableDictionary alloc] init];
                            NSMutableDictionary *dTempRoot = [[NSMutableDictionary alloc] init];
                            [dTempArr setValue:[dTemp valueForKey:@"Id"] forKey:@"Id"];
                            [dTempArr setValue:[dTemp valueForKey:@"ParentQuestion"] forKey:@"ParentQuestion"];
                            [dTempArr setValue:[dTemp valueForKey:@"QuestionName"] forKey:@"QuestionName"];
                            [dTempArr setValue:[dTemp valueForKey:@"QuestionType"] forKey:@"QuestionType"];
                            [dTempArr setValue:[NSString stringWithFormat:@"%d", [[[arraySurveyParse objectAtIndex:indexPath.row] valueForKey:@"Level"] intValue] + 1] forKey:@"Level"];
                            [dTempArr setValue:[NSString stringWithFormat:@"%d", i] forKey:@"PositionParent"];
                            [dTempRoot setValue:dTempArr forKey:@"Data"];
                            [arrTemp1 addObject:dTempRoot];
                            // add answers to array survey parse
                            NSArray *arrTemp = [dTemp valueForKey:@"Answers"];
                            for (int j = 0; j < arrTemp.count; j++) {
                                NSDictionary *dT = [arrTemp objectAtIndex:j];
                                NSMutableDictionary *dTempAnswer = [[NSMutableDictionary alloc] init];
                                [dTempAnswer setValue:[dT valueForKey:@"Id"] forKey:@"Id"];
                                [dTempAnswer setValue:[dT valueForKey:@"AnswerName"] forKey:@"AnswerName"];
                                [dTempAnswer setValue:[dT valueForKey:@"isShowChild"] forKey:@"isShowChild"];
                                [dTempAnswer setValue:[NSString stringWithFormat:@"%d", [[[arraySurveyParse objectAtIndex:indexPath.row] valueForKey:@"Level"] intValue] + 1] forKey:@"Level"];
                                [dTempAnswer setValue:[NSString stringWithFormat:@"%d", [[[arraySurveyParse objectAtIndex:indexPath.row] valueForKey:@"Position"] intValue]] forKey:@"Position"];
                                [dTempAnswer setValue:[NSString stringWithFormat:@"%d", i] forKey:@"indexAnswer"];
                                [dTempAnswer setValue:[dTemp valueForKey:@"ParentQuestion"] forKey:@"ParentQuestion"];
                                [dTempAnswer setValue:[dTemp valueForKey:@"QuestionType"] forKey:@"QuestionType"];
                                [dTempAnswer setValue:[NSString stringWithFormat:@"%d", j] forKey:@"PositionAnswer"];
                                [dTempAnswer setValue:[NSString stringWithFormat:@"%lu", (unsigned long)arrTemp.count] forKey:@"TotalAnswer"];
                                [dTempAnswer setValue:@"" forKey:@"Status"];
                                [arrTemp1 addObject:dTempAnswer];
                            }
                        }
//                        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(indexPath.row + 2, arrTemp1.count)];
                        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(indexPath.row + intTotalAnswer - intPositionAnswer, arrTemp1.count)];
                        [arrTemp123 insertObjects:arrTemp1 atIndexes:indexSet];
                        arraySurveyParse = [NSMutableArray arrayWithArray:arrTemp123];
                    }
                    [_tableViewSurvey reloadData];
                }
            }else if ([[[arraySurveyParse objectAtIndex:indexPath.row] valueForKey:@"isShowChild"] intValue] == 0 && [[[arraySurveyParse objectAtIndex:indexPath.row] valueForKey:@"Status"] isEqualToString:@""]){
                // set status for row
                NSDictionary *dStatus;// = [[NSDictionary alloc] init];// = [arraySurveyParse objectAtIndex:indexPath.row];
//                [dStatus mutableCopy];
//                dStatus = [arraySurveyParse objectAtIndex:indexPath.row - 1];
//                [dStatus setValue:@"" forKey:@"Status"];
//                [arraySurveyParse removeObjectAtIndex:indexPath.row - 1];
//                [arraySurveyParse insertObject:dStatus atIndex:indexPath.row - 1];
                int intTotalAnswer = [[[arraySurveyParse objectAtIndex:indexPath.row] valueForKey:@"TotalAnswer"] intValue];
                int intPositionAnswer = [[[arraySurveyParse objectAtIndex:indexPath.row] valueForKey:@"PositionAnswer"] intValue];
                NSDictionary *dT;
                for (int k = 0; k < intTotalAnswer; k++) {
                    
//                    NSLog(@"index = %d", indexPath.row - intPositionAnswer + k);
//                    NSLog(@"k = %d", k);
//                    NSLog(@"indexpath = %d", indexPath.row);
//                    NSLog(@"PositionAnswer = %d", intPositionAnswer);
                    NSLog(@"gewg = %@", [arraySurveyParse objectAtIndex:indexPath.row - intPositionAnswer + k]);
                    dT = [arraySurveyParse objectAtIndex:indexPath.row - intPositionAnswer + k];
                    dStatus = [dT mutableCopy];
//                    dStatus = [arraySurveyParse objectAtIndex:indexPath.row - intPositionAnswer + k];
                    [dStatus setValue:@"" forKey:@"Status"];
                    [arraySurveyParse removeObjectAtIndex:indexPath.row - intPositionAnswer + k];
                    [arraySurveyParse insertObject:dStatus atIndex:indexPath.row - intPositionAnswer + k];
                }
                dT = [arraySurveyParse objectAtIndex:indexPath.row];
                dStatus = [dT mutableCopy];
                [dStatus setValue:@"Active" forKey:@"Status"];
                [arraySurveyParse removeObjectAtIndex:indexPath.row];
                [arraySurveyParse insertObject:dStatus atIndex:indexPath.row];
                // end set status for row
                if ([[[arraySurveyParse objectAtIndex:indexPath.row] valueForKey:@"Level"] intValue] == 0) {
                    NSMutableArray *arrTemp = [arraySurveyParse mutableCopy];
                    NSInteger k = arrTemp.count;
                    NSMutableArray *arrIndex = [[NSMutableArray alloc] init];
                    for (int i = 0; i < k; i++) {
                        NSDictionary *dTemp = [arrTemp objectAtIndex:i];
                        if ([dTemp objectForKey:@"Data"]) {
                            if ([[[dTemp objectForKey:@"Data"] valueForKey:@"Level"] intValue] == 1 && [[[dTemp objectForKey:@"Data"] valueForKey:@"ParentQuestion"] intValue] == [[[[arraySurveyParse objectAtIndex:indexPath.row - intPositionAnswer - 1] objectForKey:@"Data"] valueForKey:@"Id"] intValue]) {
                                // check level 2 status = active
                                NSDictionary *dTemp1 = [arrTemp objectAtIndex:i+1];
                                if ([[dTemp1 valueForKey:@"Status"] isEqualToString:@"Active"]) {
                                    NSDictionary *dTempLevel2 = [arrTemp objectAtIndex:i+3];
                                    for (int j = i; j < k; j++) {
                                        NSDictionary *dTemp2 = [arrTemp objectAtIndex:j];
                                        if (([[[dTempLevel2 objectForKey:@"Data"] valueForKey:@"Level"] intValue] == 2 && [[[dTemp objectForKey:@"Data"] valueForKey:@"Id"] intValue] == [[[dTemp2 objectForKey:@"Data"] valueForKey:@"ParentQuestion"] intValue]) ||
                                            ([[[dTempLevel2 objectForKey:@"Data"] valueForKey:@"Level"] intValue] == 2 && [[dTemp2 valueForKey:@"ParentQuestion"] intValue] == [[[dTemp objectForKey:@"Data"] valueForKey:@"Id"] intValue])
                                            ){
                                            NSLog(@"level 2222");
                                            [arrIndex addObject:[NSString stringWithFormat:@"%d", j]];
                                        }
                                    }
                                    [arrIndex addObject:[NSString stringWithFormat:@"%d", i]];
                                }else{
                                    [arrIndex addObject:[NSString stringWithFormat:@"%d", i]];
                                }
                            }
                        }
                        else if ([[dTemp objectForKey:@"Level"] intValue] >= 1 && [[dTemp valueForKey:@"ParentQuestion"] intValue] == [[[[arraySurveyParse objectAtIndex:indexPath.row - intPositionAnswer - 1] objectForKey:@"Data"] valueForKey:@"Id"] intValue]) {
                            [arrIndex addObject:[NSString stringWithFormat:@"%d", i]];
                        }
                    }
                    //                NSLog(@"arrIndex = %@", arrIndex);
//                    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(indexPath.row + 1, arrIndex.count)];
                    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(indexPath.row + intTotalAnswer - intPositionAnswer, arrIndex.count)];
                    [arrTemp removeObjectsAtIndexes:indexSet];
                    arraySurveyParse = [NSMutableArray arrayWithArray:arrTemp];
                }else if ([[[arraySurveyParse objectAtIndex:indexPath.row] valueForKey:@"Level"] intValue] == 1){
                    NSMutableArray *arrTemp = [arraySurveyParse mutableCopy];
                    int k = arrTemp.count;
                    NSMutableArray *arrIndex = [[NSMutableArray alloc] init];
                    for (int i = 0; i < k; i++) {
                        NSDictionary *dTemp = [arrTemp objectAtIndex:i];
                        if ([dTemp objectForKey:@"Data"]) {
                            if ([[[dTemp objectForKey:@"Data"] valueForKey:@"Level"] intValue] >= 2 && [[[dTemp objectForKey:@"Data"] valueForKey:@"ParentQuestion"] intValue] == [[[[arraySurveyParse objectAtIndex:indexPath.row - intPositionAnswer - 1] objectForKey:@"Data"] valueForKey:@"Id"] intValue]) {
                                [arrIndex addObject:[NSString stringWithFormat:@"%d", i]];
                            }
                        }
                        else if ([[dTemp objectForKey:@"Level"] intValue] >= 2 && [[dTemp valueForKey:@"ParentQuestion"] intValue] == [[[[arraySurveyParse objectAtIndex:indexPath.row - 2] objectForKey:@"Data"] valueForKey:@"Id"] intValue]) {
                            [arrIndex addObject:[NSString stringWithFormat:@"%d", i]];
                        }
                    }
//                    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(indexPath.row + 1, arrIndex.count)];
                    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(indexPath.row + intTotalAnswer - intPositionAnswer, arrIndex.count)];
                    [arrTemp removeObjectsAtIndexes:indexSet];
                    arraySurveyParse = [NSMutableArray arrayWithArray:arrTemp];
                }
                [_tableViewSurvey reloadData];
            }else{
                
                for (int i = 0; i < [[[arraySurveyParse objectAtIndex:indexPath.row] valueForKey:@"TotalAnswer"] intValue]; i++) {
                    int j = [[[arraySurveyParse objectAtIndex:indexPath.row] valueForKey:@"PositionAnswer"] intValue];
                    NSDictionary *dT = [arraySurveyParse objectAtIndex:indexPath.row - j + i];
                    NSDictionary *dStatus;// = [arraySurveyParse objectAtIndex:indexPath.row - j + i];
                    dStatus = [dT mutableCopy];
                    [dStatus setValue:@"" forKey:@"Status"];
                    [arraySurveyParse removeObjectAtIndex:indexPath.row - j + i];
                    [arraySurveyParse insertObject:dStatus atIndex:indexPath.row - j + i];
                }
                NSDictionary *dT = [arraySurveyParse objectAtIndex:indexPath.row];
                NSDictionary *dStatus;
                dStatus = [dT mutableCopy];
                [dStatus setValue:@"Active" forKey:@"Status"];
                [arraySurveyParse removeObjectAtIndex:indexPath.row];
                [arraySurveyParse insertObject:dStatus atIndex:indexPath.row];
                
                [_tableViewSurvey reloadData];
            }
        }else{
            // set status for row
            
            NSDictionary *dStatus;
            NSDictionary *dT = [arraySurveyParse objectAtIndex:indexPath.row];
            dStatus = [dT mutableCopy];
            if ([[dStatus valueForKey:@"Status"] isEqualToString:@"Active"]) {
                [dStatus setValue:@"" forKey:@"Status"];
            }else{
                [dStatus setValue:@"Active" forKey:@"Status"];
            }
            [arraySurveyParse removeObjectAtIndex:indexPath.row];
            [arraySurveyParse insertObject:dStatus atIndex:indexPath.row];
            // end set status for row
            NSLog(@"arraySurveyParse = %@", arraySurveyParse);
            [_tableViewSurvey reloadData];
        }
    }
}

- (IBAction)TouchDoneDate:(id)sender {
    self.tabBarController.tabBar.hidden = NO;
    self.navigationController.navigationBarHidden = NO;
    _viewPickerDate.hidden = YES;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    strDate = [dateFormatter stringFromDate:_datePicker.date];
    [[CLWeeklyCalendarView ShareInstance] redrawToDate:_datePicker.date];
}

- (IBAction)touchCancelDate:(id)sender {
    self.tabBarController.tabBar.hidden = NO;
    self.navigationController.navigationBarHidden = NO;
    _viewPickerDate.hidden = YES;
}

- (IBAction)touchOkSideEffect:(id)sender {
    self.navigationController.navigationBarHidden = NO;
    self.tabBarController.tabBar.hidden = NO;
    _viewTableView.hidden = YES;
    NSString *strSideEffectChoise = @"";
    if (self.txtNameSideEffect.text.length > 0) {
        [arraySideEffectChoise addObject:self.txtNameSideEffect.text];
    }
    for (int i = 0; i < arraySideEffectChoise.count; i++) {
        if (strSideEffectChoise.length == 0) {
            strSideEffectChoise = [NSString stringWithFormat:@"%@", [arraySideEffectChoise objectAtIndex:i]];
        }else{
            strSideEffectChoise = [NSString stringWithFormat:@"%@,%@", strSideEffectChoise, [arraySideEffectChoise objectAtIndex:i]];
        }
    }
    if (strSideEffectChoise.length > 0) {
        self.txtNameSideEffect.text = @"";
        [arraySideEffectChoise removeAllObjects];
        [_tableViewSelectedSideEffect reloadData];
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"MM/dd/yyyy"];
        NSDate *dateNow = [NSDate date];
        UIButton *btn = (UIButton *)sender;
        NSDictionary *dictTemp = [arrayCalendar objectAtIndex:btn.tag];
        [[AppDelegate shareInstance] showProgressHub];
        NSDictionary *dictAccount = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultLogin];
        NSDictionary *dictPost = @{
                                   @"patientid":[dictAccount valueForKey:@"PatientId"],
                                   @"results":strSideEffectChoise,
                                   @"calendarId":[NSString stringWithFormat:@"%@", [dictTemp Id]],
                                   @"TimeLogId":[NSString stringWithFormat:@"%@", [dictTemp TimeLogId]],
                                   @"calendarTypeId":[NSString stringWithFormat:@"%@", [dictTemp PatientCalendarTypeId]],
                                   @"protocoltype":@"1",
                                   @"datetime":strDate,//[format stringFromDate:dateNow],
                                   @"isbaseline":[dictTemp isBaseline],
                                   @"isoverride":@"false"
                                   };
        NSDictionary *dictParameter = @{
                                        @"parameter":[Settings EnCryptionDictionary:dictPost]
                                        };
        // pass dictTemp to postInputResult check if finish event and then remove register local notification for duration time
        NSDictionary *dPost = @{
                                @"dictParameter" : dictParameter,
                                @"dictTemp" : dictTemp
                                };
        //                    [self performSelectorInBackground:@selector(postInputResult:) withObject:dictParameter];
        [self performSelectorInBackground:@selector(postInputResult:) withObject:dPost];
    }else{
        UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:@"Warning!" message:@"Please input results!" preferredStyle:UIAlertControllerStyleAlert];
        [alertControl addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [alertControl dismissViewControllerAnimated:YES completion:nil];
        }]];
        [[AppDelegate shareInstance] hideProgressHub];
        [self presentViewController:alertControl animated:YES completion:nil];
    }
}

- (IBAction)touchCancelSideEffect:(id)sender {
    [arraySideEffectChoise removeAllObjects];
    [_tableViewSelectedSideEffect reloadData];
    self.navigationController.navigationBarHidden = NO;
    self.tabBarController.tabBar.hidden = NO;
    _viewTableView.hidden = YES;
}

#pragma mark survey

- (void)getListSurvey{
    NSDictionary *dictAccount = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultLogin];
    NSString *strLinkCalendar = [NSString stringWithFormat:@"%@%@", kLink, kSurvey];
    NSURL *url = [NSURL URLWithString:strLinkCalendar];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.HTTPAdditionalHeaders = @{@"token":[dictAccount valueForKey:@"token"]};
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:url sessionConfiguration:config];
    [manager.requestSerializer setTimeoutInterval:kMaxTimeOut];
    NSDictionary *dictTemp = [arrayCalendar objectAtIndex:_btnSendSurvey.tag];
//    NSDictionary *parameter = @{
//                                @"id":[dictTemp valueForKey:@"Id"]
//                                };
//    NSLog(@"egwg = %@", [NSString stringWithFormat:@"?id=%@", [Settings URLEncodeStringFromString:[Settings EnCryptionString:[dictTemp valueForKey:@"Id"]]]]);
    
    [manager GET:[NSString stringWithFormat:@"?id=%@", [dictTemp valueForKey:@"Id"]] parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"responseObject list survey = %@", responseObject);
        NSDictionary *dict = (NSDictionary *)responseObject;
//        arraySurvey = [dict valueForKey:@"results"];
        if ([[dict valueForKey:@"success"] intValue] == 1) {
            
            arraySurvey = (NSMutableArray*)[dict valueForKey:@"results"];
            NSLog(@"arraySurvey = %@", arraySurvey);
//            NSMutableArray *arrTmp = (NSMutableArray*)[dict valueForKey:@"results"];
            
//            NSString *strTemp = @"";
//            for (int i = 0; i < arrTmp.count; i++){
//                strTemp = [NSString stringWithFormat:@"%@%@", strTemp, [Settings DeCryptionString:[arrTmp objectAtIndex:i]]];
//            }
//            
//            NSLog(@"strTemp = %@", strTemp);
//            
//            NSData *data = [strTemp dataUsingEncoding:NSUTF8StringEncoding];
//            arraySurvey = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            for (int i = 0; i < arraySurvey.count; i++) {
                NSDictionary *dTemp = [arraySurvey objectAtIndex:i];
                
                NSMutableDictionary *dTempArr = [[NSMutableDictionary alloc] init];
                
                NSMutableDictionary *dTempRoot = [[NSMutableDictionary alloc] init];
                
                [dTempArr setValue:[dTemp valueForKey:@"Id"] forKey:@"Id"];
                [dTempArr setValue:[dTemp valueForKey:@"ParentQuestion"] forKey:@"ParentQuestion"];
                [dTempArr setValue:[dTemp valueForKey:@"QuestionName"] forKey:@"QuestionName"];
                [dTempArr setValue:[dTemp valueForKey:@"QuestionType"] forKey:@"QuestionType"];
                [dTempArr setValue:@"0" forKey:@"Level"];
                [dTempArr setValue:[NSString stringWithFormat:@"%d", i] forKey:@"PositionParent"];
                
                [dTempRoot setValue:dTempArr forKey:@"Data"];
                [arraySurveyParse addObject:dTempRoot];
                
                // add answers to array survey parse
                NSArray *arrTemp = [dTemp objectForKey:@"Answers"];
                for (int j = 0; j < arrTemp.count; j++) {
                    NSDictionary *dT = [arrTemp objectAtIndex:j];
                    NSMutableDictionary *dTempAnswer = [[NSMutableDictionary alloc] init];
                    [dTempAnswer setValue:[dT valueForKey:@"Id"] forKey:@"Id"];
                    [dTempAnswer setValue:[dT valueForKey:@"AnswerName"] forKey:@"AnswerName"];
                    [dTempAnswer setValue:[dT valueForKey:@"isShowChild"] forKey:@"isShowChild"];
                    [dTempAnswer setValue:@"0" forKey:@"Level"];
                    [dTempAnswer setValue:[NSString stringWithFormat:@"%d", i] forKey:@"Position"];
                    [dTempAnswer setValue:[NSString stringWithFormat:@"%d", i] forKey:@"indexAnswer"];
                    [dTempAnswer setValue:[dTemp valueForKey:@"ParentQuestion"] forKey:@"ParentQuestion"];
                    [dTempAnswer setValue:[dTemp valueForKey:@"QuestionType"] forKey:@"QuestionType"];
                    [dTempAnswer setValue:[NSString stringWithFormat:@"%d", j] forKey:@"PositionAnswer"];
                    [dTempAnswer setValue:[NSString stringWithFormat:@"%lu", (unsigned long)arrTemp.count] forKey:@"TotalAnswer"];
                    [dTempAnswer setValue:@"" forKey:@"Status"];
                    [arraySurveyParse addObject:dTempAnswer];
                }
            }
            NSLog(@"arraySurveyParse = %@", arraySurveyParse);
            [self performSelectorOnMainThread:@selector(refreshUISurvey) withObject:nil waitUntilDone:YES];
        }else{
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

- (void)refreshUISurvey{
    self.navigationController.navigationBarHidden = YES;
    self.tabBarController.tabBar.hidden = YES;
    NSDictionary *dTemp = [arrayCalendar objectAtIndex:_btnSendSurvey.tag];
    _lblTitleSurveyTouch.text = [dTemp DisplayName];
    _viewSurvey.hidden = NO;
    [_tableViewSurvey reloadData];
    [[AppDelegate shareInstance] hideProgressHub];
}

- (IBAction)touchSendSurvey:(id)sender {
    NSLog(@"arraysurvey parse = %@", arraySurveyParse);
    _btnSurveyReminder.tag = -1;
    self.navigationController.navigationBarHidden = NO;
    self.tabBarController.tabBar.hidden = NO;
    _viewSurvey.hidden = YES;
    
    [[AppDelegate shareInstance] showProgressHub];
    
    [self performSelectorInBackground:@selector(sendSurvey) withObject:nil];
    
    
//    self.navigationController.navigationBarHidden = NO;
//    self.tabBarController.tabBar.hidden = NO;
//    _viewSurvey.hidden = YES;
}

- (IBAction)touchReminderSurvey:(id)sender {
//    [arraySurveyParse removeAllObjects];
//    [_tableViewSurvey reloadData];
    // save data for later
    [[NSUserDefaults standardUserDefaults] setObject:arraySurveyParse forKey:kReminderSurvey];
    [[NSUserDefaults standardUserDefaults] setObject:dictInputTextSurvey forKey:kDictInputTextSurvey];
    [[NSUserDefaults standardUserDefaults] setObject:arraySurvey forKey:kArraySurvey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    // end save data for later
    _btnSurveyReminder.tag = _btnSendSurvey.tag;
    self.navigationController.navigationBarHidden = NO;
    self.tabBarController.tabBar.hidden = NO;
    _viewSurvey.hidden = YES;
}

- (void)alertWarning{
    UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:@"Warning!" message:@"Please Answer the question." preferredStyle:UIAlertControllerStyleAlert];
    [alertControl addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [alertControl dismissViewControllerAnimated:YES completion:nil];
    }]];
    [self presentViewController:alertControl animated:YES completion:nil];
    [[AppDelegate shareInstance] hideProgressHub];
}

//- (void)refreshUISurveyPost{
//    self.navigationController.navigationBarHidden = NO;
//    self.tabBarController.tabBar.hidden = NO;
//    _viewSurvey.hidden = YES;
//    [[AppDelegate shareInstance] hideProgressHub];
//}

- (void)sendSurvey{
    
    NSMutableArray *arrTemp = [[NSMutableArray alloc] init];
//    NSString *strIdCheckedBox = @"";
    NSMutableArray *arrayIDCheckedBox = [[NSMutableArray alloc] init];
    NSString *strCheckedBox = @"";
    bool bCheckedBox = false;
    bool bCheckAll = true;
    bool bCheckActive = false;
    NSMutableDictionary *dTemp;
    // get data from array survey parse
    int iData = 0;
    NSInteger iCountSurvey = arraySurveyParse.count;
    
    for (int ji = 0; ji < iCountSurvey; ji++) {
        
        NSLog(@"ji = %d", ji);
    }
    
    for (int i = 0; i < iCountSurvey; i++) {
//        NSMutableDictionary *dTemp = [[NSMutableDictionary alloc] init];
        NSDictionary *d = [arraySurveyParse objectAtIndex:i];
//        NSLog(@"data = %@", [[d objectForKey:@"Data"] valueForKey:@"QuestionName"]);
        NSLog(@"d = %@", d);
        NSLog(@"i = %d", i);
        if ([d objectForKey:@"Data"]) {
            iData = iData + 1;
            // create dictionary for checkedbox
            if (bCheckedBox) {
                bCheckedBox = false;
//                NSArray *arr = [NSArray arrayWithObjects:strIdCheckedBox, nil];
//                [dTemp setValue:arr forKey:@"Answer"];
                [dTemp setValue:arrayIDCheckedBox forKey:@"Answer"];
                
                [dTemp setValue:strCheckedBox forKey:@"OtherAnswer"];
                
                [arrTemp addObject:dTemp];
//                strIdCheckedBox = @"";
                arrayIDCheckedBox = [[NSMutableArray alloc] init];
                strCheckedBox = @"";
            }
            dTemp = [[NSMutableDictionary alloc] init];
            [dTemp setValue:[d valueForKey:@"AnswerName"] forKey:@"OtherAnswer"];
//            [dTemp setValue:@"abcde" forKey:@"OtherAnswer"];
            [dTemp setValue:[[d objectForKey:@"Data"] valueForKey:@"Id"] forKey:@"QuestionId"];
        }else if ([[d objectForKey:@"QuestionType"] isEqualToString:@"1"]){//([[d valueForKey:@"AnswerName"] isEqualToString:@"Yes"]){
            
            
            if ([[d valueForKey:@"Status"] isEqualToString:@"Active"]) {
                NSArray *arr = [NSArray arrayWithObjects:[d valueForKey:@"Id"], nil];
                
                [dTemp setValue:arr forKey:@"Answer"];
                [dTemp setValue:[d valueForKey:@"AnswerName"] forKey:@"OtherAnswer"];
                //                [dTemp setValue:@"abcde" forKey:@"OtherAnswer"];
                [arrTemp addObject:dTemp];
                bCheckActive = true;
            }
            
            // check position answer
            if ([[d valueForKey:@"TotalAnswer"] integerValue] == [[d valueForKey:@"PositionAnswer"] integerValue] + 1) {
                if (!bCheckActive) {
                    [self performSelectorOnMainThread:@selector(alertWarning) withObject:nil waitUntilDone:NO];
                    bCheckAll = false;
                    break;
                }else{
                    bCheckActive = false;
                }
            }
            
            
//            if ([[d valueForKey:@"Status"] isEqualToString:@"Active"]) {
//                NSArray *arr = [NSArray arrayWithObjects:[d valueForKey:@"Id"], nil];
//                
//                [dTemp setValue:arr forKey:@"Answer"];
//                [dTemp setValue:[d valueForKey:@"AnswerName"] forKey:@"OtherAnswer"];
////                [dTemp setValue:@"abcde" forKey:@"OtherAnswer"];
//                [arrTemp addObject:dTemp];
//            }else{
//                NSDictionary *dNo = [arraySurveyParse objectAtIndex:i+1];
//                if ([[dNo valueForKey:@"Status"] isEqualToString:@"Active"]) {
//                    NSArray *arr = [NSArray arrayWithObjects:[dNo valueForKey:@"Id"], nil];
//                    [dTemp setValue:arr forKey:@"Answer"];
//                    [dTemp setValue:[dNo valueForKey:@"AnswerName"] forKey:@"OtherAnswer"];
////                    [dTemp setValue:@"abcde" forKey:@"OtherAnswer"];
//                    [arrTemp addObject:dTemp];
//                }else{
//                    [self performSelectorOnMainThread:@selector(alertWarning) withObject:nil waitUntilDone:NO];
//                    bCheckAll = false;
//                    break;
//                }
//            }
        }
//        else if ([[d valueForKey:@"AnswerName"] isEqualToString:@"Yes"]){
//            if ([[d valueForKey:@"Status"] isEqualToString:@"Active"]) {
//                NSArray *arr = [NSArray arrayWithObjects:[d valueForKey:@"Id"], nil];
//                
//                [dTemp setValue:arr forKey:@"Answer"];
//                [dTemp setValue:[d valueForKey:@"AnswerName"] forKey:@"OtherAnswer"];
//                //                [dTemp setValue:@"abcde" forKey:@"OtherAnswer"];
//                [arrTemp addObject:dTemp];
//            }else{
//                NSDictionary *dNo = [arraySurveyParse objectAtIndex:i+1];
//                if ([[dNo valueForKey:@"Status"] isEqualToString:@"Active"]) {
//                    NSArray *arr = [NSArray arrayWithObjects:[dNo valueForKey:@"Id"], nil];
//                    [dTemp setValue:arr forKey:@"Answer"];
//                    [dTemp setValue:[dNo valueForKey:@"AnswerName"] forKey:@"OtherAnswer"];
//                    //                    [dTemp setValue:@"abcde" forKey:@"OtherAnswer"];
//                    [arrTemp addObject:dTemp];
//                }else{
//                    [self performSelectorOnMainThread:@selector(alertWarning) withObject:nil waitUntilDone:NO];
//                    bCheckAll = false;
//                    break;
//                }
//            }
//        }
        else if ([[d objectForKey:@"QuestionType"] isEqualToString:@"2"]){//([[d valueForKey:@"AnswerName"] isEqualToString:@"text"] || [[d valueForKey:@"AnswerName"] isEqualToString:@"textbox"]){
            NSLog(@"dictInputTextSurvey = %@", dictInputTextSurvey);
//            UITextField *txt = (UITextField *)[_tableViewSurvey viewWithTag:50 + [[d valueForKey:@"Id"] integerValue]];
//            NSLog(@"txt%@ = %@", [d valueForKey:@"Id"], txt.text);
            NSArray *arr = [NSArray arrayWithObjects:[d valueForKey:@"Id"], nil];
            NSLog(@"arr = %@", arr);
            [dTemp setValue:arr forKey:@"Answer"];
            
//            [dTemp setValue:strText forKey:@"OtherAnswer"];
            NSString *str123 = [dictInputTextSurvey valueForKey:[NSString stringWithFormat:@"key%d", 50 + [[d valueForKey:@"Id"] integerValue]]];
//            NSData *data123 = [str123 dataUsingEncoding:NSUTF8StringEncoding];
//            str123 = [[NSString alloc] initWithData:data123 encoding:NSUTF8StringEncoding];
            
            [dTemp setValue:str123 forKey:@"OtherAnswer"];
            
            [arrTemp addObject:dTemp];
        }else if (![[d valueForKey:@"AnswerName"] isEqualToString:@"No"]){
            if ([[d valueForKey:@"Status"] isEqualToString:@"Active"]) {
                bCheckedBox = true;
                [arrayIDCheckedBox addObject:[d valueForKey:@"Id"]];
                if (strCheckedBox.length == 0) {
//                    strIdCheckedBox = [NSString stringWithFormat:@"%@", [d valueForKey:@"Id"]];
                    strCheckedBox = [NSString stringWithFormat:@"%@", [d valueForKey:@"AnswerName"]];
                }else{
//                    strIdCheckedBox = [NSString stringWithFormat:@"%@,%@", strIdCheckedBox, [d valueForKey:@"Id"]];
                    strCheckedBox = [NSString stringWithFormat:@"%@,%@", strCheckedBox, [d valueForKey:@"AnswerName"]];
                }
            }
        }
    }
    NSLog(@"iData = %d", iData);
//    NSLog(@"arrTemp = %@", arrTemp);
    if (bCheckAll) {
        NSDictionary *dictAccount = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultLogin];
        NSString *strLinkCalendar = [NSString stringWithFormat:@"%@%@", kLink, kSurvey];
        NSURL *url = [NSURL URLWithString:strLinkCalendar];
//        NSLog(@"url = %@", [url absoluteString]);
        
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        config.HTTPAdditionalHeaders = @{@"token":[dictAccount valueForKey:@"token"]};
        
        AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:url sessionConfiguration:config];
        [manager.requestSerializer setTimeoutInterval:kMaxTimeOut];
        
//        manager.requestSerializer = [AFJSONRequestSerializer serializer];
//        manager.responseSerializer = [AFJSONResponseSerializer serializer];
//        [manager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
//        [manager setResponseSerializer:[AFHTTPRequestSerializer serializer]];
//        [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        
        NSLog(@"arrTemp = %@", arrTemp);
        // convert array object to string json
        NSError *err = NULL;
        NSData *data = [NSJSONSerialization dataWithJSONObject:arrTemp options:NSJSONWritingPrettyPrinted error:&err];
        NSString *strData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        // end convert array object to string json
        
        
        
        NSDictionary *dictTemp = [arrayCalendar objectAtIndex:_btnSendSurvey.tag];
        NSDictionary *dictPost = @{
                                   @"patientid":[NSString stringWithFormat:@"%@", [dictAccount valueForKey:@"PatientId"]],
                                   @"categoryid":[NSString stringWithFormat:@"%@", [dictTemp Id]],
                                   @"settingid":[NSString stringWithFormat:@"%d", [[dictTemp TimeLogId] intValue]],
                                   @"answers":strData//[NSString stringWithFormat:@"%@", arrTemp]
                                   };
        NSLog(@"dictPost = %@", dictPost);
        
        
//        NSError *err;
//        NSData *jsonData = [NSJSONSerialization  dataWithJSONObject:dictPost options:0 error:&err];
//        
//        NSString *strTemp = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//
//        NSString *key = SecretKey;
//        key = [[StringEncryption alloc] sha256:key length:31];
//        
//        NSData *encryptData = [[StringEncryption alloc] encrypt:[strTemp dataUsingEncoding:NSUTF8StringEncoding] key:key iv:IVKey];
//        
//        NSString *strEncrypt = [encryptData base64EncodedStringWithOptions:0];
//        
//        NSData *dataResponse = [[NSData alloc] initWithBase64EncodedString:[Settings EnCryptionDictionary:dictPost] options:NSUTF8StringEncoding];
//        NSString *strKey = [[StringEncryption alloc] sha256:SecretKey length:31];
//        
//        NSError *error = nil;
//        NSData *dataDecrypt = [[StringEncryption alloc] decrypt:dataResponse key:strKey iv:IVKey];
//        NSDictionary *dt = [NSJSONSerialization JSONObjectWithData:dataDecrypt options:NSJSONReadingMutableContainers error:&error];
//        NSLog(@"dt = %@", dt);
        
        // encryption
        // convert nsdictionary to nsstring
//        NSData *dataTemp = [NSJSONSerialization dataWithJSONObject:dictPost options:0 error:nil];
//        NSString *strTemp = [[NSString alloc] initWithData:dataTemp encoding:NSUTF8StringEncoding];
//        NSLog(@"strTemp = %@, length = %lu", strTemp, (unsigned long)strTemp.length);
//        NSMutableArray *arrTemp = [[NSMutableArray alloc] init];
//        
//        if (strTemp.length < 500) {
//            [arrTemp addObject:[Settings EnCryptionString:strTemp]];
//        }else{
//            int div = strTemp.length/500;
//            NSLog(@"div = %d", div);
//            for (int i = 0; i <= div; i++) {
//                if ((div - i) == 0) {
//                    [arrTemp addObject:[Settings EnCryptionString:[strTemp substringWithRange:NSMakeRange(500*i, strTemp.length%500)]]];
//                }else{
//                    [arrTemp addObject:[Settings EnCryptionString:[strTemp substringWithRange:NSMakeRange(i == 0 ?500*i:500*i + 1, 500)]]];
//                }
//                
//            }
//        }
        
//        NSData *da = [NSJSONSerialization dataWithJSONObject:arrTemp options:NSJSONWritingPrettyPrinted error:nil];
//        
//        NSDictionary *paraPost = @{
//                               @"parameter" : [[NSString alloc] initWithData:da encoding:NSUTF8StringEncoding]
//                               };
        // end convert nsdictionary to nsstring

        // end encryption
//        NSLog(@"paraPost = %@", paraPost);
        [manager POST:@"" parameters:dictPost progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"responseObject post survey = %@", responseObject);
            NSDictionary *dTemp = (NSDictionary *)responseObject;
            if ([[dTemp valueForKey:@"success"] intValue] == -1) {
                UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:@"Fail." message:[NSString stringWithFormat:@"%@", [dTemp valueForKey:@"message"]] preferredStyle:UIAlertControllerStyleAlert];
                [alertControl addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [alertControl dismissViewControllerAnimated:YES completion:nil];
                }]];
                [[AppDelegate shareInstance] hideProgressHub];
                [self presentViewController:alertControl animated:YES completion:nil];
            }else{
                [arraySurveyParse removeAllObjects];
                [dictInputTextSurvey removeAllObjects];

                NSDictionary *dTemp = [arrayCalendar objectAtIndex:_btnSendSurvey.tag];
                if ([[dTemp valueForKey:@"Id"] isEqualToString:[[NSUserDefaults standardUserDefaults] valueForKey:kEventIDSurvey]]){
//                    [[NSUserDefaults standardUserDefaults] setObject:arraySurveyParse forKey:kReminderSurvey];
//                    [[NSUserDefaults standardUserDefaults] setObject:dictInputTextSurvey forKey:kDictInputTextSurvey];
//                    [[NSUserDefaults standardUserDefaults] setObject:arraySurvey forKey:kArraySurvey];
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kEventIDSurvey];
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kReminderSurvey];
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kDictInputTextSurvey];
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kArraySurvey];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }

                [_tableViewSurvey reloadData];
                [self performSelectorInBackground:@selector(getListCalendar) withObject:nil];
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"error = %@", error);
            [arraySurveyParse removeAllObjects];
            [dictInputTextSurvey removeAllObjects];
            [_tableViewSurvey reloadData];
            UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:@"Warning!" message:@"Please check internet and try again." preferredStyle:UIAlertControllerStyleAlert];
            [alertControl addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [alertControl dismissViewControllerAnimated:YES completion:nil];
            }]];
            [[AppDelegate shareInstance] hideProgressHub];
            [self presentViewController:alertControl animated:YES completion:nil];
        }];
    }
}

#pragma mark end survey

#pragma mark UITextField Delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSLog(@"string = %@", string);
    NSLog(@"string123 = %@", textField.text);
    if (textField != _txtNameSideEffect && textField.tag < 50) {

        NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];

        // temperature
//        if (textField.tag == 38) {
//            return [Settings expressionResult:newString :kExpressionTemperature];
//        }else
        if (textField.tag == 35){
            // SPO2
            return [Settings expressionResult:newString :kExpressionSPO2];
        }else if (textField.tag == 36){
            // BP
            return [Settings expressionResult:newString :kExpressionBP];
        }else if (textField.tag == 37){
            // heart rate
            return [Settings expressionResult:newString :kExpressionHR];
        }else if (textField.tag == 39){
            // covid
            NSDictionary *dictTemp = [arrayCalendar objectAtIndex:index];
            if ([dictTemp.PatientCalendarTypeId intValue] == CovidLevel1 ||
                [dictTemp.PatientCalendarTypeId intValue] == CovidLevel2 ||
                [dictTemp.PatientCalendarTypeId intValue] == CovidLevel3) {
                if ([dictTemp.Max intValue] > 0) {
                    NSString *strExpress = [NSString stringWithFormat:@"^([0-%d]{0,1}+)$", [dictTemp.Max intValue]];//@"[0-9]";
                    return [Settings expressionResult:newString :strExpress];
                }
            }
        }

        NSError *error = nil;
        NSString *strExpress = @"^([0-9,/.]+)?$";
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:strExpress options:0 error:&error];
        NSInteger numberOfMatch = [regex numberOfMatchesInString:newString options:0 range:NSMakeRange(0, [newString length])];
        if (numberOfMatch == 0)
            return NO;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    if (textField == _txtNameSideEffect) {
        _tableViewSideEffect.hidden = YES;
    }
    return YES;
}

- (void)textFieldDidChange: (UITextField *)textField{
    if (textField == _txtNameSideEffect) {
        _tableViewSideEffect.hidden = NO;
        NSPredicate *pre = [NSPredicate predicateWithFormat:@"SELF beginswith[c] %@",textField.text];
        arraySideBarFilter = (NSMutableArray*)[arraySideBar filteredArrayUsingPredicate:pre];
        [_tableViewSideEffect reloadData];
    }else if (textField.tag == 35 ||
              textField.tag == 36 ||
              textField.tag == 37 ||
              textField.tag == 38 ||
              textField.tag == 39){
        if (textField.text.length > 0) {
            [actionCoInputResultOk setEnabled:YES];
        }else{
            [actionCoInputResultOk setEnabled:NO];
        }
    }else if (textField.tag > 50){
//        strText = textField.text;
        [dictInputTextSurvey setValue:textField.text forKey:[NSString stringWithFormat:@"key%ld", (long)textField.tag]];
//        [dictInputTextSurvey add];
    }
}

#pragma mark Delegate Creative SDK

#pragma mark sdk 协议
// comment 24/05/2020
-(void)OnSearchCompleted:(CRCreativeSDK *)bleSerialComManager{
    NSLog(@"scan complete");
    currentPort = nil;
    foundPorts = [[CRCreativeSDK sharedInstance] GetDeviceList];
    NSLog(@"foundPorts = %lu", (unsigned long)foundPorts.count);
    for (CreativePeripheral *p in foundPorts) {
        currentPort = p;
        [[CRCreativeSDK sharedInstance] connectDevice:p];
    }
    [[AppDelegate shareInstance] hideProgressHub];
}
-(void)crManager:(CRCreativeSDK *)crManager OnFindDevice:(CreativePeripheral *)port
{
    NSLog(@"port.advName = %@", port.advName);
    if([port.advName  isEqual: @"PC-200"]||[port.advName  isEqual: @"PC_300SNT"]||[port.advName  isEqual: @"PC-100"])
    {
        NSLog(@"dc ko");
        [[CRCreativeSDK sharedInstance] searchPortsTimeout];//停止扫描，返回

    }

}

//- timeout

//connect 成功
-(void)crManager:(CRCreativeSDK *)crManager OnConnected:(CreativePeripheral *)peripheral withResult:(resultCodeType)result CurrentCharacteristic:(CBCharacteristic *)theCurrentCharacteristic{

    NSString *connectString = [[NSString alloc] init];
    if (result == RESULT_SUCCESS)
    {
        connectString = @"The connection is successful.";
//        nibpBtn.hidden = FALSE;

//        bIsActionNibp = FALSE;

    }
    else
    {
        connectString = @"The connection failed!";

    }
    [self showAlert:connectString];
}

-(void)crManager:(CRCreativeSDK *)crManager OnConnectFail:(CBPeripheral *)port
{
//    scanBtn.enabled = TRUE;
//
//    nibpBtn.hidden = TRUE;
    [self showAlert:@"Disconnect!"];
}

-(void)showAlert:(NSString *)message
{
    if (![message isEqualToString:@"Disconnect!"]) {
        UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:message message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSDictionary *dictTemp = [arrayCalendar objectAtIndex:indexTakeMeasurement];
            if (BP == [dictTemp.PatientCalendarTypeId intValue]) {
                alertCo.message = @"BP Cuff: 0";
//                [[CRSpotCheck sharedInstance] SetNIBPAction:TRUE port:currentPort];
            }else if (SpO2 == [dictTemp.PatientCalendarTypeId intValue]){
                alertCo.message = @"Spo2: 0, PR: 0";
            }else if (Heart_Rate == [dictTemp.PatientCalendarTypeId intValue]){
                alertCo.message = @"PR: 0";
            }
            else if (Temperature == [dictTemp.PatientCalendarTypeId intValue]){
                alertCo.message = @"C: 0";
            }
            [self showPopupValuesDevice];
            [alertControl dismissViewControllerAnimated:YES completion:nil];
        }];
        [alertControl addAction:actionOk];
        [self presentViewController:alertControl animated:YES completion:nil];
    }
//    UIAlertView *connectAlert = [[UIAlertView alloc] initWithTitle:message message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//    [connectAlert show];
}

-(void)showAlert1:(NSString *)message
{
    self.tabBarController.tabBar.hidden = NO;
    self.navigationController.navigationBarHidden = NO;
        UIAlertView *connectAlert = [[UIAlertView alloc] initWithTitle:message message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [connectAlert show];
}

#pragma mark spotcheck delegate
// comment 24/05/2020
-(void)spotCheck:(CRSpotCheck *)spotCheck OnGetNIBPResult:(BOOL)bHR Pulse:(int)nPulse MAP:(int)nMap SYS:(int)nSys Dia:(int)nDia Grade:(int)nGrade BPErr:(int)nBPErr
{
    // do huyet ap
    // thu tu: Systolic, Diastolic, Pulse
    NSLog(@"nSys = %d", nSys);
    NSLog(@"nDia = %d", nDia);
    NSLog(@"nMap = %d", nMap);
    if (!nBPErr) {

        NSDictionary *dictTemp = [arrayCalendar objectAtIndex:indexTakeMeasurement];

        if (BP == [dictTemp.PatientCalendarTypeId intValue]) {
            [alertCo dismissViewControllerAnimated:YES completion:nil];
            UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:@"Measurement Results" message:[NSString stringWithFormat:@"SYS: %d, DIA: %d, PR: %d", nSys,nDia,nPulse] preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *actionAccept = [UIAlertAction actionWithTitle:@"Accept" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                NSDateFormatter *format = [[NSDateFormatter alloc] init];
                [format setDateFormat:@"MM/dd/yyyy"];
                NSDate *dateNow = [NSDate date];

                [[AppDelegate shareInstance] showProgressHub];
                NSDictionary *dictAccount = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultLogin];
                NSDictionary *dictPost = @{
                                           @"patientid":[dictAccount valueForKey:@"PatientId"],
                                           @"results":[NSString stringWithFormat:@"%d/%d/%d", nSys,nDia,nPulse],
                                           @"calendarId":[NSString stringWithFormat:@"%@", [dictTemp Id]],
                                           @"TimeLogId":[NSString stringWithFormat:@"%@", [dictTemp TimeLogId]],
                                           @"calendarTypeId":[NSString stringWithFormat:@"%@", [dictTemp PatientCalendarTypeId]],
                                           @"protocoltype":@"1",
                                           @"datetime":strDate,//[format stringFromDate:dateNow],
                                           @"isbaseline":[dictTemp isBaseline],// == 0 ? @"false" : @"true",
                                           @"isoverride":@"false"
                                           };
                NSDictionary *dictParameter = @{
                                                @"parameter":[Settings EnCryptionDictionary:dictPost]
                                                };
                // pass dictTemp to postInputResult check if finish event and then remove register local notification for duration time
                NSDictionary *dPost = @{
                                        @"dictParameter" : dictParameter,
                                        @"dictTemp" : dictTemp
                                        };
                //                    [self performSelectorInBackground:@selector(postInputResult:) withObject:dictParameter];
                [self performSelectorInBackground:@selector(postInputResult:) withObject:dPost];

                [alertControl dismissViewControllerAnimated:YES completion:nil];
            }];

            UIAlertAction *actionReMajor = [UIAlertAction actionWithTitle:@"Re-measure" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                [actionCoOk setEnabled:YES];
                [self showPopupValuesDevice];
                [[CRSpotCheck sharedInstance] SetNIBPAction:TRUE port:currentPort];

                [alertControl dismissViewControllerAnimated:YES completion:nil];
            }];
            [alertControl addAction:actionAccept];
            [alertControl addAction:actionReMajor];

            [self presentViewController:alertControl animated:YES completion:nil];
        }
    }

    if (nBPErr)
    {
        if (!checkError){
            checkError = true;
            [self ShowNibpError:nBPErr];
        }
    }
//    else
//    {
//
//        sysNum.text = [NSString stringWithFormat:@"%d",nSys];
//
//        diaNum.text = [NSString stringWithFormat:@"%d",nDia];
//
//        mapNum.text = [NSString stringWithFormat:@"%d",nMap];
//
//        pulseNum.text = [NSString stringWithFormat:@"%d",nPulse];
//    }

}

-(void) ShowNibpError:(int)nError
{
//    _viewPopupShowValue.hidden = true;
    [alertCo dismissViewControllerAnimated:YES completion:nil];
    NSString *message = [[NSString alloc] init];
    switch (nError) {
        case NIBP_ERROR_CUFF_NOT_WRAPPED:
            message = @"Cuff error";
            break;
        case NIBP_ERROR_OVERPRESSURE_PROTECTION:
            message = @"Overpressure protection";
            break;
        case NIBP_ERROR_NO_VALID_PULSE:
            message = @"No valid pulse measurement";
            break;
        case NIBP_ERROR_EXCESSIVE_MOTION:
            message = @"Excessive interference";
            break;
        case NIBP_ERROR_RESULT_FAULT:
            message = @"Invalid result";
            break;
        case NIBP_ERROR_AIR_LEAKAG:
            message = @"Air leakage";
            break;
        case NIBP_ERROR_LOW_POWER:
            message = @"Low battery,measurement terminated.";
            break;
        default:
            break;
    }
    
    [self showAlert1:message];
    
}

// comment 24/05/2020
-(void)spotCheck:(CRSpotCheck *)spotCheck OnGetNIBPRealTime:(BOOL)bHeartBeat NIBP:(int)nNIBP
{
    NSLog(@"OnGetNIBPRealTime");
//    cuffNum.text = [NSString stringWithFormat:@"%d",nNIBP];
//    NSArray *arr = (NSArray*)[dictCalendar results];
    NSDictionary *dictTemp = [arrayCalendar objectAtIndex:indexTakeMeasurement];

    if (BP == [dictTemp.PatientCalendarTypeId intValue]){
//        _lblValues.text = [NSString stringWithFormat:@"BP Cuff: %d", nNIBP];
        alertCo.message = [NSString stringWithFormat:@"BP Cuff: %d", nNIBP];
//        _btnOkPopup.hidden = true;
        [actionCoOk setEnabled:NO];
        checkError = false;
    }
}

-(void)spotCheck:(CRSpotCheck *)spotCheck OnGetNIBPAction:(BOOL)bStart
{
    NSLog(@"OnGetNIBPAction");
}


-(void)spotCheck:(CRSpotCheck *)spotCheck OnGetGlu:(int)nGlu ResultStatus:(int) nGluStatus
{

    NSString *tmpGlu = [[NSString alloc]init];
    float tmpGlufloat = ((float)nGlu)/10;
    tmpGlu = [NSString stringWithFormat:@"%2.1f",tmpGlufloat];
    NSLog(@"OnGetGlu");


}
-(void) showDeviceInfo:(int)nHWMajeor HWMinor:(int)nHWMinor SWMajor:(int)nSWMajeor SWMinor:(int)nSWMinor
{
    NSLog(@"nHWMinor");
}


-(void)spotCheck:(CRSpotCheck *)spotCheck OnGetDeviceVer:(int)nHWMajeor HWMinor:(int)nHWMinor SWMajor:(int)nSWMajeor SWMinor:(int)nSWMinor Power:(int)nPower Battery:(int)nBattery200
{
    NSLog(@"HWMinor");
}

//体温
-(void)spotCheck:(CRSpotCheck *)spotCheck OnGetTemp:(float)temp1
{
    // thu tu: Sp02, Pulse
    NSDictionary *dictTemp = [arrayCalendar objectAtIndex:indexTakeMeasurement];
    if (Temperature == [[dictTemp PatientCalendarTypeId] intValue]) {
        checkError = false;
        [actionCoOk setEnabled:NO];

        NSString *strAlertCo, *strResults;
        strAlertCo = [NSString stringWithFormat:@"C: %2.1f", temp1];
        strResults = [NSString stringWithFormat:@"%2.1f",temp1];
        alertCo.message = strAlertCo;

        [alertCo dismissViewControllerAnimated:YES completion:nil];
        UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:@"Measurement Results" message:strAlertCo preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *actionAccept = [UIAlertAction actionWithTitle:@"Accept" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSDateFormatter *format = [[NSDateFormatter alloc] init];
            [format setDateFormat:@"MM/dd/yyyy"];
            NSDate *dateNow = [NSDate date];

            [[AppDelegate shareInstance] showProgressHub];
            NSDictionary *dictAccount = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultLogin];
            NSDictionary *dictPost = @{
                                       @"patientid":[dictAccount valueForKey:@"PatientId"],
                                       @"results":strResults,
                                       @"calendarId":[NSString stringWithFormat:@"%@", [dictTemp Id]],
                                       @"TimeLogId":[NSString stringWithFormat:@"%@", [dictTemp TimeLogId]],
                                       @"calendarTypeId":[NSString stringWithFormat:@"%@", [dictTemp PatientCalendarTypeId]],
                                       @"protocoltype":@"1",
                                       @"datetime":strDate,//[format stringFromDate:dateNow],
                                       @"isbaseline":[dictTemp isBaseline],// == 0 ? @"false" : @"true",
                                       @"isoverride":@"false"
                                       };
            NSDictionary *dictParameter = @{
                                            @"parameter":[Settings EnCryptionDictionary:dictPost]
                                            };
            // pass dictTemp to postInputResult check if finish event and then remove register local notification for duration time
            NSDictionary *dPost = @{
                                    @"dictParameter" : dictParameter,
                                    @"dictTemp" : dictTemp
                                    };
            //                    [self performSelectorInBackground:@selector(postInputResult:) withObject:dictParameter];
            [self performSelectorInBackground:@selector(postInputResult:) withObject:dPost];

            [alertControl dismissViewControllerAnimated:YES completion:nil];
        }];

        UIAlertAction *actionReMajor = [UIAlertAction actionWithTitle:@"Re-measure" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [actionCoOk setEnabled:YES];
            [self showPopupValuesDevice];
            [alertControl dismissViewControllerAnimated:YES completion:nil];
        }];
        [alertControl addAction:actionAccept];
        [alertControl addAction:actionReMajor];

        [self presentViewController:alertControl animated:YES completion:nil];
    }
}

-(void)spotCheck:(CRSpotCheck *)spotCheck OnGetSpo2Wave:(struct dataWave *)wave
{
//    NSLog(@"OnGetSpo2Wave");
//    NSString *newString = [NSString stringWithFormat:@"%d,%d",wave[0].nWave,wave[1].nWave];
//    waveNum.text = newString;
}

-(void)spotCheck:(CRSpotCheck *)spotCheck OnGetSpo2Param:(BOOL)bProbeOff spo2Value:(int)nSpO2 prValue:(int)nPR piValue:(int)nPI mMode:(int)nMode spo2Status:(int)nStatus
{
    // thu tu: Sp02, Pulse
//    NSArray *arr = (NSArray*)[dictCalendar results];
    NSDictionary *dictTemp = [arrayCalendar objectAtIndex:indexTakeMeasurement];
    if (SpO2 == [[dictTemp PatientCalendarTypeId] intValue] || Heart_Rate == [[dictTemp PatientCalendarTypeId] intValue]) {
        checkError = false;
//        _lblValues.text = [NSString stringWithFormat:@"Spo2: %d, PR: %d", nSpO2, nPR];
        //[NSString stringWithFormat:@"Spo2: %d, PR: %d", nSpO2, nPR];
//        _btnOkPopup.hidden = true;
        [actionCoOk setEnabled:NO];
        if (nStatus == 0) {
            spo2 = nSpO2;
            pr = nPR;
        }
        NSString *strAlertCo, *strResults;
        if (SpO2 == [[dictTemp PatientCalendarTypeId] intValue]) {
            strAlertCo = [NSString stringWithFormat:@"Spo2: %d, PR: %d", spo2, pr];
            strResults = [NSString stringWithFormat:@"%d/%d", spo2,pr];
        }else{
            strAlertCo = [NSString stringWithFormat:@"PR: %d", pr];
            strResults = [NSString stringWithFormat:@"%d",pr];
        }
        alertCo.message = strAlertCo;
        if (bProbeOff){
            [alertCo dismissViewControllerAnimated:YES completion:nil];
            UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:@"Measurement Results" message:strAlertCo preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *actionAccept = [UIAlertAction actionWithTitle:@"Accept" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                NSDateFormatter *format = [[NSDateFormatter alloc] init];
                [format setDateFormat:@"MM/dd/yyyy"];
                NSDate *dateNow = [NSDate date];

                [[AppDelegate shareInstance] showProgressHub];
                NSDictionary *dictAccount = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultLogin];
                NSDictionary *dictPost = @{
                                           @"patientid":[dictAccount valueForKey:@"PatientId"],
                                           @"results":strResults,//[NSString stringWithFormat:@"%d/%d", spo2,pr],
                                           @"calendarId":[NSString stringWithFormat:@"%@", [dictTemp Id]],
                                           @"TimeLogId":[NSString stringWithFormat:@"%@", [dictTemp TimeLogId]],
                                           @"calendarTypeId":[NSString stringWithFormat:@"%@", [dictTemp PatientCalendarTypeId]],
                                           @"protocoltype":@"1",
                                           @"datetime":strDate,//[format stringFromDate:dateNow],
                                           @"isbaseline":[dictTemp isBaseline],// == 0 ? @"false" : @"true",
                                           @"isoverride":@"false"
                                           };
                NSDictionary *dictParameter = @{
                                                @"parameter":[Settings EnCryptionDictionary:dictPost]
                                                };
                // pass dictTemp to postInputResult check if finish event and then remove register local notification for duration time
                NSDictionary *dPost = @{
                                        @"dictParameter" : dictParameter,
                                        @"dictTemp" : dictTemp
                                        };
                //                    [self performSelectorInBackground:@selector(postInputResult:) withObject:dictParameter];
                [self performSelectorInBackground:@selector(postInputResult:) withObject:dPost];

                [alertControl dismissViewControllerAnimated:YES completion:nil];
            }];

            UIAlertAction *actionReMajor = [UIAlertAction actionWithTitle:@"Re-measure" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                [actionCoOk setEnabled:YES];
                [self showPopupValuesDevice];
                [alertControl dismissViewControllerAnimated:YES completion:nil];
            }];
            [alertControl addAction:actionAccept];
            [alertControl addAction:actionReMajor];

            [self presentViewController:alertControl animated:YES completion:nil];
        }
    }
    NSLog(@"nSpO2 = %d,nPI = %d,nPR = %d",nSpO2,nPI,nPR);
    NSLog(@"nStatus = %d", nStatus);
    NSLog(@"nMode = %d", nMode);
    NSLog(@"bProbeOff=%d", bProbeOff);

}
-(void)spotCheck:(CRSpotCheck *)spotCheck OnGetECGRealTime:(struct ecgWave)wave HR:(int)nHR lead:(BOOL)bLeadOff
{
    NSLog(@"OnGetECGRealTime");
    NSLog(@"nHR = %d", nHR);
//    NSString *string = [NSString string];
//
//    for (int i = 0; i<25; i++) {
//        string = [string stringByAppendingString:[NSString stringWithFormat:@"%d,",wave.wave[i].nWave]];
//    }
//    ecgWaveNum.text = string;
}

- (void) peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:
(CBCharacteristic *)characteristic error:(NSError *)error{
    NSLog(@"didWriteValueForCharacteristic characteristic = %@", characteristic);
    NSLog(@"didWriteValueForCharacteristic dung ko");
}

#pragma mark BLE

//-(void)FunTest : (NSString *)str{
//    NSString*  mDataStaring = str;
//    NSString *subStr =@"";
//    NSUInteger tlen=mDataStaring.length;
//    for(int i=0;i<tlen;i=i+2){
//        subStr = [mDataStaring substringWithRange:NSMakeRange(i, 2)];
//        int value=[self Fun_ConvertStringToInt:subStr];
//        NSLog(@"value=%d\n", value);
//    }
//}
//
//-(int)Fun_ConvertStringToInt:(NSString*)iDataStaring{
//    NSData* theData=[self bytesStringToData:iDataStaring];
//
//    int *values = [theData bytes];
//    //    NSUInteger cnt = [theData length];
//    return values[0];
//}
//-(NSData*)bytesStringToData:(NSString*)bytesString
//{
//    if (!bytesString || !bytesString.length) return NULL;
//    // Get the c string
//    const char *scanner=[bytesString cStringUsingEncoding:NSUTF8StringEncoding];
//    char twoChars[3]={0,0,0};
//    long bytesBlockSize = bytesString.length/2;
//    long counter = bytesBlockSize;
//    Byte *bytesBlock = malloc(bytesBlockSize);
//    if (!bytesBlock) return NULL;
//    Byte *writer = bytesBlock;
//    while (counter--) {
//        twoChars[0]=*scanner++;
//        twoChars[1]=*scanner++;
//        *writer++ = strtol(twoChars, NULL, 16);
//    }
//    return[NSData dataWithBytesNoCopy:bytesBlock length:bytesBlockSize freeWhenDone:YES];
//}

// method called whenever we have successfully connected to the BLE peripheral
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    //    [peripheral setDelegate:self];
    [self.Peripheral setDelegate:self];
    [peripheral discoverServices:nil];
//    self.connected = [NSString stringWithFormat:@"Connected: %@", peripheral.state == CBPeripheralStateConnected ? @"YES" : @"NO"];
}

// CBPeripheralDelegate - Invoked when you discover the peripheral's available services.
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    for (CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

- (void)peripheralDidUpdateName:(CBPeripheral *)peripheral{
    NSLog(@"peripheral = %@", peripheral);
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(NSError *)error{
    NSLog(@"service = %@, error = %@", service, error);
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    NSLog(@"didDiscoverDescriptorsForCharacteristic");
}

//- (void)setPolarH7HRMPeripheral:(CBPeripheral *)polarH7HRMPeripheral


- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"didFailToConnectPeripheral");
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error{
    NSLog(@"didWriteValueForDescriptor = %@", descriptor);
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error{
    NSLog(@"didUpdateValueForDescriptor = %@", descriptor);
}

// CBCentralManagerDelegate - This is called with the CBPeripheral class as its main input parameter. This contains most of the information there is to know about a BLE peripheral.
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    //(2)
    NSLog(@"peripheral didDiscoverPeripheral = %@", peripheral);
    NSLog(@"advertisementData = %@", advertisementData);
    NSLog(@"RSSI = %@", RSSI);
    NSString *localName = [advertisementData objectForKey:CBAdvertisementDataLocalNameKey];
    NSLog(@"localName =%@", localName);
    if (![localName isEqual:@""]) {
        // We found the Heart Rate Monitor
        [self.centralManager stopScan];
        self.Peripheral = peripheral;
        //		peripheral.delegate = self;
        self.Peripheral.delegate = self;
        [self.centralManager connectPeripheral:peripheral options:nil];
    }
}

// Invoked when you discover the characteristics of a specified service.
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    //(3)
    NSLog(@"service.UUID = %@", service.UUID);
    NSLog(@"service = %@", service.characteristics);
    ////    service.ch
    //    NSArray *arrCharac = service.characteristics;
    //    [[arrCharac objectAtIndex:0] UUID];
    ////    [charac UUID]
    ////    [charac properties];
    
    NSLog(@"gwegeggr = %@", [CBUUID UUIDWithString:E_BODY_SERVICE_UUID]);
    if ([service.UUID isEqual:[CBUUID UUIDWithString:E_BODY_SERVICE_UUID]])  {  // 1
        for (CBCharacteristic *aChar in service.characteristics)
        {
            
            //            uint8_t enableValue = 1;
            //            NSData *enableBytes = [NSData dataWithBytes:&enableValue length:sizeof(uint8_t)];
            //            UInt8 value = 0x01;
            //            NSData *data = [NSData dataWithBytes:&value length:sizeof(value)];
            // Request heart rate notifications
            //            [self.polarH7HRMPeripheral setNotifyValue:YES forCharacteristic:aChar];
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:E_BODY_NOTIFICATIONS_SERVICE_UUID]]) { // 2
                [self.Peripheral setNotifyValue:YES forCharacteristic:aChar];
            }
            // Request body sensor location
            else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:E_BODY_LOCATION_UUID]]) { // 3
                [self.Peripheral readValueForCharacteristic:aChar];
            }
            else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:E_BODY_ENABLE_SERVICE_UUID]]) { // 4
                // Read the value of the heart rate sensor
                [self.Peripheral setNotifyValue:YES forCharacteristic:aChar];
                uint16_t value = 0x10;
                //                UInt16 value = 0x10;
                NSData *data = [NSData dataWithBytes:&value length:sizeof(value)];
                //				[peripheral writeValue:data forCharacteristic:aChar type:CBCharacteristicWriteWithResponse];
                [self.Peripheral writeValue:data forCharacteristic:aChar type:CBCharacteristicWriteWithResponse];
            }
        }
    }
    // Retrieve Device Information Services for the Manufacturer Name
    if ([service.UUID isEqual:[CBUUID UUIDWithString:E_BODY_DEVICE_INFO_SERVICE_UUID]])  { // 5
        for (CBCharacteristic *aChar in service.characteristics)
        {
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:E_BODY_MANUFACTURER_NAME_UUID]]) {
                [self.Peripheral readValueForCharacteristic:aChar];
                NSLog(@"Found a Device Manufacturer Name Characteristic");
            }
        }
    }
    
}


// Invoked when you retrieve a specified characteristic's value, or when the peripheral device notifies your app that the characteristic's value has changed.
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    //(4)
    NSLog(@"peripheral = %@", peripheral);
    NSLog(@"characteristic = %@", characteristic);
    NSData *dataBytes = characteristic.value;
    NSLog(@"dataBytes = %@", dataBytes);
    [self displayTemperature:dataBytes];
    [self displayWeight:characteristic error:error];
    // Updated value for heart rate measurement received
    // Retrieve the characteristic value for manufacturer name received

    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:E_BODY_NOTIFICATIONS_SERVICE_UUID]]) { // 1
        // Get the Heart Rate Monitor BPM
//        [self getHeartBPMData:characteristic error:error];
        [self displayWeight:characteristic error:error];
    }
    
    
    // Add our constructed device information to our UITextView
//    self.deviceInfo.text = [NSString stringWithFormat:@"%@\n%@\n%@\n", self.connected, self.bodyData, self.manufacturer];  // 4
}

- (void)displayTemperature:(NSData *)dataBytes {
    // get the data's length
    // divide by two since we're creating an array
    // that holds 16-bit (two-byte) values
    NSUInteger dataLength = dataBytes.length/ 2;
    NSLog(@"dataLength = %lu", (unsigned long)dataLength);
    // 1
    // create an array to contain the 16-bit values
    uint16_t dataArray[dataLength];
    for (int i = 0; i < dataLength; i++) {
        dataArray[i] = 0;
    }
    
    // 2
    // extract the data from the dataBytes object
    [dataBytes getBytes:&dataArray length:dataLength * sizeof(uint16_t)];
    
    NSLog(@"dataBytes 123 = %@", dataBytes);
    
    NSString *str = [NSString stringWithFormat:@"%@", dataBytes];
    NSArray *arrr = [str componentsSeparatedByString:@" "];
    NSLog(@"arrr = %@", arrr[0]);
    NSString *strTemp = [arrr[0] substringFromIndex:1];
    if (arrr.count == 1) {
        strTemp = [strTemp substringToIndex:strTemp.length - 1];
    }
//    [self FunTest:strTemp];

    
    //    NSData *data4 = [dataBytes subdataWithRange:NSMakeRange(0, dataBytes.length)];
    //    NSLog(@"data4 = %@", data4);
    //    NSLog(@"dataBytes.length = %d", dataBytes.length);
    //    int value = CFSwapInt32BigToHost(*(int*)([data4 bytes]));
    //    NSLog(@"value = %d", value);
    // 3
    // get the value of the of the ambient temperature element
//    uint16_t rawAmbientTemp = dataArray[SENSOR_DATA_INDEX_TEMP_AMBIENT
//                                        ];
//    NSLog(@"rawAmbientTemp = %hu", rawAmbientTemp);
//    
//    uint16_t rawAmbienTe0 = dataArray[2];
//    NSLog(@"rawAmbienTe0 = %hu", rawAmbienTe0);
}

- (void)displayWeight:(CBCharacteristic *)character error:(NSError *)error{
    NSData *data = [character value];
    const uint16_t *conData = [data bytes];
    uint16_t weight = 0;
    uint16_t weight0 = 0;
    if ((conData[0] & 0x10) == 0) {
        NSLog(@"displayWeight if");
        weight = + conData[1];
        weight0 = + conData[0];
    }else{
        NSLog(@"displayWeight else");
        weight = CFSwapInt16LittleToHost(*(uint16_t *)(&conData[1]));
        weight0 = CFSwapInt16LittleToHost(*(uint16_t *)(&conData[0]));
    }
    NSLog(@"weight = %u", weight);
    NSLog(@"weight0 = %u", weight0);
    
    //    if (!character.isNotifying) {
    //        NSLog(@"stoppppp");
    ////        [self.centralManager connectPeripheral:peripheral options:nil];
    //        [self.centralManager cancelPeripheralConnection:_polarH7HRMPeripheral];
    //        NSLog(@"connected = %@", _polarH7HRMPeripheral.state == CBPeripheralStateConnected ? @"YES" : @"NO");
    //
    //        CBCentralManager *centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];
    //        //    [centralManager scanForPeripheralsWithServices:services options:nil];
    //        //    NSLog(@"centralManager = %ld", (long)[centralManager accessibilityElementCount]);
    //        self.centralManager = centralManager;
    ////        [self.centralManager stopScan];
    ////        [self.centralManager cancelPeripheralConnection:_polarH7HRMPeripheral];
    ////        [_polarH7HRMPeripheral isst];
    //    }
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central{

}


@end
