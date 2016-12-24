//
//  AddPayerViewController.m
//  ZeroBalance
//
//  Created by Brad Bernard on 12/17/16.
//  Copyright © 2016 Brad Bernard. All rights reserved.
//

#import "AddPayerViewController.h"
#import "DataController.h"
#import "PaymentMO+CoreDataClass.h"
#import "TransactionMO+CoreDataClass.h"

@interface AddPayerViewController ()

@property (weak, nonatomic) IBOutlet UITextField *nameText;
@property (weak, nonatomic) IBOutlet UITextField *phoneText;
@property (weak, nonatomic) IBOutlet UITextField *paidText;
@property (nonatomic, strong) NSManagedObjectContext* managedObjectContext;

@end

@implementation AddPayerViewController

CNContactPickerViewController *contactPicker = nil;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    contactPicker = [[CNContactPickerViewController alloc] init];
    contactPicker.delegate = self;
    
    if(self.payment != nil) {
        self.nameText.text = self.payment.name;
        self.phoneText.text = self.payment.phoneNumber;
        self.paidText.text = [NSString stringWithFormat:@"$%.2lf", self.payment.paid];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [self.paidText becomeFirstResponder];
}

# pragma mark - IBAction

- (IBAction)contactsPressed:(id)sender {
    [self presentViewController:contactPicker animated:YES completion:nil];
}

- (IBAction)savePressed:(id)sender {
    
    if(![self paymentFilledOut]) {
        return;
    }
    
    PaymentMO *payment = nil;
    
    if(self.payment == nil) {
        payment = [NSEntityDescription insertNewObjectForEntityForName:@"Payment" inManagedObjectContext:self.managedObjectContext];
    } else {
        payment = self.payment;
    }
    
    payment.paid = [[[self.paidText.text substringFromIndex:1] stringByReplacingOccurrencesOfString:@"," withString:@""] doubleValue];
    payment.name = self.nameText.text;
    payment.firstName = [self.nameText.text componentsSeparatedByString:@" "][0];
    payment.phoneNumber = self.phoneText.text;
    
    NSError *error = nil;
    if ([[self managedObjectContext] save:&error] == NO) {
        NSAssert(NO, @"Error saving context: %@\n%@", [error localizedDescription], [error userInfo]);
    }
    
    if(self.payment == nil) {
        [self.delegate newPaymentMO:payment.objectID];
    } else {
        [self.delegate updatedPaymentMO:payment.objectID rowIndex:self.rowIndex];
    }
    
    [self.navigationController popViewControllerAnimated:true];
}

# pragma mark - Void Methods

- (bool)paymentFilledOut {
    return (self.nameText.text.length  > 0  &&
            self.phoneText.text.length > 0  &&
            self.paidText.text.length  > 0);
}

# pragma mark - CNContactPickerDelegate

- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContact:(CNContact *)contact {
    
    unsigned long firstLength = [contact.givenName length];
    unsigned long lastLength = [contact.familyName length];
    
    if(firstLength > 0 && lastLength > 0) {
        self.nameText.text = [NSString stringWithFormat:@"%@%@%@", contact.givenName, @" ", contact.familyName];
    } else if(firstLength > 0 && lastLength == 0) {
        self.nameText.text = contact.givenName;
    } else if(firstLength == 0 && lastLength > 0) {
        self.nameText.text = contact.familyName;
    }
    
    if([contact.phoneNumbers count] > 0) {
        self.phoneText.text = [[[contact.phoneNumbers objectAtIndex:0] value] stringValue];
    }
    
    [self.paidText becomeFirstResponder];
}

# pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == self.paidText && textField.text.length  == 0) {
        textField.text = @"$0.00";
    }
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if(textField != self.paidText) {
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

@end
