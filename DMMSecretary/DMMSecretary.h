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
/*!
 Shared Secretary instance.
 
 There is only supposed to be one secretary. If you somehow create
 more than one odd things could happen.
 */
+ (instancetype)sharedSecretary;

#pragma mark - Instace Methods
/*!
 Ask the secretary to create an inbox with a specified identifier.
 Any number of notifications may be passed in for the secretary to watch
 
 @note This is essentially a @c noop if an inbox already exists for the specified identifier
 
 @param identifier    Specific inbox identifier. All access is done through this name and it must be unique and known.
 @param notifications array of @c DMMSecretaryNotification objects to watch. May be an empty array upon creation. If @c nil an empty array is assumed.
 */
- (void)createInbox:(NSString *)identifier notifications:(NSArray *)notifications __attribute__((nonnull (1)));

/*!
 Ask the secretary to remove an inbox for a specific identifier.
 
 @warning this will @e instantly remove the inbox and drop any references to existing notifications in the inbox.
 
 @param identifier inbox identifier to remove
 */
- (void)removeInbox:(NSString *)identifer __attribute__((nonnull (1)));

/*!
 Add a notificaiton to an existing inbox.
 
 @warning this assumes the inbox already exists.
 
 @param notification    notification to observer
 @param inboxIdentifier inbox to add the notifiation to.
 */
- (void)addNotification:(DMMSecretaryNotification *)notification toInbox:(NSString *)inboxIdentifer __attribute__((nonnull (1, 2)));

/*!
 Get the notification names that are being observed by the inbox.
 
 @param inboxIdentifer inbox to retrieve observed notifications for
 @return array of @c NSString objects that are the names of the notifications current being observed
 */
- (NSArray *)notificationsObservedByInbox:(NSString *)inboxIdentifier __attribute__((nonnull (1)));

/*!
 Get the current notifications in the inbox that have been held.
 
 @param inboxIdentifer inbox to retrieve the held notifications for
 @return array of @c NSNotification objects that are the notifications that have been held
 */
- (NSArray *)notificationsForInbox:(NSString *)inboxIdentifier __attribute__((nonnull (1)));

/*!
 Remove a notification from an inbox
 
 @param notificationIdentifier name of the notification to stop observing
 @param inboxIdentifier        inbox to stop observing that notification for
 */
- (void)removeNotification:(NSString *)notificationIdentifier fromInbox:(NSString *)inboxIdentifier __attribute__((nonnull (1, 2)));

/*!
 Ask the secretary to start holding messages.
 
 @param inboxIdentifer inbox to start holding messages for
 */
- (void)startHoldingMessagesForInbox:(NSString *)inboxIdentifier __attribute__((nonnull (1)));

/*!
 Ask the secretary to stop holding messages.
 
 @param inboxIdentifer inbox to stop holding messages for
 */
- (void)stopHoldingMessagesForInbox:(NSString *)inboxIdentifier __attribute__((nonnull (1)));

/*!
 Ask the secretary to foward all holding messages to the observer.
 
 @param inboxIdentifer inbox to forward mesages for
 */
- (void)sendHeldNotificationsForInbox:(NSString *)inboxIdentifier __attribute__((nonnull (1)));

@end
