//
//  DetailViewController.h
//  ZeroBalance
//
//  Created by Brad Bernard on 3/14/17.
//  Copyright © 2017 Brad Bernard. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, atomic) NSManagedObjectID *transactionId;

@end
