//
//  NewTransactionViewController.h
//  ZeroBalance
//
//  Created by Brad Bernard on 12/5/16.
//  Copyright © 2016 Brad Bernard. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "HSDatePickerViewController.h"
#import "DataController.h"
#import "PaymentMO+CoreDataClass.h"
#import "TransactionMO+CoreDataClass.h"
#import "PaymentTableCell.h"
#import "AddPayerViewController.h"

@class NewTransactionViewController;

@protocol NewTransactionViewControllerDelegate <NSObject>

- (void)newTransactionMO:(NSManagedObjectID *)objectID;
- (void)updatedTransactionMO:(NSManagedObjectID *)objectID rowIndex:(NSUInteger)rowIndex;

@end

@interface NewTransactionViewController : BaseViewController<UITableViewDelegate, UITableViewDataSource, HSDatePickerViewControllerDelegate, UITextFieldDelegate, AddPayerViewControllerDelegate>

@property (weak, nonatomic) id <NewTransactionViewControllerDelegate> delegate;
@property (strong, nonatomic) NSMutableArray<PaymentMO *> *rows;
@property (strong, nonatomic) TransactionMO *transaction;
@property (strong, atomic) NSManagedObjectID *transactionId;
@property bool editing;

@end
