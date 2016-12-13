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
@property (weak, nonatomic) IBOutlet UITextField *dateText;

@end

@implementation NewTransactionViewController

static NSString *cellIdentifier = @"PaymentCollectionCell";
static NSString *currencySymbol = @"$";
static unsigned int cellHeight = 70;

NSDate *date = nil;
HSDatePickerViewController *picker = nil;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Add Transaction";
    
    date = [NSDate date];
    picker = [[HSDatePickerViewController alloc] init];
    picker.delegate = self;
    
    [self navigationItems];
    [self displayDate];
}

#pragma mark - IBActions

- (IBAction)closeModal:(id)sender {
    NSLog(@"Wow");
    [self dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)saveTransaction:(id)sender {
    NSLog(@"Saved");
}


- (IBAction)datePressed:(id)sender {
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField.text.length  == 0) {
        textField.text = currencySymbol;
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (![newText hasPrefix:currencySymbol]) {
        return false;
    }
    
    return true;
}

#pragma Mark - Void Methods

- (void)navigationItems {
    UIBarButtonItem *close = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(closeModal:)];
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveTransaction:)];
    
    self.navigationItem.leftBarButtonItem = close;
    self.navigationItem.rightBarButtonItem = done;
}

- (void)displayDate {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MMMM dd, yyyy h:mm a";
    NSString *string = [formatter stringFromDate:date];
    
    self.dateText.text = string;
}

- (void)hsDatePickerPickedDate:(NSDate *)selectedDate {
    date = selectedDate;
    [self displayDate];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 2;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(collectionView.bounds.size.width, cellHeight);
}


@end
