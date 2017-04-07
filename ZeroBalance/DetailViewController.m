//
//  DetailViewController.m
//  ZeroBalance
//
//  Created by Brad Bernard on 3/14/17.
//  Copyright © 2017 Brad Bernard. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()

@property (weak, nonatomic) IBOutlet UILabel *amountLabel;
@property (nonatomic, strong) NSManagedObjectContext* managedObjectContext;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    NSLog(@"%@", _managedObjectContext);
}

@end
