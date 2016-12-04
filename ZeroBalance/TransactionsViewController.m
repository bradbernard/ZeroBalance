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
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButtonItem;

@end

@implementation TransactionsViewController

bool deleteAll = true;
static NSString *cellIdentifier = @"TransactionTableCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Transactions";
    self.managedObjectContext = [[[DataController alloc] init] managedObjectContext];
    [self initializeFetchedResultsController];
}

- (void)viewDidUnload {
    self.fetchedResultsController = nil;
}

#pragma mark - IBAction

- (IBAction)editItemPressed:(UIBarButtonItem *)sender {
    [self editPressed];
}

- (IBAction)addItemPressed:(UIBarButtonItem *)sender {
    [self addPressed];
}

#pragma mark - Button Events

-(void) editPressed {
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

-(void) addPressed {
    if(self.tableView.editing) {
        if(deleteAll) {
            [self deleteAllTransactions];
            [self editPressed];
        } else {
            [self deleteSelectedItems];
            [self setToDeleteAll];
        }
    } else {
        [self test];
            //    [self presentViewController:<#(nonnull UIViewController *)#> animated:<#(BOOL)#> completion:<#^(void)completion#>]
    }
}

- (void)test {
    TransactionMO *transaction = [NSEntityDescription insertNewObjectForEntityForName:@"Transaction" inManagedObjectContext: self.managedObjectContext];
    transaction.name = @"Woodstocks Pizza";
    transaction.total = 25.44;
    transaction.date = [NSDate date];
    transaction.formattedDate = [NSDateFormatter localizedStringFromDate:transaction.date dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle];
    transaction.people = @"Billy, Bob, Joe, Barry";
    NSError *error = nil;
    [[self managedObjectContext] save:&error];
}

#pragma mark - Deletion

-(void) setToDeleteAll {
    self.addButtonItem.title = @"Delete all";
    deleteAll = true;
}

-(void) setToDeleteSome: (NSArray*)selectedRows {
    self.addButtonItem.title = [NSString stringWithFormat: @"Delete (%lu)", (unsigned long) selectedRows.count];
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
            [self setToDeleteAll];
        } else {
            [self setToDeleteSome:selectedRows];
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
    [[self managedObjectContext] save:&error];
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
    [self.managedObjectContext save:&error];
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
    cell.peopleLabel.text = object.people;
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
        [[self managedObjectContext] save:&error];
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
