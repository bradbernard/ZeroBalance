//
//  DetailViewController.m
//  ZeroBalance
//
//  Created by Brad Bernard on 3/14/17.
//  Copyright © 2017 Brad Bernard. All rights reserved.
//

#import "DetailViewController.h"
#import "BalanceTableCell.h"

@interface DetailViewController ()

@property (nonatomic, strong) NSManagedObjectContext* managedObjectContext;
@property (weak, nonatomic) IBOutlet UITableView *paymentsTable;

@end

@implementation DetailViewController

static NSString *cellIdentifier = @"BalanceTableCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(self.transactionId == nil) {
        return;
    }
    
    self.transaction = (TransactionMO *)[self.managedObjectContext objectWithID:self.transactionId];
    
    NSString *title = self.title;
    title = [title stringByAppendingString:@" ("];
    title = [title stringByAppendingString:[NSNumberFormatter localizedStringFromNumber:[NSNumber numberWithDouble:self.transaction.total] numberStyle:NSNumberFormatterCurrencyStyle]];
    title = [title stringByAppendingString:@")"];
    self.title = title;

    [self createChart];
    [self populateTransactions];
}

- (UIColor *)generateColor {
    CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}

- (void)populateTransactions {
    
    [self.rows removeAllObjects];
    [self.paymentsTable reloadData];
    
    double total = self.transaction.total;
    double avg = total / self.transaction.payments.count;
    
    PaymentMO *payment;
    self.rows = [[NSMutableArray alloc] init];
    
    for (payment in self.transaction.payments) {
        if(payment.paid >= avg) {
            payment.credit = payment.paid - avg;
        } else {
            payment.debt = avg - payment.paid;
        }
        [self.rows addObject:payment];
    }
    
    NSError *error = nil;
    if ([[self managedObjectContext] save:&error] == NO) {
        NSAssert(NO, @"Error saving context: %@\n%@", [error localizedDescription], [error userInfo]);
    }
}

- (void)createChart {
    
    TransactionMO* transaction = [self.managedObjectContext objectWithID:self.transactionId];
    NSMutableArray *items = [[NSMutableArray alloc] init];
    PaymentMO *payment;
    
    for (payment in transaction.payments) {
        if(payment.paid == 0) continue;
        [items addObject:[PNPieChartDataItem dataItemWithValue:payment.paid color:[self generateColor] description:payment.name]];
    }
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    
    PNPieChart *pieChart = [[PNPieChart alloc] initWithFrame:CGRectMake(width/2.75, 175, width/2, height/5) items:items];
    pieChart.descriptionTextColor = [UIColor whiteColor];
    pieChart.descriptionTextFont  = [UIFont fontWithName:@"Avenir-Medium" size:14.0];
    pieChart.showAbsoluteValues = false;
    pieChart.showOnlyValues = true;
    [pieChart strokeChart];
    
    pieChart.legendStyle = PNLegendItemStyleStacked;
    UIView *legend = [pieChart getLegendWithMaxWidth:200];
    [legend setFrame:CGRectMake(15, 175, legend.frame.size.width, legend.frame.size.height)];

    [self.view addSubview:legend];
    [self.view addSubview:pieChart];
}

- (IBAction)sendSMSTapped:(id)sender {
    NSLog(@"SMS tapped");
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BalanceTableCell *cell = (BalanceTableCell*)[tableView dequeueReusableCellWithIdentifier: cellIdentifier];
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.rows count];
}

#pragma mark - UITableViewDelegate

- (void)configureCell:(BalanceTableCell*)cell atIndexPath:(NSIndexPath*)indexPath
{
    PaymentMO *payment = [self.rows objectAtIndex:indexPath.row];
    
    cell.nameLabel.text = payment.name;
    cell.paidLabel.text = [NSNumberFormatter localizedStringFromNumber:[NSNumber numberWithDouble:payment.paid] numberStyle:NSNumberFormatterCurrencyStyle];
    
    double balance = (payment.debt == 0 ? payment.credit : -payment.debt);
    NSString *paid = [NSNumberFormatter localizedStringFromNumber:[NSNumber numberWithDouble:balance] numberStyle:NSNumberFormatterCurrencyStyle];
    cell.balanceLabel.text = paid;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return true;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

@end
