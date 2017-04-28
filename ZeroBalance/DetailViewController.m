//
//  DetailViewController.m
//  ZeroBalance
//
//  Created by Brad Bernard on 3/14/17.
//  Copyright © 2017 Brad Bernard. All rights reserved.
//

#import "DetailViewController.h"
#import "TransactionMO+CoreDataClass.h"
#import "PaymentMO+CoreDataClass.h"
#import "PNChart.h"

@interface DetailViewController ()

@property (weak, nonatomic) IBOutlet UILabel *amountLabel;
@property (nonatomic, strong) NSManagedObjectContext* managedObjectContext;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(self.transactionId == nil) {
        return;
    }
    
//        self.amountLabel.text = [NSNumberFormatter localizedStringFromNumber:[NSNumber numberWithDouble:transaction.total] numberStyle:NSNumberFormatterCurrencyStyle];
    [self createChart];
}

- (UIColor *)generateColor {
    CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}

- (void)createChart {
    
    TransactionMO* transaction = [self.managedObjectContext objectWithID:self.transactionId];
    NSMutableArray *items = [[NSMutableArray alloc] init];
    PaymentMO *payment;
    
    for (payment in transaction.payments) {
        if(payment.paid == 0) continue;
        [items addObject:[PNPieChartDataItem dataItemWithValue:payment.paid color:[self generateColor] description:payment.name]];
    }
    
    PNPieChart *pieChart = [[PNPieChart alloc] initWithFrame:CGRectMake(40.0, 155.0, 240.0, 240.0) items:items];
    pieChart.descriptionTextColor = [UIColor whiteColor];
    pieChart.descriptionTextFont  = [UIFont fontWithName:@"Avenir-Medium" size:14.0];
    pieChart.showAbsoluteValues = false;
    pieChart.showOnlyValues = true;
    [pieChart strokeChart];
    
    pieChart.legendStyle = PNLegendItemStyleStacked;
    UIView *legend = [pieChart getLegendWithMaxWidth:200];
    [legend setFrame:CGRectMake(330, 350, legend.frame.size.width, legend.frame.size.height)];

    [self.view addSubview:legend];
    [self.view addSubview:pieChart];
}


- (IBAction)sendSMSTapped:(id)sender {
    NSLog(@"SMS tapped");
}

@end
