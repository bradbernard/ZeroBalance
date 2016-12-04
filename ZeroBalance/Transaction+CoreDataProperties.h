//
//  Transaction+CoreDataProperties.h
//  
//
//  Created by Brad Bernard on 12/3/16.
//
//  This file was automatically generated and should not be edited.
//

#import "Transaction+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Transaction (CoreDataProperties)

+ (NSFetchRequest<Transaction *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *name;
@property (nonatomic) double total;
@property (nullable, nonatomic, copy) NSDate *date;
@property (nullable, nonatomic, copy) NSString *people;

@end

NS_ASSUME_NONNULL_END
