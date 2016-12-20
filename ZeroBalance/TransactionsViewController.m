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

@interface TransactionsViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *addButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButtonItem;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSManagedObjectContext* managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end

@implementation TransactionsViewController

bool deleteAll = true;
static NSString *cellIdentifier = @"TransactionTableCell";
static NSString *storyboardName = @"Main";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Transactions";
    [self initializeFetchedResultsController];
    [self updateDeleteButtonTitle];
}

- (void)viewDidUnload {
    self.fetchedResultsController = nil;
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
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    NewTransactionViewController *viewController = (NewTransactionViewController*)[storyboard instantiateViewControllerWithIdentifier:@"NewTransactionViewController"];
    [self.navigationController pushViewController:viewController animated:true];
    
}

- (void)test {
    
//    NewTransactionViewController *viewController = [[NewTransactionViewController alloc] initWithNibName:@"NewTransactionViewController" bundle:nil];
    
        //UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
        //NewTransactionViewController *viewController = (NewTransactionViewController*)[storyboard instantiateViewControllerWithIdentifier:@"NewTransactionViewController"];
        //[self.navigationController pushViewController:viewController animated:true];


//    PersonMO *person = [NSEntityDescription insertNewObjectForEntityForName:@"Person" inManagedObjectContext:self.managedObjectContext];
//    person.firstName = @"Billy";
//    person.lastName = @"Bob";
//    person.name = @"Billy Bob";
//    person.phoneNumber = @"5556667777";
//    
//    PaymentMO *payment1 = [NSEntityDescription insertNewObjectForEntityForName:@"Payment" inManagedObjectContext:self.managedObjectContext];
//    payment1.paid = 10.00;
//    payment1.person = person;
//    
//    NSMutableSet *personPayments = [[NSMutableSet alloc] init];
//    [personPayments addObject:payment1];
//    person.payments = personPayments;
//    
//    TransactionMO *transaction = [NSEntityDescription insertNewObjectForEntityForName:@"Transaction" inManagedObjectContext: self.managedObjectContext];
//    transaction.name = @"Woodstocks Pizza";
//    transaction.total = 25.44;
//    transaction.date = [NSDate date];
//    transaction.formattedDate = [NSDateFormatter localizedStringFromDate:transaction.date dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle];
//    
//    NSMutableSet *payments = [[NSMutableSet alloc] init];
//    [payments addObject:payment1];
//    transaction.payments = payments;
//    payment1.transaction = transaction;
//
//    NSError *error = nil;
//    if ([[self managedObjectContext] save:&error] == NO) {
//        NSAssert(NO, @"Error saving context: %@\n%@", [error localizedDescription], [error userInfo]);
//    }
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
    [self setFetchedResultsController:[[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:moc sectionNameKeyPath:@"formattedDate" cacheName:@"RootTransVC"]];
    [[self fetchedResultsController] setDelegate:self];
    
    NSError *error = nil;
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Failed to initialize FetchedResultsController: %@\n%@", [error localizedDescription], [error userInfo]);
        abort();
    }
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
        [peopleCollection addObject:payment.name];
    }
    
    cell.peopleLabel.text = [peopleCollection componentsJoinedByString:@","];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    TransactionTableCell *cell = (TransactionTableCell*)[tableView dequeueReusableCellWithIdentifier: cellIdentifier];
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(!self.tableView.editing) {
        return;
    }
    
    [self updateDeleteButtonTitle];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(!self.tableView.editing) {
        return;
    }
    
    [self updateDeleteButtonTitle];
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
}

@end
