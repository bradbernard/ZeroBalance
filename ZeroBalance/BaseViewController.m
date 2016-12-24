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

+ (id)sharedManager {
    static DataController *dataController = nil;
    @synchronized(self) {
        if (dataController == nil)
            dataController = [[self alloc] init];
    }
    return dataController;
}

-(void) viewDidLoad {
    [super viewDidLoad];
    
    self.managedObjectContext = [[DataController sharedManager] managedObjectContext];
}

@end
