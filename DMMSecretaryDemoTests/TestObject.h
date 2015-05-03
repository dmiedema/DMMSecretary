//
//  TestObject.h
//  DMMSecretaryDemo
//
//  Created by Daniel on 1/20/15.
//  Copyright (c) 2015 Daniel Miedema. All rights reserved.
//

#import <Foundation/Foundation.h>
@class TestObject, DMMSecretaryNotification;

extern NSString * const TestInbox;
extern NSString * const TestNotification;
extern NSString * const AnotherTestNotification;

DMMSecretaryNotification * CreateTestNotification(TestObject *obj);

@interface TestObject : NSObject
- (void)testMethod;
- (void)anotherTestMethod;
@end
