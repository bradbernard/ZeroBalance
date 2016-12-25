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
#import "AddPayerViewController.h"

@interface NewTransactionViewController ()

@property (weak, nonatomic) IBOutlet UITextField *nameText;
@property (weak, nonatomic) IBOutlet UITextField *moneyText;
@property (weak, nonatomic) IBOutlet UITextField *dateText;
@property (weak, nonatomic) IBOutlet UILabel *peopleLabel;
@property (weak, nonatomic) IBOutlet UILabel *perPersonLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *payeeButton;
@property (strong, nonatomic) NSManagedObjectContext* managedObjectContext;

@end

@implementation NewTransactionViewController

static NSString *storyboardName = @"Main";
static NSString *cellIdentifier = @"PaymentTableCell";

static NSString *peopleText = @"People: ";
static NSString *perPersonText = @"Average: ";

NSDate *date = nil;
HSDatePickerViewController *picker = nil;

UIStoryboard *storyboardInstance = nil;
UIColor *moneyColor = nil;
UIColor *redColor = nil;
UIBarButtonItem *closeButton = nil;
UIBarButtonItem *doneButton = nil;

double moneyAmount = 0;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    picker = [[HSDatePickerViewController alloc] init];
    picker.backButtonTitle = @"Cancel";
    picker.confirmButtonTitle = @"Select";
    picker.delegate = self;
    
    date = [NSDate date];
    storyboardInstance = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    moneyColor = [UIColor colorWithRed:33.0/255.0 green:108.0/255.0 blue:42.0/255.0 alpha:1.0];
    redColor = [UIColor redColor];
    
    if(self.transactionId != nil) {
        self.transaction = [self.managedObjectContext objectWithID:self.transactionId];
        self.nameText.text = self.transaction.name;
        self.moneyText.text = [NSNumberFormatter localizedStringFromNumber:[NSNumber numberWithDouble:self.transaction.total] numberStyle:NSNumberFormatterCurrencyStyle];
        date = self.transaction.date;
        picker.date = date;
        self.rows = [NSMutableArray arrayWithArray:[self.transaction.payments allObjects]];
        moneyAmount = self.transaction.total;
    } else {
        self.rows = [[NSMutableArray alloc] init];
    }
    
    self.tableView.accessibilityLabel = @"Payers Table";
    
    [self navigationItems];
    [self displayDate];
    [self updateDisplayTotals];
}

-(void)viewDidAppear:(BOOL)animated {
    if(self.rows.count == 0) {
        [self.nameText becomeFirstResponder];
    }
}

#pragma mark - IBActions

- (IBAction)addPayeePressed:(id)sender {
    [self.view endEditing:true];
    AddPayerViewController *viewController = (AddPayerViewController*)[storyboardInstance instantiateViewControllerWithIdentifier:@"AddPayerViewController"];
    viewController.transaction = self.transaction;
    viewController.delegate = self;
    viewController.title = @"New Payer";
    [self.navigationController pushViewController:viewController animated:true];
}

- (IBAction)closeModal:(id)sender {
    [self deleteTemporaryObjects];
    [self.navigationController popViewControllerAnimated:true];
}

- (IBAction)saveTransaction:(id)sender {
    [self insertTransaction];
}

- (IBAction)datePressed:(id)sender {
    [self presentViewController:picker animated:YES completion:nil];
}

# pragma mark - AddPayerViewControllerDelegate

- (void)newPaymentMO:(NSManagedObjectID *)objectID {
    PaymentMO* payment = [self.managedObjectContext objectWithID:objectID];
    [self.rows addObject:payment];
    [self.tableView reloadData];
    [self updateDisplayTotals];
}

-(void)updatedPaymentMO:(NSManagedObjectID *)objectID rowIndex:(NSUInteger)rowIndex {
    [self.tableView reloadData];
    [self updateDisplayTotals];
}

# pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == self.moneyText && textField.text.length == 0) {
        textField.text = @"$0.00";
    }
}

-(BOOL)textFieldShouldClear:(UITextField *)textField {
    if(textField == self.moneyText) {
        self.moneyText.text = @"$0.00";
        return false;
    }
    
    return true;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
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
    NSNumber *formattedValue = [[NSNumber alloc] initWithDouble:[myNumber doubleValue]/ 100.0];
    
    NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc] init];
    [currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    textField.text = [currencyFormatter stringFromNumber:formattedValue];
    moneyAmount = [[currencyFormatter numberFromString:textField.text] doubleValue];
    
    [self updateDisplayTotals];
    [self.tableView reloadData];
    
    return false;
}

#pragma Mark - Void Methods

- (void)navigationItems {
    closeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(closeModal:)];
    doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveTransaction:)];
    
    self.navigationItem.leftBarButtonItem = closeButton;
    self.navigationItem.rightBarButtonItem = doneButton;
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void)toggleHidden:(BOOL)toggle {
    self.peopleLabel.hidden = toggle;
    self.perPersonLabel.hidden = toggle;
    self.tableView.hidden = toggle;
}

- (void)insertTransaction {
    if(![self transactionFilledOut]) {
        return [self displayAlert:@"Error" message:@"Name, total, and date are required to save the transaction."];
    }
    
    if(!self.editing) {
        self.transaction = [NSEntityDescription insertNewObjectForEntityForName:@"Transaction" inManagedObjectContext: self.managedObjectContext];
    }
    
    self.transaction.name = self.nameText.text;
    self.transaction.total = [[[self.moneyText.text substringFromIndex:1] stringByReplacingOccurrencesOfString:@"," withString:@""] doubleValue];
    self.transaction.date = date;
    self.transaction.formattedDate = [NSDateFormatter localizedStringFromDate:self.transaction.date dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle];

    for(unsigned int i = 0; i < [self.rows count]; ++i) {
        [self.rows objectAtIndex:i].transaction = self.transaction;
    }
    
    NSMutableSet *payments = [[NSMutableSet alloc] initWithArray:self.rows];
    self.transaction.payments = payments;
    
    NSError *error = nil;
    if ([[self managedObjectContext] save:&error] == NO) {
        NSAssert(NO, @"Error saving context: %@\n%@", [error localizedDescription], [error userInfo]);
    }
    
    [self.delegate newTransactionMO:self.transaction.objectID];
    
    [self.navigationController popViewControllerAnimated:true];
}

- (double)perPersonTotal {
    return moneyAmount/[self.rows count];
}

- (void)updateDisplayTotals {
    if([self.rows count] > 0) {
        double perPerson = [self perPersonTotal];
        
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [formatter setMaximumFractionDigits:2];
        [formatter setMinimumFractionDigits:2];
        [formatter setRoundingMode: NSNumberFormatterRoundUp];
        
        self.perPersonLabel.text = [perPersonText stringByAppendingString:[formatter stringFromNumber:[NSNumber numberWithDouble:perPerson]]];
        [self toggleHidden:false];
    } else {
        self.perPersonLabel.text = perPersonText;
        [self toggleHidden:true];
    }
    
    self.peopleLabel.text = [peopleText stringByAppendingString:[NSString stringWithFormat:@"%lu", (unsigned long)[self.rows count]]];
}

- (bool)transactionFilledOut {
    return  (self.moneyText.text.length > 0) &&
            (self.nameText.text.length  > 0) &&
            (self.dateText.text.length  > 0) &&
            (date != nil);
}

- (void)deleteTemporaryObjects {
    
    if(self.editing) {
        return ([self.managedObjectContext hasChanges] ? [self.managedObjectContext rollback] : nil);
    }
    
    for(unsigned int i = 0; i < [self.rows count]; ++i) {
        [self.managedObjectContext deleteObject:[self.rows objectAtIndex:i]];
    }
    
    if(self.transaction != nil) {
        [self.managedObjectContext deleteObject:self.transaction];
    }
    
    NSError *error = nil;
    if ([[self managedObjectContext] save:&error] == NO) {
        NSAssert(NO, @"Error saving context: %@\n%@", [error localizedDescription], [error userInfo]);
    }
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
    return [self.rows count];
}

#pragma mark - UITableViewDelegate

- (void)configureCell:(PaymentTableCell*)cell atIndexPath:(NSIndexPath*)indexPath
{
    PaymentMO *payment = [self.rows objectAtIndex:indexPath.row];
    
    cell.nameText.text = payment.name;
    cell.phoneText.text = payment.phoneNumber;
    cell.phoneText.hidden = ([payment.phoneNumber length] == 0);
    NSString *paid = [NSNumberFormatter localizedStringFromNumber:[NSNumber numberWithDouble:payment.paid] numberStyle:NSNumberFormatterCurrencyStyle];

    bool equalOrAboveAvg = payment.paid >= [self perPersonTotal];
    NSMutableAttributedString *money = [[NSMutableAttributedString alloc] initWithString:paid];
    [money addAttribute:NSForegroundColorAttributeName value:(equalOrAboveAvg ? moneyColor : redColor) range:NSMakeRange(0, [paid length])];
    [cell.moneyText setAttributedText:money];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:true];
    PaymentMO *payment = [self.rows objectAtIndex:indexPath.row];

    AddPayerViewController *viewController = (AddPayerViewController*)[storyboardInstance instantiateViewControllerWithIdentifier:@"AddPayerViewController"];
    viewController.transaction = self.transaction;
    viewController.delegate = self;
    viewController.payment = payment;
    viewController.rowIndex = indexPath.row;
    viewController.title = @"Edit Payer";
    
    [self.navigationController pushViewController:viewController animated:true];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return true;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete) {
        [self.managedObjectContext deleteObject:[self.rows objectAtIndex:indexPath.row]];
        [self.rows removeObjectAtIndex:indexPath.row];
        [self.tableView reloadData];
        [self updateDisplayTotals];
    }
}

@end
