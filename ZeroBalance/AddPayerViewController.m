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
    
    NSLog(@"%@", self.transaction);
}

# pragma mark - IBAction

- (IBAction)contactsPressed:(id)sender {
    [self presentViewController:contactPicker animated:YES completion:nil];
}

- (IBAction)savePressed:(id)sender {
    NSLog(@"What");
    PaymentMO *payment = [NSEntityDescription insertNewObjectForEntityForName:@"Payment" inManagedObjectContext:self.managedObjectContext];
    payment.paid = [self.paidText.text doubleValue];
    payment.name = self.nameText.text;
    payment.phoneNumber = self.phoneText.text;
    
    [self.delegate newPaymentMO:payment];
    [self.navigationController popViewControllerAnimated:true];
}

# pragma mark - CNContactPickerDelegate

- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContact:(CNContact *)contact {
    
    unsigned int firstLength = [contact.givenName length];
    unsigned int lastLength = [contact.familyName length];
    
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
