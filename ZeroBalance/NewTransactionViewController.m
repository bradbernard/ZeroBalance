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
#import "PaymentTableCell.h"
#import "AddPayeeViewController.h"

@interface NewTransactionViewController ()

@property (weak, nonatomic) IBOutlet UITextField *nameText;
@property (weak, nonatomic) IBOutlet UITextField *moneyText;
@property (weak, nonatomic) IBOutlet UITextField *dateText;
@property (weak, nonatomic) IBOutlet UILabel *peopleLabel;
@property (weak, nonatomic) IBOutlet UILabel *perPersonLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *payeeButton;

@end

@implementation NewTransactionViewController

static NSString *storyboardName = @"Main";
static NSString *cellIdentifier = @"PaymentTableCell";

static NSString *peopleText = @"People: ";
static NSString *perPersonText = @"Per person: ";

unsigned int rowTotal = 0;
unsigned int rowSaved = 0;

NSDate *date = nil;
HSDatePickerViewController *picker = nil;
NSMutableArray<PaymentMO *> *rows = nil;
//NSMutableArray<PersonMO *> *people = nil;
TransactionMO *transaction = nil;
UIStoryboard *storyboard = nil;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Add Transaction";
    
    date = [NSDate date];
    picker = [[HSDatePickerViewController alloc] init];
    picker.delegate = self;
    
    rows = [[NSMutableArray alloc] init];
    storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    
    // [self toggleHidden:true];
    
    [self navigationItems];
    [self displayDate];
}

#pragma mark - IBActions

- (IBAction)addPayeePressed:(id)sender {
    AddPayeeViewController *viewController = (AddPayeeViewController*)[storyboard instantiateViewControllerWithIdentifier:@"AddPayeeViewController"];
    viewController.transaction = transaction;
    [self.navigationController pushViewController:viewController animated:true];
}

- (IBAction)closeModal:(id)sender {
    [self.navigationController popViewControllerAnimated:true];
}

- (IBAction)saveTransaction:(id)sender {
    NSLog(@"Saved");
}

- (IBAction)textChanged:(id)sender {
    self.payeeButton.enabled = [self transactionFilledOut];
}

- (IBAction)datePressed:(id)sender {
    [self presentViewController:picker animated:YES completion:nil];
}

# pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    self.payeeButton.enabled = [self transactionFilledOut];
    
    if (textField == self.moneyText && textField.text.length  == 0) {
        textField.text = @"$0.00";
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.payeeButton.enabled = [self transactionFilledOut];
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if(textField != self.moneyText) {
        return true;
    }
    
    NSString *cleanCentString = [[textField.text componentsSeparatedByCharactersInSet: [[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
    NSInteger centValue = [cleanCentString intValue];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    NSNumber *myNumber = [formatter numberFromString:cleanCentString];
    NSNumber *result;
    
    if (string.length > 0) {
        centValue = centValue * 10 + [string intValue];
        double intermediate = [myNumber doubleValue] * 10 +  [[formatter numberFromString:string] doubleValue];
        result = [[NSNumber alloc] initWithDouble:intermediate];
    } else {
        centValue = centValue / 10;
        double intermediate = [myNumber doubleValue]/10;
        result = [[NSNumber alloc] initWithDouble:intermediate];
    }
        
    myNumber = result;
    NSNumber *formattedValue = [[NSNumber alloc] initWithDouble:[myNumber doubleValue]/ 100.0f];
    
    NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc] init];
    [currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    textField.text = [currencyFormatter stringFromNumber:formattedValue];
    
    return false;
}

#pragma Mark - Void Methods

- (void)navigationItems {
    UIBarButtonItem *close = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(closeModal:)];
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveTransaction:)];
    
    self.navigationItem.leftBarButtonItem = close;
    self.navigationItem.rightBarButtonItem = done;
}

- (void)toggleHidden:(BOOL)toggle {
    self.peopleLabel.hidden = toggle;
    self.perPersonLabel.hidden = toggle;
    self.tableView.hidden = toggle;
}

- (BOOL)transactionFilledOut {
    return (self.moneyText.text.length > 0) &&
            (self.nameText.text.length > 0) &&
            (self.dateText.text.length > 0) &&
            (date != nil);
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


#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PaymentTableCell *cell = (PaymentTableCell*)[tableView dequeueReusableCellWithIdentifier: cellIdentifier];
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [rows count];
}

#pragma mark - UITableViewDelegate

- (void)configureCell:(PaymentTableCell*)cell atIndexPath:(NSIndexPath*)indexPath
{
    PaymentMO *object = [rows objectAtIndex:indexPath.row];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete) {
        [rows removeObjectAtIndex:indexPath.row];
    }
}

@end
