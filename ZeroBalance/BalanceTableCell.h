//
//  BalanceTableCell.h
//  ZeroBalance
//
//  Created by Bradley Bernard on 7/25/17.
//  Copyright © 2017 Brad Bernard. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BalanceTableCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *balanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *paidLabel;

@end
