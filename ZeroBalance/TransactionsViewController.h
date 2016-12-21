//
//  TransactionsViewController.h
//  ZeroBalance
//
//  Created by Brad Bernard on 12/3/16.
//  Copyright © 2016 Brad Bernard. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ChameleonFramework/Chameleon.h>
#import "BaseViewController.h"
#import "NewTransactionViewController.h"

@interface TransactionsViewController : BaseViewController<UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, NewTransactionViewControllerDelegate>


@end
