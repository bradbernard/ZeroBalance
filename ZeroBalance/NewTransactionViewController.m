//
//  NewTransactionViewController.m
//  ZeroBalance
//
//  Created by Brad Bernard on 12/5/16.
//  Copyright © 2016 Brad Bernard. All rights reserved.
//

#import "NewTransactionViewController.h"
#import "DataController.h"
#import "PaymentMO+CoreDataClass.h"
#import "TransactionMO+CoreDataClass.h"
#import "PersonMO+CoreDataClass.h"

@interface NewTransactionViewController ()

@property (weak, nonatomic) IBOutlet UITextField *nameText;
@property (weak, nonatomic) IBOutlet UITextField *moneyText;

@end

@implementation NewTransactionViewController

static NSString *cellIdentifier = @"PaymentCollectionCell";
static unsigned int cellHeight = 70;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Add Transaction";
    
    UIBarButtonItem *close = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(closeModal:)];
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveTransaction:)];
    
    self.navigationItem.leftBarButtonItem = close;
    self.navigationItem.rightBarButtonItem = done;
}

- (IBAction)closeModal:(id)sender {
    NSLog(@"Wow");
    [self dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)saveTransaction:(id)sender {
    NSLog(@"Saved");
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 2;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(collectionView.bounds.size.width, cellHeight);
}


@end
