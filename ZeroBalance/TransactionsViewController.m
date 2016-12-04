//
//  TransactionsViewController.m
//  ZeroBalance
//
//  Created by Brad Bernard on 12/3/16.
//  Copyright © 2016 Brad Bernard. All rights reserved.
//

#import "TransactionsViewController.h"

@interface TransactionsViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation TransactionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setStatusBarStyle:UIStatusBarStyleContrast];
    self.title = @"Transactions";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"TransactionTableCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];

//    cell.textLabel.text = [recipes objectAtIndex:indexPath.row];
    return cell;
}

@end
