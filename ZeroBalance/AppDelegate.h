//
//  AppDelegate.h
//  ZeroBalance
//
//  Created by Brad Bernard on 12/3/16.
//  Copyright © 2016 Brad Bernard. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <ChameleonFramework/Chameleon.h>
#import "DataController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) DataController *dataController;

//@property (readonly, strong) NSPersistentContainer *persistentContainer;

//- (void)saveContext;


@end

