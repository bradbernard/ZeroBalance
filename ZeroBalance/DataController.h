//
//  DataController.h
//  ZeroBalance
//
//  Created by Brad Bernard on 12/3/16.
//  Copyright © 2016 Brad Bernard. All rights reserved.
//

//#ifndef DataController_h
//#define DataController_h

#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>

@interface DataController : NSObject

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;


- (void)initializeCoreData;
+ (id)sharedManager;

@end

//#endif /* DataController_h */
