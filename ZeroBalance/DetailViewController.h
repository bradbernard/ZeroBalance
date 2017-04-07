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


@interface DetailViewController : BaseViewController

@property (strong, atomic) NSManagedObjectID *transactionId;

@end
