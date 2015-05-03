//
//  DMMSecretaryInbox.m
//  DMMSecretaryDemo
//
//  Created by Daniel on 1/19/15.
//  Copyright (c) 2015 Daniel Miedema. All rights reserved.
//

#import "DMMSecretaryInbox.h"
#import "DMMSecretaryNotification.h"

@interface DMMSecretaryInbox()
@property (strong, nonatomic) NSMutableArray *notificationNames;
@property (strong, nonatomic) NSMutableArray *heldNotifications;
@end

@implementation DMMSecretaryInbox

#pragma mark - Class Methods
+ (instancetype)inboxWithIdentifier:(NSString *)identifer {
    DMMSecretaryInbox *inbox = [[self alloc] init];
    inbox.identifier = identifer;
    return inbox;
}

#pragma mark - Init
- (instancetype)init {
    self = [super init];
    if (self) {
        self.notificationNames     = [NSMutableArray array];
        self.heldNotifications     = [NSMutableArray array];
        self.notificationObservers = [NSMutableArray array];
    }
    return self;
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Getter
- (NSArray *)notifications {
    return [self.heldNotifications copy];
}

- (NSArray *)observedNotificationNames {
    return [self.notificationNames copy];
}
#pragma mark - Implementation
- (void)addNotificationToNotifications:(DMMSecretaryNotification *)notification {
    [self addNotification:notification];
}

- (void)removeNotificationFromNotifications:(NSString *)notificationIdentifier {
    [self removeNotification:notificationIdentifier];
}

- (void)sendHeldNotifications {
    for (NSNotification *notification in self.heldNotifications) {
        [self forwardNotification:notification];
    }
    [self clearHeldNotifications];
}

- (void)clearHeldNotifications {
    [self.heldNotifications removeAllObjects];
}

- (void)clearHeldNotificationsByName:(NSString *)notificationName {
    self.heldNotifications = [[self.heldNotifications filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name != %@", notificationName]] mutableCopy];
}


#pragma mark - Private
- (void)addNotification:(DMMSecretaryNotification *)notification {
    if ([self.notificationNames containsObject:notification]) { return; }
    
    [self.notificationNames addObject:notification.name];
    [self.notificationObservers addObject:notification];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceived:) name:notification.name object:notification.object];
}

- (void)removeNotification:(NSString *)notificationIdentifier {
    [self.notificationNames removeObject:notificationIdentifier];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:notificationIdentifier object:nil];

    __block NSInteger index = -1;
    [self.notificationObservers enumerateObjectsUsingBlock:^(DMMSecretaryNotification *obj, NSUInteger idx, BOOL *stop) {
        if ([obj.name isEqualToString:notificationIdentifier]) {
            index = idx;
            *stop = YES;
        }
    }];
    
    if (index >= 0) {
        [self.notificationObservers removeObjectAtIndex:index];
    }
}

#pragma mark - notificationReceived
- (void)notificationReceived:(NSNotification *)notification {
    if (self.isHoldingMessages) {
        if (self.onlyUniqueMessages) {
            NSUInteger indexOfNotification = [[self.heldNotifications valueForKeyPath:@"name"] indexOfObject:notification.name];
            if (indexOfNotification != NSNotFound) {
                [self.heldNotifications removeObjectAtIndex:indexOfNotification];
            }
        }
        [self.heldNotifications addObject:notification];
    } else {
        [self forwardNotification:notification];
    }
}

- (void)forwardNotification:(NSNotification *)notification {
    [self.notificationObservers enumerateObjectsUsingBlock:^(DMMSecretaryNotification *obj, NSUInteger idx, BOOL *stop) {
        if ([obj.name isEqualToString:notification.name]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [obj.observer performSelector:obj.selector withObject:notification];
#pragma clang diagnostic pop
        }
    }];
}
@end
