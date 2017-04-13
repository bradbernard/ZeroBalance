//
//  DetailViewController.m
//  ZeroBalance
//
//  Created by Brad Bernard on 3/14/17.
//  Copyright © 2017 Brad Bernard. All rights reserved.
//

#import "DetailViewController.h"
#import "TransactionMO+CoreDataClass.h"

@interface DetailViewController ()

@property (weak, nonatomic) IBOutlet UILabel *amountLabel;
@property (nonatomic, strong) NSManagedObjectContext* managedObjectContext;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(self.transactionId != nil) {
        TransactionMO* transaction = [self.managedObjectContext objectWithID:self.transactionId];
        self.amountLabel.text = [NSNumberFormatter localizedStringFromNumber:[NSNumber numberWithDouble:transaction.total] numberStyle:NSNumberFormatterCurrencyStyle];
    }
}

- (IBAction)sendSMSTapped:(id)sender {
    NSLog("SMS tapped");
}

@end
