//
//  CalendarViewController.h
//  InterV
//
//  Created by HungLe on 10/4/16.
//  Copyright © 2016 HungLe. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <ExternalAccessory/ExternalAccessory.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface CalendarViewController : UIViewController<UITextFieldDelegate>
{
    NSDictionary *dictCalendar;
    NSTimer *timer;
    NSMutableArray *arrayCalendar;
    NSMutableArray *arraySideBar;
    NSMutableArray *arraySideBarFilter;
    NSMutableArray *arraySideEffectChoise;
    
    NSMutableArray *arraySurvey;
    NSMutableArray *arraySurveyParse;
    NSMutableArray *arrayQuestion;
    
    // moi them
    NSInteger index;
    // end moi them
    
    NSMutableArray *arrayIDRegisterPushNotifications;
}

@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) CBPeripheral     *Peripheral;

@property (weak, nonatomic) IBOutlet UITableView *tableViewCalendar;
@property (weak, nonatomic) IBOutlet UIView *viewPickerDate;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIView *viewTableView;
@property (weak, nonatomic) IBOutlet UITextField *txtNameSideEffect;
@property (weak, nonatomic) IBOutlet UIButton *btnSideEffectOk;
@property (weak, nonatomic) IBOutlet UITableView *tableViewSideEffect;
@property (weak, nonatomic) IBOutlet UITableView *tableViewSelectedSideEffect;
@property (weak, nonatomic) IBOutlet UIView *viewSurvey;
@property (weak, nonatomic) IBOutlet UIButton *btnSideEffectCancel;
@property (weak, nonatomic) IBOutlet UIButton *btnSurveyReminder;
- (IBAction)touchReminderSurvey:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnSendSurvey;
@property (weak, nonatomic) IBOutlet UILabel *lblTitleSurveyTouch;
@property (weak, nonatomic) IBOutlet UITableView *tableViewSurvey;
- (IBAction)TouchDoneDate:(id)sender;
- (IBAction)touchCancelDate:(id)sender;
+ (CalendarViewController*)ShareInstance;
- (void)touchLogout;
- (IBAction)touchSendSurvey:(id)sender;
- (void)showAlertWhenAppActive;
- (void)getEventImmediately;
- (void)getListCalendar;
- (void)showAlertBannerTop : (NSString *)string view : (UIView *)view;
@end
