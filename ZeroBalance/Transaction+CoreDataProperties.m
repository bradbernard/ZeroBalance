//
//  Transaction+CoreDataProperties.m
//  
//
//  Created by Brad Bernard on 12/3/16.
//
//  This file was automatically generated and should not be edited.
//

#import "Transaction+CoreDataProperties.h"

@implementation Transaction (CoreDataProperties)

+ (NSFetchRequest<Transaction *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Transaction"];
}

@dynamic name;
@dynamic total;
@dynamic date;
@dynamic people;

@end
