//
//  DMMSecretaryInbox.h
//  DMMSecretaryDemo
//
//  Created by Daniel on 1/19/15.
//  Copyright (c) 2015 Daniel Miedema. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DMMSecretaryNotification;
@interface DMMSecretaryInbox : NSObject
@property (copy, nonatomic) NSString *identifier;
@property (nonatomic, readonly) NSArray *notifications;
@property (nonatomic, readonly) NSArray *observedNotificationNames;
@property (nonatomic, getter=isHoldingMessages) BOOL holdMessages;

#pragma mark - Class Methods
+ (instancetype)inboxWithIdentifier:(NSString *)identifer __attribute__((nonnull (1)));

#pragma mark - Instance Methods
- (void)addNotificationToNotifications:(DMMSecretaryNotification *)notification __attribute__((nonnull (1)));

- (void)removeNotificationFromNotifications:(NSString *)notificationIdentifier __attribute__((nonnull (1)));

- (void)sendHeldNotifications;

- (void)clearHeldNotifications;
@end
