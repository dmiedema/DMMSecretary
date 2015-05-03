//
//  ViewController.m
//  DMMSecretaryDemo
//
//  Created by Daniel on 1/19/15.
//  Copyright (c) 2015 Daniel Miedema. All rights reserved.
//

#import "ViewController.h"
#import "DMMSecretary.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *sendNotification1Button;
@property (weak, nonatomic) IBOutlet UIButton *sendNotification2Button;
@property (weak, nonatomic) IBOutlet UIButton *sendNotification3Button;
@property (weak, nonatomic) IBOutlet UIButton *sendNotification4Button;
@property (weak, nonatomic) IBOutlet UISwitch *holdSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *onlyUniqueSwitch;

@property (weak, nonatomic) IBOutlet UILabel *totalCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *outputLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentHeldLabel;

@property (nonatomic) NSInteger totalNumberOfNotificationsReceived;
@end

NSString * const InboxIdentifer = @"ViewController";
NSString * const NotificationName1 = @"SecretaryNotificationType1";
NSString * const NotificationName2 = @"SecretaryNotificationType2";
NSString * const NotificationName3 = @"SecretaryNotificationType3";
NSString * const NotificationName4 = @"SecretaryNotificationType4";

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.totalNumberOfNotificationsReceived = 0;
    
    DMMSecretaryNotification *notification1 = [DMMSecretaryNotification secretaryNotificationWithObserver:self selector:@selector(notificationReceived:) name:NotificationName1 object:nil];
    DMMSecretaryNotification *notification2 = [DMMSecretaryNotification secretaryNotificationWithObserver:self selector:@selector(notificationReceived:) name:NotificationName2 object:nil];
    DMMSecretaryNotification *notification3 = [DMMSecretaryNotification secretaryNotificationWithObserver:self selector:@selector(notificationReceived:) name:NotificationName3 object:nil];
    DMMSecretaryNotification *notification4 = [DMMSecretaryNotification secretaryNotificationWithObserver:self selector:@selector(notificationReceived:) name:NotificationName4 object:nil];
    
    [DMMSecretary createInbox:InboxIdentifer notifications:@[notification1, notification2, notification3, notification4]];
}

- (IBAction)holdSwitchToggled:(UISwitch *)sender {
    if (sender.on) {
        [DMMSecretary startHoldingMessagesForInbox:InboxIdentifer];
    } else {
        NSLog(@"%@", [DMMSecretary notificationsObservedByInbox:InboxIdentifer]);
        NSLog(@"Held - %@", [DMMSecretary notificationsForInbox:InboxIdentifer]);
        [DMMSecretary stopHoldingMessagesForInbox:InboxIdentifer];
        [DMMSecretary sendHeldNotificationsForInbox:InboxIdentifer];
    }
    [self updateCurrentHeldLabel];
}
- (IBAction)onlyUniqueSwitchToggled:(UISwitch *)sender {
    [DMMSecretary onlyKeepUniqueMessages:sender.on forInboxIdentifier:InboxIdentifer];
}

- (IBAction)sendNotificationPressed:(UIButton *)sender {
    NSString *name = NotificationName1;
    if ([sender isEqual:self.sendNotification1Button]) {
        name = NotificationName1;
    } else if ([sender isEqual:self.sendNotification2Button]) {
        name = NotificationName2;
    } else if ([sender isEqual:self.sendNotification3Button]) {
        name = NotificationName3;
    } else if ([sender isEqual:self.sendNotification4Button]) {
        name = NotificationName4;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:name object:nil];
    
    [self updateCurrentHeldLabel];
}

- (void)updateCurrentHeldLabel {
    self.currentHeldLabel.text = [NSString stringWithFormat:@"Currently Held: %li", (long)[DMMSecretary notificationsForInbox:InboxIdentifer].count];
}

- (void)notificationReceived:(NSNotification *)notification {
    self.totalNumberOfNotificationsReceived++;
    self.totalCountLabel.text = [NSString stringWithFormat:@"Total Recieved Notifications: %li", (long)self.totalNumberOfNotificationsReceived];
    self.outputLabel.text = [NSString stringWithFormat:@"Notification Recieved - %@ : %@", notification.name, [NSDate date]];
}

@end
