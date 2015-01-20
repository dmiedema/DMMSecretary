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
@end

@implementation DMMSecretary {
    dispatch_queue_t _secretaryQueue;
}

#pragma mark - -- Public --
#pragma mark - Class Methods
+ (instancetype)sharedSecretary {
    static DMMSecretary *_shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shared = [[DMMSecretary alloc] init];
    });
    return _shared;
}

#pragma mark - Instance Methods
- (void)createInbox:(NSString *)identifier notifications:(NSArray *)notifications {
    DMMSecretaryInbox *newInbox = [DMMSecretaryInbox inboxWithIdentifier:identifier];
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

- (NSArray *)notificationsObservedInbox:(NSString *)inboxIdentifier {
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

- (void)startHoldMessagesForInbox:(NSString *)inboxIdentifier {
    dispatch_barrier_sync(_secretaryQueue, ^{
        DMMSecretaryInbox *inbox = self.inboxes[inboxIdentifier];
        inbox.holdMessages = YES;
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

#pragma mark - -- Private --

- (instancetype)init {
    self = [super init];
    if (self) {
        _secretaryQueue = dispatch_queue_create("DMMSecretaryQueue", DISPATCH_QUEUE_SERIAL);
        _inboxes = [NSMutableDictionary dictionary];
    }
    return self;
}

@end
