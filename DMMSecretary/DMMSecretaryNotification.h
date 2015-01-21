//
//  DMMSecretaryNotification.h
//  DMMSecretaryDemo
//
//  Created by Daniel on 1/19/15.
//  Copyright (c) 2015 Daniel Miedema. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 Basic notification object.
 
 @see @c addObserver:selector:name:object for @c NSNotificationCenter to see what this is modeled after
 */
@interface DMMSecretaryNotification : NSObject
/// Name of the notification to observe
@property (copy, nonatomic) NSString *name;
/// Object that should be notified
@property (weak, nonatomic) id observer;
/// Selector to perform when notification is observed/sent
@property (nonatomic) SEL selector;
/// Object to expect
@property (weak, nonatomic) id object;

/*!
 Convience method to help create a secretary notification object
 
 @param observer Object that should be notified when notification is sent
 @param selector Selector to perform on @c observer
 @param name     Name of @c NSNotification to observe/catch
 @param object   Object to expect when notification is sent
 */
+ (instancetype)secretaryNotificationWithObserver:(id)observer selector:(SEL)selector name:(NSString *)name object:(id)object __attribute__((nonnull (1, 2, 3)));

@end
