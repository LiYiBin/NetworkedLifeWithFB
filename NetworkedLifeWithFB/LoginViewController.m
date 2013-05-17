//
//  LoginViewController.m
//  NetworkedLifeWithFB
//
//  Created by yang on 13/5/17.
//  Copyright (c) 2013年 YiBin. All rights reserved.
//
#import "MainAppDelegate.h"
#import "LoginViewController.h"
#import "FacebookNetwork.h"
#import "User.h"
#import "Friend.h"
#import "Like.h"
#import "Checkin.h"
#import "MBProgressHUD.h"

@interface LoginViewController ()<facebookDelegate,NSFetchedResultsControllerDelegate,MBProgressHUDDelegate>{
    NSMutableArray *friendlist;
    NSMutableArray *friendlikes;
    NSMutableArray *friendcheckins;
    NSMutableArray *mycheckins;
    NSMutableArray *mylikes;
    int getCount;
    
    int loadFriendLimit;
    
    MBProgressHUD*      hud;
}
@property (nonatomic, strong) User *user;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;



- (void)clearAllInstanceOfEntityWithName:(NSString *)entity;
- (id)checkExistenceWithEntityName:(NSString *)name identifier:(NSString *)identifier;
- (void)saveManagedObjectContext;

-(void)loadDataFinish;

@end

@implementation LoginViewController

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

#pragma mark view

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]]];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"loginUID"];
    
    MainAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = [appDelegate managedObjectContext];
    friendlist = [[NSMutableArray alloc] init];
    friendcheckins = [[NSMutableArray alloc] init];
    friendlikes = [[NSMutableArray alloc] init];
    mycheckins = [[NSMutableArray alloc] init];
    mylikes = [[NSMutableArray alloc] init];
    getCount = 0;
    
    loadFriendLimit = 10;
    
    [self clearAllInstanceOfEntityWithName:@"User"];
    [self clearAllInstanceOfEntityWithName:@"Friend"];
    [self clearAllInstanceOfEntityWithName:@"Like"];
    [self clearAllInstanceOfEntityWithName:@"Checkin"];

}


-(IBAction)loginBtn:(id)sender{
    [FacebookNetwork shareFacebook].delegate = self;
    [[FacebookNetwork shareFacebook] login];
}


#pragma mark hudDelegate -
- (void)hudWasHidden:(MBProgressHUD *)hud_ {
	// Remove HUD from screen when the HUD was hidded
    
    [hud_ removeFromSuperViewOnHide];
    hud_ = nil;
    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    UIViewController* FirstViewController = [storyboard instantiateViewControllerWithIdentifier:@"MainViewController"];
    //    [self presentModalViewController:FirstViewController animated:YES];
    [self presentViewController:FirstViewController animated:NO completion:nil];
}

#pragma mark - facebookDelegate

-(void)facebookLoginSuccess {
    NSLog(@"loginSuccess");
    [[FacebookNetwork shareFacebook]requestMyLike];
    
    //讀取進度
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    hud.labelText = @"Loading";
    
    hud.color = [UIColor colorWithRed:80.0/255.0 green:68.0/255.0 blue:57.0/255.0 alpha:0.9];
    hud.delegate = self;
    hud.minSize = CGSizeMake(173, 173);
    [hud show:YES];

}

-(void)facebookRequestDidFinish:(id)result {
    if ([FacebookNetwork shareFacebook].fbState == FacebookStateTypeMyLikes) {
        NSLog(@"getMyLikes");
        /*=================自己按贊資料============================*/
        NSString *myID = [result objectForKey:@"id"];
        [[NSUserDefaults standardUserDefaults] setObject:myID forKey:@"loginUID"];
        
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
        [hud setLabelText:[NSString stringWithFormat:@"0/%d",loadFriendLimit*2]];
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
            [self.user addFriendsObject:friend];
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
        [hud setLabelText:[NSString stringWithFormat:@"%d/%d",getCount,loadFriendLimit*2]];
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
        [hud setLabelText:[NSString stringWithFormat:@"%d/%d",getCount+loadFriendLimit,loadFriendLimit*2]];
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
    
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"check.png"]];
    hud.mode = MBProgressHUDModeCustomView;
    hud.labelText = @"Completed";
    [hud hide:YES afterDelay:1.0];
    
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
    
    NSLog(@"Compare Finished, Time: %@", [NSDate date]);
    
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

// This method can get special instance of entity
- (NSArray *)getInstanceWithEntityName:(NSString *)name identifier:(NSString *)identifier
{
    NSError *error = nil;
    NSFetchRequest *instance = [[NSFetchRequest alloc] init];
    [instance setEntity:[NSEntityDescription entityForName:name inManagedObjectContext:self.managedObjectContext]];
    [instance setPredicate:[NSPredicate predicateWithFormat:@"identifier == %@", identifier]];
    
    return [self.managedObjectContext executeFetchRequest:instance error:&error];
}

- (NSArray *)getALLInstanceWithEntityName:(NSString *)name
{
    NSError *error = nil;
    NSFetchRequest *instance = [[NSFetchRequest alloc] init];
    [instance setEntity:[NSEntityDescription entityForName:name inManagedObjectContext:self.managedObjectContext]];
    
    return [self.managedObjectContext executeFetchRequest:instance error:&error];
}



@end
