//
//  ZeroBalanceUITests.m
//  ZeroBalanceUITests
//
//  Created by Brad Bernard on 12/3/16.
//  Copyright © 2016 Brad Bernard. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface ZeroBalanceUITests : XCTestCase

@end

@implementation ZeroBalanceUITests

- (void)setUp {
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;
    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    [[[XCUIApplication alloc] init] launch];
    
    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testEmptyTableViewOnStartup {
    XCUIApplication *app = [[XCUIApplication alloc] init];
    XCTAssertEqual([app.tables elementBoundByIndex:0].cells.count, 0);
}

- (void)testAddPressedDisplaysNewTransactionControllerAndNoPayers {
    XCUIApplication *app = [[XCUIApplication alloc] init];
    NSLog(@"%@", app.tables.debugDescription);
    [app.navigationBars[@"Transactions"].buttons[@"Add"] tap];
    XCTAssert(app.navigationBars[@"New Transaction"].exists);
    XCTAssertEqual(app.tables[@"Payers Table"].cells.count, 0);
}

- (void)testTransactionNotAbleToBeSavedWhenEmptyFields {
    XCUIApplication *app = [[XCUIApplication alloc] init];
    [app.navigationBars[@"Transactions"].buttons[@"Add"] tap];
    
    [app.navigationBars[@"New Transaction"].buttons[@"Save"] tap];
    
    XCTAssert(app.alerts[@"Error"].exists);
    XCTAssert(app.alerts[@"Error"].buttons[@"OK"].exists);
}

- (void)testTransactionNotAbleToBeSavedWhenFilledOutThenCleared {
    XCUIApplication *app = [[XCUIApplication alloc] init];
    [app.navigationBars[@"Transactions"].buttons[@"Add"] tap];
    
    XCUIElement *nameTextField = app.textFields[@"Name"];
    XCUIElement *totalTextField = app.textFields[@"Total"];
    
    [nameTextField typeText:@"Pizza"];
    
    [totalTextField tap];
    [totalTextField typeText:@"2000"];
    
    [nameTextField tap];
    [nameTextField.buttons[@"Clear text"] tap];
    
    [app.navigationBars[@"New Transaction"].buttons[@"Save"] tap];
    
    XCTAssert(app.alerts[@"Error"].exists);
    XCTAssert(app.alerts[@"Error"].buttons[@"OK"].exists);
}

- (void)testNewTransactionNoPayersCancelThenShowsTableviewStillEmpty {
    XCUIApplication *app = [[XCUIApplication alloc] init];
    [app.navigationBars[@"Transactions"].buttons[@"Add"] tap];
    [app.textFields[@"Name"] typeText:@"Pizza"];
    
    XCUIElement *totalTextField = app.textFields[@"Total"];
    [totalTextField tap];
    [totalTextField typeText:@"2000"];
    [app.navigationBars[@"New Transaction"].buttons[@"Cancel"] tap];
    XCTAssertEqual(app.tables[@"Transactions Table"].cells.count, 0);
}

- (void)testAddingOnePayerMakesPayerTableUpdate {
    
    XCUIApplication *app = [[XCUIApplication alloc] init];
    [app.navigationBars[@"Transactions"].buttons[@"Add"] tap];
    [app.textFields[@"Name"] typeText:@"Pizza"];
    
    XCUIElement *totalTextField = app.textFields[@"Total"];
    [totalTextField tap];
    [totalTextField typeText:@"2000"];
    
    [app.buttons[@"Add Payer"] tap];
    
    [app.textFields[@"Paid"] typeText:@"300"];
    [app.buttons[@"Import from Contacts"] tap];
    [app.tables.staticTexts[@"John Appleseed"] tap];
    
    [app.navigationBars[@"New Payer"].buttons[@"Done"] tap];
    XCTAssertEqual(app.tables[@"Payers Table"].cells.count, 1);
}

@end
