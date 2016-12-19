//
//  AddPayeeViewController.h
//  ZeroBalance
//
//  Created by Brad Bernard on 12/17/16.
//  Copyright © 2016 Brad Bernard. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "TransactionMO+CoreDataClass.h"
#import <ContactsUI/ContactsUI.h>
#import <Contacts/Contacts.h>

@interface AddPayeeViewController : BaseViewController<CNContactPickerDelegate, UITextFieldDelegate>

@property (weak, nonatomic) TransactionMO *transaction;

@end
