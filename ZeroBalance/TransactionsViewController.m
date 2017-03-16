//
//  TransactionsViewController.m
//  ZeroBalance
//
//  Created by Brad Bernard on 12/3/16.
//  Copyright © 2016 Brad Bernard. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "TransactionsViewController.h"
#import "TransactionTableCell.h"
#import "DataController.h"
#import "PaymentMO+CoreDataClass.h"
#import "TransactionMO+CoreDataClass.h"
#import "NewTransactionViewController.h"
#import "DetailViewController.h"

@interface TransactionsViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *addButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButtonItem;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSManagedObjectContext* managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@end

@implementation TransactionsViewController

bool deleteAll = true;
static NSString *cellIdentifier = @"TransactionTableCell";
static NSString *storyboardName = @"Main";

UIStoryboard *storyboard = nil;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    
    self.tableView.accessibilityLabel = @"Transactions Table";
    
    self.title = @"Transactions";
    [self initializeFetchedResultsController];
    [self updateDeleteButtonTitle];
}

#pragma mark - IBAction

- (IBAction)editItemPressed:(UIBarButtonItem *)sender {
    [self toggleEditing];
}

- (IBAction)addItemPressed:(UIBarButtonItem *)sender {
    [self deleteOrAddRecord];
}

#pragma mark - Button Events

-(void) toggleEditing {
    if(!self.tableView.editing) {
        [self.tableView setEditing:UITableViewCellEditingStyleDelete animated:YES];
        self.editButtonItem.title = @"Cancel";
        self.tableView.editing = true;
    } else {
        [self.tableView setEditing:UITableViewCellEditingStyleNone animated:YES];
        self.editButtonItem.title = @"Edit";
        self.tableView.editing = false;
    }
    [self updateDeleteButtonTitle];
}

-(void) deleteOrAddRecord {
    if(self.tableView.editing) {
        if(deleteAll) {
            [self deleteAllTransactions];
            [self toggleEditing];
        } else {
            [self deleteSelectedItems];
            [self addButtonDeleteAll];
        }
    } else {
        [self presentAddTransaction];
    }
}

- (void)presentAddTransaction {
    NewTransactionViewController *viewController = (NewTransactionViewController*)[storyboard instantiateViewControllerWithIdentifier:@"NewTransactionViewController"];
    viewController.title = @"New Transaction";
    [self.navigationController pushViewController:viewController animated:true];
}

- (void)pushDetailViewController: (NSIndexPath *)indexPath {
    DetailViewController *viewController = (DetailViewController*)[storyboard instantiateViewControllerWithIdentifier:@"DetailViewController"];
    
    TransactionMO *transaction = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    viewController.title = transaction.name;
}

#pragma mark - Deletion

-(void) addButtonDeleteAll {
    self.addButtonItem.title = @"Delete all";
    deleteAll = true;
}

-(void) addButtonDeleteSelected: (NSUInteger)count {
    self.addButtonItem.title = [NSString stringWithFormat: @"Delete (%lu)", (unsigned long) count];
    deleteAll = false;
}

- (void)updateDeleteButtonTitle
{
    NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
    NSUInteger rowCount = [[[self fetchedResultsController] fetchedObjects] count];
    
    BOOL allItemsAreSelected = selectedRows.count == rowCount;
    BOOL noItemsAreSelected = selectedRows.count == 0;
    
    if(self.tableView.editing) {
        if (allItemsAreSelected || noItemsAreSelected) {
            [self addButtonDeleteAll];
        } else {
            [self addButtonDeleteSelected:selectedRows.count];
        }
    } else {
        self.addButtonItem.title = @"Add";
    }
    
    if(rowCount > 0) {
        self.editButtonItem.enabled = true;
    } else {
        self.editButtonItem.enabled = false;
    }
}

- (void)deleteSelectedItems {
    NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
    NSIndexPath *indexPath = nil;
    
    for (indexPath in selectedRows) {
        TransactionMO *transaction = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        [self.managedObjectContext deleteObject:transaction];
    }
    
    NSError *error = nil;
    if ([[self managedObjectContext] save:&error] == NO) {
        NSAssert(NO, @"Error saving context: %@\n%@", [error localizedDescription], [error userInfo]);
    }
}

- (void)deleteAllTransactions {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Transaction"];
    [fetchRequest setIncludesPropertyValues:NO];
    
    NSError *error;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    for (NSManagedObject *object in fetchedObjects) {
        [self.managedObjectContext deleteObject:object];
    }
    
    error = nil;
    if ([[self managedObjectContext] save:&error] == NO) {
        NSAssert(NO, @"Error saving context: %@\n%@", [error localizedDescription], [error userInfo]);
    }
}

- (void)initializeFetchedResultsController
{
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"Transaction"];
    NSSortDescriptor* sortDate = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
    [request setSortDescriptors:@[sortDate]];
    
    NSManagedObjectContext* moc = self.managedObjectContext;
    [moc setStalenessInterval:0];
    [self setFetchedResultsController:[[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:moc sectionNameKeyPath:@"formattedDate" cacheName:nil]];
    [self.fetchedResultsController setDelegate:self];
    
    NSError *error = nil;
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Failed to initialize FetchedResultsController: %@\n%@", [error localizedDescription], [error userInfo]);
        abort();
    }
}

# pragma mark - MGSwipeTableViewCellDelegate

-(BOOL) swipeTableCell:(MGSwipeTableCell*) cell tappedButtonAtIndex:(NSInteger) index direction:(MGSwipeDirection)direction fromExpansion:(BOOL) fromExpansion {
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    if(index == 0) {
        
        TransactionMO *transaction = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        [self.managedObjectContext deleteObject:transaction];
        
        NSError *error = nil;
        if ([[self managedObjectContext] save:&error] == NO) {
            NSAssert(NO, @"Error saving context: %@\n%@", [error localizedDescription], [error userInfo]);
        }
        
    } else if(index == 1) {
                
        TransactionMO *transaction = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        NewTransactionViewController *viewController = (NewTransactionViewController*)[storyboard instantiateViewControllerWithIdentifier:@"NewTransactionViewController"];
        viewController.transactionId = transaction.objectID;
        viewController.editing = true;
        viewController.title = @"Edit Transaction";
        [self.navigationController pushViewController:viewController animated:true];
        
    }
    
    return true;
}

#pragma mark - UITableView

- (void)configureCell:(TransactionTableCell*)cell atIndexPath:(NSIndexPath*)indexPath
{
    TransactionMO *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    
    cell.nameLabel.text = object.name;
    cell.dateLabel.text = [NSDateFormatter localizedStringFromDate:object.date dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
    cell.amountLabel.text = [NSString stringWithFormat:@"$%.02f", object.total];

    PaymentMO *payment;
    NSMutableArray *peopleCollection = [[NSMutableArray alloc] init];
    for (payment in object.payments) {
        [peopleCollection addObject:payment.firstName];
    }
    
    if(peopleCollection.count > 0) {
        cell.peopleLabel.text = [NSString stringWithFormat:@"%lu: %@", peopleCollection.count, [peopleCollection componentsJoinedByString:@", "]];
    } else {
        cell.peopleLabel.text = @"";
    }
    
    cell.rightButtons = @[[MGSwipeButton buttonWithTitle:@"Delete" backgroundColor:[UIColor redColor]],
                                 [MGSwipeButton buttonWithTitle:@"Edit" backgroundColor:[UIColor orangeColor]]];
    cell.delegate = self;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    TransactionTableCell *cell = (TransactionTableCell*)[tableView dequeueReusableCellWithIdentifier: cellIdentifier];
    [self configureCell:cell atIndexPath:indexPath];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.tableView.editing) {
        return [self updateDeleteButtonTitle];
    }
    
    [self pushDetailViewController: indexPath];
    
    
//    [self.tableView deselectRowAtIndexPath:indexPath animated:true];
//    
//    TransactionMO *transaction = [[self fetchedResultsController] objectAtIndexPath:indexPath];
//    NewTransactionViewController *viewController = (NewTransactionViewController*)[storyboard instantiateViewControllerWithIdentifier:@"NewTransactionViewController"];
//    viewController.transactionId = transaction.objectID;
//    viewController.editing = true;
//    viewController.title = @"Edit Transaction";
//    [self.navigationController pushViewController:viewController animated:true];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.tableView.editing) {
        return [self updateDeleteButtonTitle];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
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
    } else {
        return nil;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete) {
        TransactionMO *transaction = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        [self.managedObjectContext deleteObject:transaction];
        
        NSError *error = nil;
        if ([[self managedObjectContext] save:&error] == NO) {
            NSAssert(NO, @"Error saving context: %@\n%@", [error localizedDescription], [error userInfo]);
        }
    }
}

#pragma mark - NSFetchedResultsController

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
    [self updateDeleteButtonTitle];
}

@end
