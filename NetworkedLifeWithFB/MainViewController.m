//
//  MainViewController.m
//  NetworkedLifeWithFB
//
//  Created by YiBin on 13/5/2.
//  Copyright (c) 2013年 YiBin. All rights reserved.
//

#import "MainViewController.h"
#import "MainAppDelegate.h"
#import "User.h"
#import "Friend.h"
#import "Like.h"
#import "Checkin.h"
#import "Cell.h"
#import <FacebookSDK/FacebookSDK.h>
#import "LoginViewController.h"
#import "DetialViewController.h"

@interface MainViewController () <NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) MainAppDelegate *appDelegate;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (void)clearWholeDatabase;
- (void)clearAllInstanceOfEntityWithName:(NSString *)entity;
- (id)checkExistenceWithEntityName:(NSString *)name identifier:(NSString *)identifier;
- (void)saveManagedObjectContext;
- (NSArray *)getInstanceWithEntityName:(NSString *)name identifier:(NSString *)identifier;
- (NSArray *)getAllInstanceWithEntityName:(NSString *)name;

@end

@implementation MainViewController

#pragma mark - getter

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Friend" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sumOfScore" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Root"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}

#pragma mark view lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Init ManagedObjectContext
    MainAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = [appDelegate managedObjectContext];

     [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]]];
    [self.tableView setBackgroundColor:[[UIColor whiteColor] colorWithAlphaComponent:0.7]];
    
    UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"登出" style:UIBarButtonItemStylePlain
                                                                     target:self action:@selector(logOut)];
    self.navigationItem.rightBarButtonItem = anotherButton;
    
    
    if ([[FBSession activeSession] isOpen]) {
        [self.tableView reloadData];
    } else {
        [self logOut];
    }
}

-(void)logOut
{
    [[FBSession activeSession] closeAndClearTokenInformation];
    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    LoginViewController* FirstViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    [self presentViewController:FirstViewController animated:NO completion:nil];
}

#pragma mark Custom CoreData methods

- (void)clearWholeDatabase
{
    NSError *error;
    // retrieve the store URL
    NSURL *storeURL = [[self.managedObjectContext persistentStoreCoordinator] URLForPersistentStore:[[[self.managedObjectContext persistentStoreCoordinator] persistentStores] lastObject]];
    // lock the current context
    [self.managedObjectContext lock];
    [self.managedObjectContext reset];//to drop pending changes
    //delete the store from the current managedObjectContext
    if ([[self.managedObjectContext persistentStoreCoordinator] removePersistentStore:[[[self.managedObjectContext persistentStoreCoordinator] persistentStores] lastObject] error:&error])
    {
        // remove the file containing the data
        [[NSFileManager defaultManager] removeItemAtURL:storeURL error:&error];
        //recreate the store like in the  appDelegate method
        [[self.managedObjectContext persistentStoreCoordinator] addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error];//recreates the persistent store
    }
    [self.managedObjectContext unlock];
    //that's it !
}

    // Pass Entity's name and it will clear all instance of entity
- (void)clearAllInstanceOfEntityWithName:(NSString *)entity
{
    NSFetchRequest *allInstance = [[NSFetchRequest alloc] init];
    [allInstance setEntity:[NSEntityDescription entityForName:entity inManagedObjectContext:self.managedObjectContext]];
    
    //only fetch the managedObjectID
    [allInstance setIncludesPropertyValues:NO];
    
    NSError * error = nil;
    NSArray * instances = [self.managedObjectContext executeFetchRequest:allInstance error:&error];
    
    for (NSManagedObject *instance in instances) {
        [self.managedObjectContext deleteObject:instance];
        [self saveManagedObjectContext];
    }
}

    // This method can check the entity has a same instance or not before insert a new instance
    // If it has same instance it will return instance
    // If not it will return nill
- (id)checkExistenceWithEntityName:(NSString *)name identifier:(NSString *)identifier
{
    NSError *error = nil;
    NSFetchRequest *checkExistence = [[NSFetchRequest alloc] init];
    [checkExistence setEntity:[NSEntityDescription entityForName:name inManagedObjectContext:self.managedObjectContext]];
    [checkExistence setFetchLimit:1];
    [checkExistence setPredicate:[NSPredicate predicateWithFormat:@"identifier == %@", identifier]];

    return [[self.managedObjectContext executeFetchRequest:checkExistence error:&error] lastObject];
}
    // If you change data, you must call this method for save data
- (void)saveManagedObjectContext
{    
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        exit(-1);
    }
}

    // This method can get special instance of entity
- (NSArray *)getInstanceWithEntityName:(NSString *)name identifier:(NSString *)identifier
{
    NSError *error = nil;
    NSFetchRequest *instance = [[NSFetchRequest alloc] init];
    [instance setEntity:[NSEntityDescription entityForName:name inManagedObjectContext:self.managedObjectContext]];
    [instance setPredicate:[NSPredicate predicateWithFormat:@"identifier == %@", identifier]];
    
    return [self.managedObjectContext executeFetchRequest:instance error:&error];
}

- (NSArray *)getAllInstanceWithEntityName:(NSString *)name
{
    NSError *error = nil;
    NSFetchRequest *instance = [[NSFetchRequest alloc] init];
    [instance setEntity:[NSEntityDescription entityForName:name inManagedObjectContext:self.managedObjectContext]];
    
    return [self.managedObjectContext executeFetchRequest:instance error:&error];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    Cell *mycell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    [self configureCell:mycell atIndexPath:indexPath];
    
    return mycell;
}

#pragma mark UITableViewDelegate

- (void)configureCell:(Cell *)mycell atIndexPath:(NSIndexPath *)indexPath
{
    Friend *friend = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    [mycell.image loadRequestURL:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large",friend.identifier] user_id:friend.identifier];
    mycell.backgroundColor = [UIColor clearColor];
    mycell.title.text = friend.name;
    mycell.subtitle.text = [NSString stringWithFormat:@"%d score", [friend.sumOfScore intValue]];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    DetialViewController* FirstViewController = [storyboard instantiateViewControllerWithIdentifier:@"DetialViewController"];
    
//    FirstViewController.navigationController.title = self.
    FirstViewController.friends = [self.fetchedResultsController objectAtIndexPath:indexPath];
    FirstViewController.user = [[self getAllInstanceWithEntityName:@"User"] lastObject];
    [self.navigationController pushViewController:FirstViewController animated:YES];
}

#pragma mark NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:(Cell *)[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray
                                               arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray
                                               arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.tableView endUpdates];
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [super viewDidUnload];
}

@end
