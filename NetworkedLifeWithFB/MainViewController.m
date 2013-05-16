//
//  MainViewController.m
//  NetworkedLifeWithFB
//
//  Created by YiBin on 13/5/2.
//  Copyright (c) 2013年 YiBin. All rights reserved.
//

#import "MainViewController.h"
#import "MainAppDelegate.h"
#import "FacebookNetwork.h"
#import "User.h"
#import "Friend.h"
#import "Like.h"
#import "Checkin.h"

@interface MainViewController () <facebookDelegate, NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate> {
    NSMutableArray *friendlist;
    NSMutableArray *friendlikes;
    NSMutableArray *friendcheckins;
    NSMutableArray *mycheckins;
    NSMutableArray *mylikes;
    int getCount;
    
    int loadFriendLimit;
}

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) User *user;

- (void)clearAllInstanceOfEntityWithName:(NSString *)entity;
- (id)checkExistenceWithEntityName:(NSString *)name identifier:(NSString *)identifier;
- (void)saveManagedObjectContext;

-(void)loadDataFinish;

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
	// Do any additional setup after loading the view, typically from a nib.
    NSLog(@"Start, Time: %@", [NSDate date]);
    // Init ManagedObjectContext
    MainAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = [appDelegate managedObjectContext];
    
    
    [FacebookNetwork shareFacebook].delegate = self;
    [[FacebookNetwork shareFacebook] login];
    friendlist = [[NSMutableArray alloc] init];
    friendcheckins = [[NSMutableArray alloc] init];
    friendlikes = [[NSMutableArray alloc] init];
    mycheckins = [[NSMutableArray alloc] init];
    mylikes = [[NSMutableArray alloc] init];
    getCount = 0;
    
    loadFriendLimit = 423;
    
    [self clearAllInstanceOfEntityWithName:@"User"];
    [self clearAllInstanceOfEntityWithName:@"Friend"];
    [self clearAllInstanceOfEntityWithName:@"Like"];
    [self clearAllInstanceOfEntityWithName:@"Checkin"];
}

#pragma mark Custom CoreData methods

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
    }
    
    NSError *saveError = nil;
    if (![self.managedObjectContext save:&saveError]) {
        NSLog(@"Unresolved error %@, %@", saveError, [saveError userInfo]);
        exit(-1);
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
- (void)saveManagedObjectContext {
    
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        exit(-1);
    }
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
    static NSString *CellIdentifier = @"SubtitleCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

#pragma mark UITableViewDelegate

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Friend *friend = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = friend.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d score", [friend.sumOfScore intValue]];
}

#pragma mark - facebookDelegate

-(void)facebookLoginSuccess {
    NSLog(@"loginSuccess");
    [[FacebookNetwork shareFacebook]requestMyLike];
    //    [[FacebookNetwork shareFacebook] requestFriendInfo];
}

-(void)facebookRequestDidFinish:(id)result {
    if ([FacebookNetwork shareFacebook].fbState == FacebookStateTypeMyLikes) {
        NSLog(@"getMyLikes");
        /*=================自己按贊資料============================*/
        NSString *myID = [result objectForKey:@"id"];

        // Create user data and save it to database
        
        User *user = [self checkExistenceWithEntityName:@"User" identifier:myID];
        if (user == nil) {
            user = (User *)[NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:self.managedObjectContext];
            
            if (user != nil) {
                
                user.identifier = myID;
//                user.name = ?;        
            } else {
                NSLog(@"Failed to create the new object");
            }
        }
        self.user = user;
        [self saveManagedObjectContext];
        
        NSArray* data = [((NSDictionary*)[result objectForKey:@"likes"]) objectForKey:@"data"];
        for (NSDictionary *dic in data) {
            NSString *likeID = [dic objectForKey:@"id"];
            Like *like = [self checkExistenceWithEntityName:@"Like" identifier:likeID];
            if (like == nil) {
                like = (Like *)[NSEntityDescription insertNewObjectForEntityForName:@"Like" inManagedObjectContext:self.managedObjectContext];
                
                if (like != nil) {
                    
                    like.identifier = likeID;
                    like.name = [dic objectForKey:@"name"];

                } else {
                    NSLog(@"Failed to create the new object");
                }
            }
            [self.user addLikesObject:like];
            [self saveManagedObjectContext];
            
            [mylikes addObject:like];
        }
//        NSLog(@"mylikes%@",mylikes);
        [[FacebookNetwork shareFacebook] requestMyCheckins];
        
    }else if ([FacebookNetwork shareFacebook].fbState == FacebookStateTypeMyCheckins) {
        NSLog(@"getMyCheckins");
        /*=================自己打卡資料============================*/
            NSArray* data = [((NSDictionary*)[result objectForKey:@"checkins"]) objectForKey:@"data"];
            for (NSDictionary *dic in data) {
                
                NSDictionary *place = [dic objectForKey:@"place"];
                NSString *placeID = [place objectForKey:@"id"];
                Checkin *checkin = [self checkExistenceWithEntityName:@"Checkin" identifier:placeID];
                if (checkin == nil) {
                    checkin = (Checkin *)[NSEntityDescription insertNewObjectForEntityForName:@"Checkin" inManagedObjectContext:self.managedObjectContext];
                    if (checkin != nil) {
                        
                        checkin.identifier = placeID;
                        checkin.name = [place objectForKey:@"name"];
                        
                    } else {
                        NSLog(@"Failed to create the new object");
                    }
                }
                
                [self.user addCheckinsObject:checkin];
                [self saveManagedObjectContext];
                
                [mycheckins addObject:checkin];
            }
//        NSLog(@"mycheckins%@",mycheckins);
            [[FacebookNetwork shareFacebook] requestFriendInfo];
    }else if ([FacebookNetwork shareFacebook].fbState == FacebookStateTypeFriendList) {
        /*=================朋友資料============================*/
        NSLog(@"getFriendData");
//        loadFriendLimit = 1;
        NSArray* data = [result objectForKey:@"data"];
        for (NSDictionary *friendID in data) {
            NSString *fID = [friendID objectForKey:@"id"];
            
            Friend *friend = [self checkExistenceWithEntityName:@"Friend" identifier:fID];
            if (friend == nil) {
                friend = (Friend *)[NSEntityDescription insertNewObjectForEntityForName:@"Friend" inManagedObjectContext:self.managedObjectContext];
                if (friend != nil) {
                    
                    friend.identifier = fID;
                    friend.name = [friendID objectForKey:@"name"];

                } else {
                    NSLog(@"Failed to create the new object");
                }
            }
            
            [self saveManagedObjectContext];
            [friendlist addObject:friend];
        }
        getCount = 0;
//        for (NSDictionary *dic in friendlist) {
        if (loadFriendLimit >[friendlist count]) {
            loadFriendLimit = [friendlist count];
        }
        for (int i=0 ; i<loadFriendLimit ;i++) {
//            NSDictionary *dic = [friendlist objectAtIndex:i];
//            [[FacebookNetwork shareFacebook] requestFriendLikeBYUID:[dic objectForKey:@"id"]];
            Friend *friendData = friendlist[i];
            [[FacebookNetwork shareFacebook] requestFriendLikeBYUID:friendData.identifier];
        }
//        NSLog(@"friend :  %@",friendlist);
    }else if ([FacebookNetwork shareFacebook].fbState == FacebookStateTypeFriendLikes){
        /*=================朋友按贊資料============================*/
        getCount++;
        NSString *fID = [result objectForKey:@"id"];
        NSArray* data = [((NSDictionary*)[result objectForKey:@"likes"]) objectForKey:@"data"];
        NSLog(@"likes-------%@-------",fID);
        
        NSMutableArray *likes = [[NSMutableArray alloc] init];
        for (NSDictionary *dic in data) {
            NSString *likeID = [dic objectForKey:@"id"];
            Like *like = [self checkExistenceWithEntityName:@"Like" identifier:likeID];
            if (like == nil) {
                like = [NSEntityDescription insertNewObjectForEntityForName:@"Like" inManagedObjectContext:self.managedObjectContext];
                
                if (like != nil) {
                    like.identifier = likeID;
                    like.name = [dic objectForKey:@"name"];
                } else {
                    NSLog(@"Failed to create the new object");
                }
            }
            
            Friend *friend = [self checkExistenceWithEntityName:@"Friend" identifier:fID];
            [friend addLikesObject:like];
            [self saveManagedObjectContext];
            
            [likes addObject:like];
        }
        [friendlikes addObject:likes];
        
//        if (getCount >= [friendlist count]) {
        
        if (getCount >= loadFriendLimit) {
            getCount = 0;
//            for (NSDictionary *dic in friendlist) {
//                [[FacebookNetwork shareFacebook] requestFriendCheckinsBYUID:[dic objectForKey:@"id"]];
//            }
            for (int i=0 ; i<loadFriendLimit ;i++) {
                Friend *friend = friendlist[i];
                [[FacebookNetwork shareFacebook] requestFriendCheckinsBYUID:friend.identifier];
            }
        
        }
    } else if([FacebookNetwork shareFacebook].fbState == FacebookStateTypeFriendCheckins){
        getCount++;
        /*=================朋友打卡資料============================*/
        
        NSString *fID = [result objectForKey:@"id"];
        NSArray* data = [((NSDictionary*)[result objectForKey:@"checkins"]) objectForKey:@"data"];
        
        NSMutableArray *checkins = [[NSMutableArray alloc] init];
        NSLog(@"checkins-------%@-------",fID);
        for (NSDictionary *dic in data) {
            NSDictionary *place = [dic objectForKey:@"place"];
            NSString *checkinID = [place objectForKey:@"id"];
            
            Checkin *checkin = [self checkExistenceWithEntityName:@"Checkin" identifier:checkinID];
            if (checkin == nil) {
                checkin = [NSEntityDescription insertNewObjectForEntityForName:@"Checkin" inManagedObjectContext:self.managedObjectContext];
                
                if (checkin != nil) {
                    checkin.identifier = checkinID;
                    checkin.name = [place objectForKey:@"name"];
                } else {
                    NSLog(@"Failed to create the new object");
                }
            }
            
            Friend *friend = [self checkExistenceWithEntityName:@"Friend" identifier:fID];
            [friend addCheckinsObject:checkin];
            [self saveManagedObjectContext];
            
            [checkins addObject:checkin];
        }
        [friendcheckins addObject:checkins];
        
//        if (getCount >= [friendlist count]) {
        
//        loadFriendLimit = [friendlist count];
        if (getCount >= loadFriendLimit) {
            getCount = 0;
            [self loadDataFinish];
        }
    }
}

-(void)loadDataFinish {
    NSLog(@"loadDataFinish");
    NSLog(@"friend :%@",friendlist);
    /* friendlist 是一個Array，裡面存Friend */
    NSLog(@"friendlike :%@",friendlikes);
    /* friendlikes 是一個NSMutableArray裡面存著friendlist的排序對應到的第幾個好友的全部likes
        一樣是用NSMutableArray，裡面存Like
     */
    NSLog(@"friendcheckin :%@",friendcheckins);
    /* friendcheckins 是一個NSMutableArray裡面存著friendlist的排序對應到的第幾個好友的全部checkins
     一樣是用NSMutableArray，裡面存Checkin
     */
    NSLog(@"Download finished, Time: %@", [NSDate date]);
    NSLog(@"Download friend count: %d", friendlist.count);
    NSLog(@"MyLikes count: %d", mylikes.count);
    NSLog(@"MyCheckIns count: %d", mycheckins.count);
    
    NSUInteger compareNumber = 0;
//    for (int theIndex = 0; theIndex < friendlist.count; theIndex++) {
    for (int theIndex = 0; theIndex < loadFriendLimit; theIndex++) {
        NSArray *fLikes = friendlikes[theIndex];
        NSUInteger sameLikes = 0;
        
        // Check like id
        for (Like *fLike in fLikes) {
            for (Like *mLike in mylikes) {
                if ([fLike.identifier isEqualToString:mLike.identifier]) {
                    sameLikes++;
                    break;
                }
            }
        }
        
        NSUInteger sameCheckins = 0;
        NSArray *fCheckins = friendcheckins[theIndex];
        
        // Check like's id
        for (Checkin *fCheckin in fCheckins) {
            for (Checkin *mCheckin in mycheckins) {
                if ([fCheckin.identifier isEqualToString:mCheckin.identifier]) {
                    sameCheckins++;
                    break;
                }
            }
        }
        
        // Create friend data and save it to database
        Friend *friend = friendlist[theIndex];
        if (friend != nil) {
            friend.scoreOfLikes = @(sameLikes);
            friend.scoreOfCheckins = @(sameCheckins);
            friend.sumOfScore = @(sameLikes + sameCheckins);
            
            NSError *error = nil;
            if (![self.managedObjectContext save:&error]) {
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                exit(-1);
            }
        } else {
            NSLog(@"Failed to create the new friend object");
        }
    }
    self.fetchedResultsController = nil;
    [self.tableView reloadData];
    
    NSLog(@"Compare number: %d", compareNumber);
    NSLog(@"Compare Finished, Time: %@", [NSDate date]);
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
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
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
