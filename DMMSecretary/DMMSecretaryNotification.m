//
//  DMMSecretaryNotification.m
//  DMMSecretaryDemo
//
//  Created by Daniel on 1/19/15.
//  Copyright (c) 2015 Daniel Miedema. All rights reserved.
//

#import "DMMSecretaryNotification.h"

@implementation DMMSecretaryNotification

+ (instancetype)secretaryNotificationWithObserver:(id)observer selector:(SEL)selector name:(NSString *)name object:(id)object {
    NSAssert(observer, @"observer can not be nil");
    NSAssert(name && name.length > 0, @"name can not be nil or an empty string");
    return [[self alloc] initWithObserver:observer selector:selector name:name object:object];
}

- (instancetype)initWithObserver:(id)observer selector:(SEL)selector name:(NSString *)name object:(id)object {
    self = [super init];
    if (self) {
        self.observer = observer;
        self.selector = selector;
        self.name = name;
        self.object = object;
    }
    return self;
}

- (instancetype)init {
    NSAssert(NO, @"init should not be called directly. Use initWithObserver:selector:name:object");
    return nil;
}
@end
