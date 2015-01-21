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

DMMSecretaryNotification * CreateTestNotification(TestObject *obj);

@interface TestObject : NSObject
- (void)testMethod;
@end
