//
//  ContainerNavigationController.m
//  ZeroBalance
//
//  Created by Brad Bernard on 12/3/16.
//  Copyright © 2016 Brad Bernard. All rights reserved.
//

#import "ContainerNavigationController.h"

@interface ContainerNavigationController ()

@end

@implementation ContainerNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setStatusBarStyle:UIStatusBarStyleContrast];
    [self.navigationBar setTitleTextAttributes: @{NSForegroundColorAttributeName:FlatWhite, NSFontAttributeName:[UIFont fontWithName:@"SFUIDisplay-Bold" size:18]}];
}

@end
