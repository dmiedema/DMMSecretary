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
- (void)createInbox:(NSString *)identifier notifications:(NSArray *)notifications __attribute__((nonnull (1, 2)));;;

- (void)removeInbox:(NSString *)identifer __attribute__((nonnull (1)));

- (void)addNotification:(DMMSecretaryNotification *)notification toInbox:(NSString *)inboxIdentifer __attribute__((nonnull (1, 2)));

- (NSArray *)notificationsObservedByInbox:(NSString *)inboxIdentifier __attribute__((nonnull (1)));

- (NSArray *)notificationsForInbox:(NSString *)inboxIdentifier __attribute__((nonnull (1)));

- (void)removeNotification:(NSString *)notificationIdentifier fromInbox:(NSString *)inboxIdentifier __attribute__((nonnull (1, 2)));

- (void)startHoldMessagesForInbox:(NSString *)inboxIdentifier __attribute__((nonnull (1)));

- (void)stopHoldingMessagesForInbox:(NSString *)inboxIdentifier __attribute__((nonnull (1)));

- (void)sendHeldNotificationsForInbox:(NSString *)inboxIdentifier __attribute__((nonnull (1)));

@end
