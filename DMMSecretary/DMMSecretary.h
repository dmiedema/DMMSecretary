//
//  DMMSecretary.h
//  DMMSecretaryDemo
//
//  Created by Daniel on 1/19/15.
//  Copyright (c) 2015 Daniel Miedema. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DMMSecretaryNotification.h"

@interface DMMSecretary : NSObject

#pragma mark - Class Methods
+ (instancetype)sharedSecretary;

#pragma mark - Instace Methods
- (void)createInbox:(NSString *)identifier notifications:(NSArray *)notifications;

- (void)removeInbox:(NSString *)identifer;

- (void)addNotification:(DMMSecretaryNotification *)notification toInbox:(NSString *)inboxIdentifer;

- (NSArray *)notificationsObservedInbox:(NSString *)inboxIdentifier;

- (NSArray *)notificationsForInbox:(NSString *)inboxIdentifier;

- (void)removeNotification:(NSString *)notificationIdentifier fromInbox:(NSString *)inboxIdentifier;

- (void)startHoldMessagesForInbox:(NSString *)inboxIdentifier;

- (void)stopHoldingMessagesForInbox:(NSString *)inboxIdentifier;

- (void)sendHeldNotificationsForInbox:(NSString *)inboxIdentifier;

@end
