//
//  AddPayeeViewController.m
//  ZeroBalance
//
//  Created by Brad Bernard on 12/17/16.
//  Copyright © 2016 Brad Bernard. All rights reserved.
//

#import "AddPayeeViewController.h"
#import "DataController.h"
#import "PaymentMO+CoreDataClass.h"
#import "TransactionMO+CoreDataClass.h"
#import "PersonMO+CoreDataClass.h"

@interface AddPayeeViewController ()

@end

@implementation AddPayeeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"%@", self.transaction);
}

# pragma mark - IBAction

- (IBAction)contactsPressed:(id)sender {
    CNContactPickerViewController *contactPicker = [[CNContactPickerViewController alloc] init];
    
    contactPicker.delegate = self;
    contactPicker.displayedPropertyKeys = (NSArray *)CNContactGivenNameKey;
    
    [self presentViewController:contactPicker animated:YES completion:nil];
}

# pragma mark - CNContactPickerDelegate

- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContact:(CNContact *)contact {
    NSLog(@"%@", contact);
}

- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContactProperty:(CNContactProperty *)contactProperty {
    NSLog(@"%@", contactProperty);
}

@end
