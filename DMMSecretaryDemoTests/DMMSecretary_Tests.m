//
//  DMMSecretary_Tests.m
//  DMMSecretaryDemo
//
//  Created by Daniel on 1/19/15.
//  Copyright (c) 2015 Daniel Miedema. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "TestObject.h"
#import "DMMSecretary.h"
#import "DMMSecretaryInbox.h"

@interface DMMSecretary (Tests)
- (void)cleanUpSecretary;
@end
@implementation DMMSecretary (Tests)
- (void)cleanUpSecretary {
    [[DMMSecretary sharedSecretary] setValue:[NSMutableDictionary dictionary] forKey:@"inboxes"];
}
@end

@interface DMMSecretary_Tests : XCTestCase
@property (strong, nonatomic) TestObject *obj;
@end

@implementation DMMSecretary_Tests
- (void)testCreatesInboxWhenAsked {
    NSDictionary *inboxes = [[DMMSecretary sharedSecretary] valueForKey:@"inboxes"];
    
    XCTAssertTrue([inboxes.allKeys containsObject:TestInbox], @"inboxes should contain key for %@", TestInbox);
}

- (void)testRemovesInbox {
    [[DMMSecretary sharedSecretary] removeInbox:TestInbox];
    NSDictionary *inboxes = [[DMMSecretary sharedSecretary] valueForKey:@"inboxes"];
    
    XCTAssertFalse([inboxes.allKeys containsObject:TestInbox], @"inboxes should not contain key for %@", TestInbox);
}

- (void)testPrivateQueueExists {
    dispatch_queue_t queue = [[DMMSecretary sharedSecretary] valueForKey:@"_secretaryQueue"];
    NSString *queueLabel = [NSString stringWithUTF8String:dispatch_queue_get_label(queue)];
    
    XCTAssertTrue([queueLabel isEqualToString:@"DMMSecretaryQueue"], @"Queue label should equal 'DMMSecretaryQueue'. Instead was %@", queueLabel);
}

- (void)testKeepsTrackOfObservedNotifications {
    [[DMMSecretary sharedSecretary] addNotification:CreateTestNotification(self.obj) toInbox:TestInbox];
    
    NSArray *observed = [[DMMSecretary sharedSecretary] notificationsObservedByInbox:TestInbox];
    
    XCTAssertTrue([observed containsObject:TestNotification], @"Observed notifications for %@ should contain %@", TestInbox, TestNotification);
}

- (void)testRemovesNotificationsFromInboxes {
    [[DMMSecretary sharedSecretary] addNotification:CreateTestNotification(self.obj) toInbox:TestInbox];
    
    [[DMMSecretary sharedSecretary] removeNotification:TestNotification fromInbox:TestInbox];
    
    NSArray *observed = [[DMMSecretary sharedSecretary] notificationsObservedByInbox:TestInbox];
    XCTAssertTrue(observed.count == 0, @"Observed notifications should be empty after removing %@", TestNotification);
}

- (void)testHoldsReceivedNotifications {
    id mock = [OCMockObject mockForClass:TestObject.class];
    
    [[DMMSecretary sharedSecretary] addNotification:CreateTestNotification(mock) toInbox:TestInbox];
    
    [[DMMSecretary sharedSecretary] startHoldingMessagesForInbox:TestInbox];
    
    [[mock expect] testMethod];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TestNotification object:nil];
    
    NSArray *held = [[DMMSecretary sharedSecretary] notificationsForInbox:TestInbox];
    XCTAssertTrue(held.count > 0, @"Notifications for inbox should have more than 0 items.");
    XCTAssertTrue([held.firstObject isKindOfClass:NSNotification.class], @"Held item should be of type NSNotification. Was type %@", NSStringFromClass(held.class));
}

- (void)testHoldsNotifications {
    id mock = [OCMockObject mockForClass:TestObject.class];
    
    [[DMMSecretary sharedSecretary] addNotification:CreateTestNotification(mock) toInbox:TestInbox];
    
    [[DMMSecretary sharedSecretary] startHoldingMessagesForInbox:TestInbox];
    
    [[mock expect] testMethod];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TestNotification object:nil];
    
    XCTAssertThrows([mock verify], @"mock should not have received %@", TestNotification);
}

- (void)testOnlyHoldsUniques {
    id mock = [OCMockObject mockForClass:TestObject.class];
    
    [[DMMSecretary sharedSecretary] addNotification:CreateTestNotification(mock) toInbox:TestInbox];
    
    [[DMMSecretary sharedSecretary] startHoldingMessagesForInbox:TestInbox];
    [[DMMSecretary sharedSecretary] onlyKeepUniqueMessages:YES forInboxIdentifier:TestInbox];
    [[mock expect] testMethod];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TestNotification object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:TestNotification object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:TestNotification object:nil];
    
    NSArray *heldNotifications = [[DMMSecretary sharedSecretary] notificationsForInbox:TestInbox];
    
    XCTAssertTrue(heldNotifications.count == 1, @"heldNotifications should only have 1 item. Instead had %li", heldNotifications.count);
}

- (void)testStopsHoldingNotifications {
    id mock = [OCMockObject mockForClass:TestObject.class];
    
    [[DMMSecretary sharedSecretary] addNotification:CreateTestNotification(mock) toInbox:TestInbox];
    
    [[DMMSecretary sharedSecretary] startHoldingMessagesForInbox:TestInbox];
    
    [[mock expect] testMethod];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TestNotification object:nil];
    
    XCTAssertThrows([mock verify], @"mock should not have received %@", TestNotification);
    
    [[DMMSecretary sharedSecretary] stopHoldingMessagesForInbox:TestInbox];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TestNotification object:nil];

    XCTAssertNoThrow([mock verify], @"mock should have received %@ after turning off holding", TestNotification);
}


- (void)testPassesHeldNotifications {
    id mock = [OCMockObject mockForClass:TestObject.class];
    
    [[DMMSecretary sharedSecretary] addNotification:CreateTestNotification(mock) toInbox:TestInbox];
    
    [[DMMSecretary sharedSecretary] startHoldingMessagesForInbox:TestInbox];
    
    [[mock expect] testMethod];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TestNotification object:nil];
    
    XCTAssertThrows([mock verify], @"mock should not have received %@", TestNotification);
    
    [[DMMSecretary sharedSecretary] sendHeldNotificationsForInbox:TestInbox];
    
    XCTAssertNoThrow([mock verify], @"mock should have received %@ after turning off holding", TestNotification);
}

- (void)testCreatingExistingInbox {
    [[DMMSecretary sharedSecretary] addNotification:CreateTestNotification(self.obj) toInbox:TestInbox];
    
    [[DMMSecretary sharedSecretary] createInbox:TestInbox notifications:@[]];
    
    NSArray *observed = [[DMMSecretary sharedSecretary] notificationsObservedByInbox:TestInbox];
    XCTAssertTrue(observed.count > 0, @"Creating an inbox that already exists should not overwrite existing inbox");
}

#pragma mark - Setup
- (void)setUp {
    self.obj = [TestObject new];
    
    [[DMMSecretary sharedSecretary] createInbox:TestInbox notifications:@[]];
    
    [super setUp];
}

- (void)tearDown {
    [[DMMSecretary sharedSecretary] cleanUpSecretary];
    self.obj = nil;
    [super tearDown];
}

@end
