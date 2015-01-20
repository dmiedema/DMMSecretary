//
//  DMMSecretaryNotification.h
//  DMMSecretaryDemo
//
//  Created by Daniel on 1/19/15.
//  Copyright (c) 2015 Daniel Miedema. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DMMSecretaryNotification : NSObject
@property (copy, nonatomic) NSString *name;
@property (weak, nonatomic) id observer;
@property (nonatomic) SEL selector;
@property (weak, nonatomic) id object;

+ (instancetype)secretaryNotificationWithObserver:(id)observer selector:(SEL)selector name:(NSString *)name object:(id)object __attribute__((nonnull (1, 2, 3)));

@end
