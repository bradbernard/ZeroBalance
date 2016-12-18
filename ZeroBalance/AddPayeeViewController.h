//
//  AddPayeeViewController.h
//  ZeroBalance
//
//  Created by Brad Bernard on 12/17/16.
//  Copyright © 2016 Brad Bernard. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "TransactionMO+CoreDataClass.h"

@interface AddPayeeViewController : BaseViewController

@property (weak, nonatomic) TransactionMO *transaction;

@end
