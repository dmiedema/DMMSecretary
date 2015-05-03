//
//  DMMSecretary.m
//  DMMSecretaryDemo
//
//  Created by Daniel on 1/19/15.
//  Copyright (c) 2015 Daniel Miedema. All rights reserved.
//

#import "DMMSecretary.h"
#import "DMMSecretaryInbox.h"

@interface DMMSecretary()
@property (strong, nonatomic) NSMutableDictionary *inboxes;

/*!
 Shared Secretary instance.

 There is only supposed to be one secretary. If you somehow create
 more than one odd things could happen.
 */
+ (instancetype)sharedSecretary;
@end

@implementation DMMSecretary {
    dispatch_queue_t _secretaryQueue;
}

#pragma mark - -- Public --
#pragma mark - Class Methods
+ (void)createInbox:(NSString *)identifier notifications:(NSArray *)notifications {
    [[DMMSecretary sharedSecretary] createInbox:identifier notifications:notifications];
}

+ (void)removeInbox:(NSString *)identifer {
    [[DMMSecretary sharedSecretary] removeInbox:identifer];
}

+ (void)addNotification:(DMMSecretaryNotification *)notification toInbox:(NSString *)inboxIdentifer {
    [[DMMSecretary sharedSecretary] addNotification:notification toInbox:inboxIdentifer];
}

+ (NSArray *)notificationsObservedByInbox:(NSString *)inboxIdentifier {
    return [[DMMSecretary sharedSecretary] notificationsObservedByInbox:inboxIdentifier];
}

+ (NSArray *)notificationsForInbox:(NSString *)inboxIdentifier {
    return [[DMMSecretary sharedSecretary] notificationsForInbox:inboxIdentifier];
}

+ (void)removeNotification:(NSString *)notificationIdentifier fromInbox:(NSString *)inboxIdentifier {
    [[DMMSecretary sharedSecretary] removeNotification:notificationIdentifier fromInbox:inboxIdentifier];
}

+ (void)startHoldingMessagesForInbox:(NSString *)inboxIdentifier {
    [[DMMSecretary sharedSecretary] startHoldingMessagesForInbox:inboxIdentifier];
}

+ (void)onlyKeepUniqueMessages:(BOOL)onlyUnique forInboxIdentifier:(NSString *)inboxIdentifier {
    [[DMMSecretary sharedSecretary] onlyKeepUniqueMessages:onlyUnique forInboxIdentifier:inboxIdentifier];
}

+ (void)stopHoldingMessagesForInbox:(NSString *)inboxIdentifier {
    [[DMMSecretary sharedSecretary] stopHoldingMessagesForInbox:inboxIdentifier];
}

+ (void)sendHeldNotificationsForInbox:(NSString *)inboxIdentifier {
    [[DMMSecretary sharedSecretary] sendHeldNotificationsForInbox:inboxIdentifier];
}

+ (void)dropAllHeldNotificationsForInbox:(NSString *)inboxIdentifier {
    [[DMMSecretary sharedSecretary] dropAllHeldNotificationsForInbox:inboxIdentifier];
}

+ (void)dropAllHeldNotifications:(NSString *)notificationName forInboxIdentifier:(NSString *)inboxIdentifier {
    [[DMMSecretary sharedSecretary] dropAllHeldNotifications:notificationName forInboxIdentifier:inboxIdentifier];
}

+ (void)changeObserverTo:(id)obserer forNotification:(NSString *)notificationName inInbox:(NSString *)inboxIdentifier {
    [[DMMSecretary sharedSecretary] changeObserverTo:obserer forNotification:notificationName inInbox:inboxIdentifier];
}

#pragma mark - -- Private --
#pragma mark - Shared Instance
+ (instancetype)sharedSecretary {
    static DMMSecretary *_shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shared = [[DMMSecretary alloc] init];
    });
    return _shared;
}
#pragma mark - Init
- (instancetype)init {
    self = [super init];
    if (self) {
        _secretaryQueue = dispatch_queue_create("DMMSecretaryQueue", DISPATCH_QUEUE_SERIAL);
        _inboxes = [NSMutableDictionary dictionary];
    }
    return self;
}

#pragma mark - Implementation
- (void)createInbox:(NSString *)identifier notifications:(NSArray *)notifications {
    if (self.inboxes[identifier]) { return; }

    DMMSecretaryInbox *newInbox = [DMMSecretaryInbox inboxWithIdentifier:identifier];
    if (!notifications) { notifications = @[]; }
    for (DMMSecretaryNotification *notification in notifications) {
        [newInbox addNotificationToNotifications:notification];
    }

    dispatch_barrier_sync(_secretaryQueue, ^{
        [self.inboxes addEntriesFromDictionary:@{identifier : newInbox}];
    });
}

- (void)removeInbox:(NSString *)identifer {
    NSAssert(identifer, @"identifier can no be nil");
    dispatch_barrier_sync(_secretaryQueue, ^{
        [self.inboxes removeObjectForKey:identifer];
    });
}

- (void)addNotification:(DMMSecretaryNotification *)notification toInbox:(NSString *)inboxIdentifer {
    dispatch_barrier_sync(_secretaryQueue, ^{
        [self.inboxes[inboxIdentifer] addNotificationToNotifications:notification];
    });
}

- (NSArray *)notificationsObservedByInbox:(NSString *)inboxIdentifier {
    __block NSArray *notifications;
    dispatch_barrier_sync(_secretaryQueue, ^{
        notifications = [self.inboxes[inboxIdentifier] observedNotificationNames];
    });
    return notifications;
}

- (NSArray *)notificationsForInbox:(NSString *)inboxIdentifier {
    __block NSArray *notifications;
    dispatch_barrier_sync(_secretaryQueue, ^{
        notifications = [self.inboxes[inboxIdentifier] notifications];
    });
    return notifications;
}

- (void)removeNotification:(NSString *)notificationIdentifier fromInbox:(NSString *)inboxIdentifier {
    dispatch_barrier_sync(_secretaryQueue, ^{
        [self.inboxes[inboxIdentifier] removeNotificationFromNotifications:notificationIdentifier];
    });
}

- (void)startHoldingMessagesForInbox:(NSString *)inboxIdentifier {
    dispatch_barrier_sync(_secretaryQueue, ^{
        DMMSecretaryInbox *inbox = self.inboxes[inboxIdentifier];
        inbox.holdMessages = YES;
    });
}

- (void)onlyKeepUniqueMessages:(BOOL)onlyUnique forInboxIdentifier:(NSString *)inboxIdentifier {
    dispatch_barrier_sync(_secretaryQueue, ^{
        DMMSecretaryInbox *inbox = self.inboxes[inboxIdentifier];
        inbox.onlyUniqueMessages = onlyUnique;
    });
}

- (void)stopHoldingMessagesForInbox:(NSString *)inboxIdentifier {
    dispatch_barrier_sync(_secretaryQueue, ^{
        DMMSecretaryInbox *inbox = self.inboxes[inboxIdentifier];
        inbox.holdMessages = NO;
    });
}

- (void)sendHeldNotificationsForInbox:(NSString *)inboxIdentifier {
    dispatch_barrier_sync(_secretaryQueue, ^{
        DMMSecretaryInbox *inbox = self.inboxes[inboxIdentifier];
        [inbox sendHeldNotifications];
    });
}

- (void)dropAllHeldNotificationsForInbox:(NSString *)inboxIdentifier {
    dispatch_barrier_async(_secretaryQueue, ^{
        DMMSecretaryInbox *inbox = self.inboxes[inboxIdentifier];
        [inbox clearHeldNotifications];
    });
}

- (void)dropAllHeldNotifications:(NSString *)notificationName forInboxIdentifier:(NSString *)inboxIdentifier {
    dispatch_barrier_async(_secretaryQueue, ^{
        DMMSecretaryInbox *inbox = self.inboxes[inboxIdentifier];
        [inbox clearHeldNotificationsByName:notificationName];
    });
}

- (void)changeObserverTo:(id)observer forNotification:(NSString *)notificationName inInbox:(NSString *)inboxIdentifier {
    dispatch_barrier_async(_secretaryQueue, ^{
        DMMSecretaryInbox *inbox = self.inboxes[inboxIdentifier];
        for (DMMSecretaryNotification *notification in inbox.notificationObservers) {
            if ([notification.name isEqualToString:notificationName]) {
                notification.observer = observer;
            }
        }
    });
}

@end
