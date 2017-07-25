//
//  ListingViewController.h
//  ZeroBalance
//
//  Created by Bradley Bernard on 7/25/17.
//  Copyright © 2017 Brad Bernard. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "DataController.h"
#import <CoreData/CoreData.h>

@interface ListingViewController : BaseViewController<UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate>
@end
