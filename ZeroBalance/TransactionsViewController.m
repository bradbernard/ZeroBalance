//
//  TransactionsViewController.m
//  ZeroBalance
//
//  Created by Brad Bernard on 12/3/16.
//  Copyright © 2016 Brad Bernard. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "TransactionsViewController.h"
#import "TransactionMO+CoreDataClass.h"
#import "TransactionTableCell.h"
#import "DataController.h"

@interface TransactionsViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSManagedObjectContext* managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end

@implementation TransactionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Transactions";
    self.managedObjectContext = [[[DataController alloc] init] managedObjectContext];
    [self initializeFetchedResultsController];
    [self test];
}

- (void)viewDidUnload {
    self.fetchedResultsController = nil;
}

- (void)initializeFetchedResultsController
{
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"Transaction"];
    NSSortDescriptor* sort = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
    [request setSortDescriptors:@[sort]];
    
    NSManagedObjectContext* moc = self.managedObjectContext;
    [self setFetchedResultsController:[[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:moc sectionNameKeyPath:nil cacheName:nil]];
    [[self fetchedResultsController] setDelegate:self];
    
    NSError *error = nil;
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Failed to initialize FetchedResultsController: %@\n%@", [error localizedDescription], [error userInfo]);
        abort();
    } else {
        NSLog(@"WOrked");
    }
}

- (void)deleteAll {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Transaction"];
    [fetchRequest setIncludesPropertyValues:NO];
    
    NSError *error;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    for (NSManagedObject *object in fetchedObjects) {
        [self.managedObjectContext deleteObject:object];
    }
    
    error = nil;
    [self.managedObjectContext save:&error];
}

- (void)test {
    TransactionMO *transaction = [NSEntityDescription insertNewObjectForEntityForName:@"Transaction" inManagedObjectContext: self.managedObjectContext];
    transaction.name = @"Woodstocks Pizza";
    transaction.total = 25.44;
    transaction.date = [NSDate date];
    transaction.people = @"Travis, Steve, Bennett";
    NSError *error = nil;
    [[self managedObjectContext] save:&error];
}

//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    return 5;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *simpleTableIdentifier = @"TransactionTableCell";
//    
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
//
////    cell.textLabel.text = [recipes objectAtIndex:indexPath.row];
//    return cell;
//}

- (void)configureCell:(TransactionTableCell*)cell atIndexPath:(NSIndexPath*)indexPath
{
    TransactionMO *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    cell.nameLabel.text = object.name;
    cell.dateLabel.text = [NSDateFormatter localizedStringFromDate:object.date dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
    cell.amountLabel.text = [NSString stringWithFormat:@"$%f", object.total];
    cell.peopleLabel.text = object.people;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"TransactionTableCell";
    
    TransactionTableCell *cell = (TransactionTableCell*)[tableView dequeueReusableCellWithIdentifier: cellIdentifier];
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row % 2 == 1) {
        [self deleteAll];
    } else {
        [self test];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSLog(@"%lu", [[[self fetchedResultsController] sections] count]);
    return [[[self fetchedResultsController] sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id<NSFetchedResultsSectionInfo> sectionInfo = [[self fetchedResultsController] sections][section];
    return [sectionInfo numberOfObjects];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if ([[self.fetchedResultsController sections] count] > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
        return [sectionInfo name];
    } else
        return @"Woww";
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [self.fetchedResultsController sectionIndexTitles];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [self.fetchedResultsController sectionForSectionIndexTitle:title atIndex:index];
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [[self tableView] beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [[self tableView] insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [[self tableView] deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeMove:
        case NSFetchedResultsChangeUpdate:
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [[self tableView] insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [[self tableView] deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[[self tableView] cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
        case NSFetchedResultsChangeMove:
            [[self tableView] deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [[self tableView] insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [[self tableView] endUpdates];
}

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    return [[<#Fetched results controller#> sections] count];
//}
//
//- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
//    if ([[<#Fetched results controller#> sections] count] > 0) {
//        id <NSFetchedResultsSectionInfo> sectionInfo = [[<#Fetched results controller#> sections] objectAtIndex:section];
//        return [sectionInfo numberOfObjects];
//    } else
//        return 0;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//    UITableViewCell *cell = <#Get the cell#>;
//    NSManagedObject *managedObject = [<#Fetched results controller#> objectAtIndexPath:indexPath];
//        // Configure the cell with data from the managed object.
//    return cell;
//    
//}
//
//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    if ([[<#Fetched results controller#> sections] count] > 0) {
//        id <NSFetchedResultsSectionInfo> sectionInfo = [[<#Fetched results controller#> sections] objectAtIndex:section];
//        return [sectionInfo name];
//    } else
//        return nil;
//}
//
//- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
//    return [<#Fetched results controller#> sectionIndexTitles];
//}
//
//- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
//    return [<#Fetched results controller#> sectionForSectionIndexTitle:title atIndex:index];
//}

@end
