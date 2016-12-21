//
//  AddPayerViewController.h
//  ZeroBalance
//
//  Created by Brad Bernard on 12/17/16.
//  Copyright © 2016 Brad Bernard. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "TransactionMO+CoreDataClass.h"
#import <ContactsUI/ContactsUI.h>
#import <Contacts/Contacts.h>

@class AddPayerViewController;

@protocol AddPayerViewControllerDelegate <NSObject>

- (void)newPaymentMO:(NSManagedObjectID *)objectID;
- (void)updatedPaymentMO:(NSManagedObjectID *)objectID rowIndex:(NSUInteger)rowIndex;

@end

@interface AddPayerViewController : BaseViewController<CNContactPickerDelegate, UITextFieldDelegate>

@property (weak, nonatomic) id <AddPayerViewControllerDelegate> delegate;
@property (weak, nonatomic) TransactionMO *transaction;
@property (weak, nonatomic) PaymentMO *payment;
@property NSUInteger rowIndex;

@end
