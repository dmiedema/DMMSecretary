//
//  TestObject.m
//  DMMSecretaryDemo
//
//  Created by Daniel on 1/20/15.
//  Copyright (c) 2015 Daniel Miedema. All rights reserved.
//

#import "TestObject.h"
#import "DMMSecretaryNotification.h"

NSString * const TestInbox = @"Inbox";
NSString * const TestNotification = @"Notifcation";
NSString * const AnotherTestNotification = @"AnotherTestNotification";

DMMSecretaryNotification * CreateTestNotification(TestObject *obj) {
    return [DMMSecretaryNotification secretaryNotificationWithObserver:obj selector:@selector(testMethod) name:TestNotification object:nil];
}


@implementation TestObject
- (void)testMethod {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}
- (void)anotherTestMethod {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}
@end
