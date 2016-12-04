//
//  TransactionTableCell.h
//  ZeroBalance
//
//  Created by Brad Bernard on 12/3/16.
//  Copyright © 2016 Brad Bernard. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TransactionTableCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *amountLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *peopleLabel;

@end
