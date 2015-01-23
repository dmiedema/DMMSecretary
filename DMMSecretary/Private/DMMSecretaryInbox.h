//
//  DMMSecretaryInbox.h
//  DMMSecretaryDemo
//
//  Created by Daniel on 1/19/15.
//  Copyright (c) 2015 Daniel Miedema. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DMMSecretaryNotification;

/*!
 The heart of it all.
 
 The Inbox watches & holds if necessary all @c NSNotification notifications sent for the @c defaultCenter.
 */
@interface DMMSecretaryInbox : NSObject
/// Identifer for the Inbox
@property (copy, nonatomic) NSString *identifier;
/// Currently held @c NSNotification objects
@property (nonatomic, readonly) NSArray *notifications;
/// Currently observed notification names
@property (nonatomic, readonly) NSArray *observedNotificationNames;
/// @c YES if inbox has been asked to hold notifications in the inbox. @c NO otherwise
@property (nonatomic, getter=isHoldingMessages) BOOL holdMessages;
/// @c YES to only keep a single copy of each message. @c NO to keep all copies. @c NO by default
@property (nonatomic) BOOL onlyUniqueMessages;

#pragma mark - Class Methods
/*!
 Create a new inbox with a specified identifer
 
 @param  identifier unique identifier to reference inbox by
 @return Created @c DMMSecretaryInbox object
 */
+ (instancetype)inboxWithIdentifier:(NSString *)identifer __attribute__((nonnull (1)));

#pragma mark - Instance Methods
/*!
 Add a notification to the inboxes observed notifications
 */
- (void)addNotificationToNotifications:(DMMSecretaryNotification *)notification __attribute__((nonnull (1)));

/*!
 Remove a notification from the observed notifications.
 
 Essentially a @c noop if it is not being observed
 */
- (void)removeNotificationFromNotifications:(NSString *)notificationIdentifier __attribute__((nonnull (1)));

/*!
 Forward all the held notifications to the set observes in the @c DMMSecretaryNotification objects in the inbox
 */
- (void)sendHeldNotifications;

/*!
 Remove all held notifications from the inbox
 */
- (void)clearHeldNotifications;
@end
