//
//  BaseViewController.m
//  ZeroBalance
//
//  Created by Brad Bernard on 12/5/16.
//  Copyright © 2016 Brad Bernard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseViewController.h"
#import "DataController.h"

@interface BaseViewController ()

@property (nonatomic, strong) NSManagedObjectContext* managedObjectContext;

@end

@implementation BaseViewController

-(void) viewDidLoad {
    [super viewDidLoad];
    
    self.managedObjectContext = [[DataController sharedManager] managedObjectContext];
}

- (void)displayAlert:(NSString *)title message:(NSString*)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:okButton];
    [self presentViewController:alertController animated:true completion:nil];
}

@end
