//
//  PaymentTableCell.h
//  ZeroBalance
//
//  Created by Brad Bernard on 12/17/16.
//  Copyright © 2016 Brad Bernard. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PaymentTableCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameText;
@property (weak, nonatomic) IBOutlet UILabel *phoneText;
@property (weak, nonatomic) IBOutlet UILabel *moneyText;

@end
