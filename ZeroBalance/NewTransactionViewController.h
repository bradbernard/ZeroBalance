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

@interface NewTransactionViewController : BaseViewController<UICollectionViewDelegate, UICollectionViewDataSource, HSDatePickerViewControllerDelegate, UITextFieldDelegate>

@end
