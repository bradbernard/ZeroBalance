//
//  DetailViewController.h
//  ZeroBalance
//
//  Created by Brad Bernard on 3/14/17.
//  Copyright © 2017 Brad Bernard. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "BaseViewController.h"
#import "TransactionMO+CoreDataClass.h"
#import "PaymentMO+CoreDataClass.h"
#import "PNChart.h"

@interface DetailViewController : BaseViewController<UITableViewDelegate, UITableViewDataSource>

@property (strong, atomic) NSManagedObjectID *transactionId;
@property (strong, nonatomic) TransactionMO *transaction;
@property (strong, nonatomic) NSMutableArray<PaymentMO *> *rows;


@end
