//
//  LoginViewController.m
//  NetworkedLifeWithFB
//
//  Created by yang on 13/5/17.
//  Copyright (c) 2013年 YiBin. All rights reserved.
//

#import "LoginViewController.h"
#import "MainAppDelegate.h"
#import "User.h"
#import "Friend.h"
#import "Like.h"
#import "Checkin.h"
#import "Cell.h"
#import <FacebookSDK/FacebookSDK.h>
#import "MBProgressHUD.h"


#define loadFriendLimit 50

@interface LoginViewController () <MBProgressHUDDelegate> {
    int currentFriendCount;
    int currentFriendLikeCount;
    int currentFriendCheckinCount;
    
    MBProgressHUD *hud;
}

@property (nonatomic, strong) MainAppDelegate *appDelegate;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

-(IBAction)loginBtn:(id)sender;

- (void)clearWholeDatabase;
- (void)clearAllInstanceOfEntityWithName:(NSString *)entity;
- (id)checkExistenceWithEntityName:(NSString *)name identifier:(NSString *)identifier;
- (void)saveManagedObjectContext;
- (NSArray *)getInstanceWithEntityName:(NSString *)name identifier:(NSString *)identifier;
- (NSArray *)getAllInstanceWithEntityName:(NSString *)name;

- (void)sendFBRequestForUser;
- (void)requestCompletedForUser:(FBRequestConnection *)connection result:(id)result error:(NSError *)error;

- (void)sendFBRequestForLikesOfUser:(User *)user;
- (void)requestCompletedForLikes:(FBRequestConnection *)connection withUser:(User *)user result:(id)result error:(NSError *)error;

- (void)sendFBRequestForCheckinsOfUser:(User *)user;
- (void)requestCompletedForCheckins:(FBRequestConnection *)connection withUser:(User *)user result:(id)result error:(NSError *)error;

- (void)sendFBRequestForFirendsWithUser:(User *)user;
- (void)requestCompletedForFriends:(FBRequestConnection *)connection withUser:(User *)user result:(id)result error:(NSError *)error;

/*!
 @method
 When you want to use sendFBRequestForLikesOfFriends: or sendFBRequestForCheckinsOfFriends:
 @param [friends count] must <= 50
 */
- (void)sendFBRequestForLikesOfFriends:(NSArray *)friends;
- (void)requestCompletedForLikes:(FBRequestConnection *)connection withFriend:(Friend *)friend result:(id)result error:(NSError *)error;

- (void)sendFBRequestForCheckinsOfFriends:(NSArray *)friends;
- (void)requestCompletedForCheckins:(FBRequestConnection *)connection withFriend:(Friend *)friend result:(id)result error:(NSError *)error;

@end

@implementation LoginViewController

#pragma mark view lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]]];
    
    // Init ManagedObjectContext
    MainAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = [appDelegate managedObjectContext];
    
    currentFriendCount = 0;
    currentFriendLikeCount = 0;
    currentFriendCheckinCount = 0;
    
    [self clearWholeDatabase];
    [self.navigationController.visibleViewController setTitle:@"大家愛什麼"];
    
    [self loginBtn:nil];
}

-(IBAction)loginBtn:(id)sender
{
    if ([[FBSession activeSession] isOpen]) {
        [self hudWasHidden:nil];
//        [self sendFBRequestForUser];
//        [self showProgressHUD];
        
    } else {
        [FBSession openActiveSessionWithReadPermissions:nil allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
            if (error) {
                NSLog(@"Error: %@, %@", error, [error userInfo]);
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            } else {
                [self sendFBRequestForUser];
                [self showProgressHUD];
            }
        }];
    }
}

- (void)showProgressHUD
{
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    hud.labelText = @"Loading";
    
    hud.color = [UIColor colorWithRed:80.0/255.0 green:68.0/255.0 blue:57.0/255.0 alpha:0.9];
    hud.delegate = self;
    hud.minSize = CGSizeMake(173, 173);
    [hud show:YES];
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

#pragma mark - Custom Facebook Methods

- (void)sendFBRequestForUser
{
    // create the connection object
    FBRequestConnection *connection = [[FBRequestConnection alloc] init];
    
    // create the request object
    FBRequest *request = [[FBRequest alloc] initWithSession:[FBSession activeSession] graphPath:@"/me?fields=id,name"];
    
    // add the request to the connection object, if more than one request is added
    // the connection object will compose the requests as a batch request; whether or
    // not the request is a batch or a singleton, the handler behavior is the same,
    // allowing the application to be dynamic in regards to whether a single or multiple
    // requests are occuring
    [connection addRequest:request completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        [self requestCompletedForUser:connection result:result error:error];
    }];
    
    [connection start];
}

- (void)requestCompletedForUser:(FBRequestConnection *)connection result:(id)result error:(NSError *)error
{
    //    NSLog(@"%@", result);
    if (!error) {
        NSString *userID = [result objectForKey:@"id"];
        NSLog(@"User ID: %@", userID);
        
        User *user = [self checkExistenceWithEntityName:@"User" identifier:userID];
        if (user == nil) {
            user = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:self.managedObjectContext];
            
            if (user != nil) {
                
                user.identifier = userID;
                user.name = [result objectForKey:@"name"];
            } else {
                NSLog(@"Failed to create the new object");
            }
        }
        [self saveManagedObjectContext];
        
        // Get details data
        [self sendFBRequestForLikesOfUser:user];
        [self sendFBRequestForCheckinsOfUser:user];
        [self sendFBRequestForFirendsWithUser:user];
        
    } else {
        NSLog(@"RequestCompletedForUser Error: %@, %@", error, [error userInfo]);
    }
}

- (void)sendFBRequestForLikesOfUser:(User *)user
{
    FBRequestConnection *connection = [[FBRequestConnection alloc] init];
    
    FBRequest *request = [[FBRequest alloc] initWithSession:[FBSession activeSession] graphPath:@"/me?fields=likes"];
    
    [connection addRequest:request completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        [self requestCompletedForLikes:connection withUser:user result:result error:error];
    }];
    
    [connection start];
}

- (void)requestCompletedForLikes:(FBRequestConnection *)connection withUser:(User *)user result:(id)result error:(NSError *)error
{
    //    NSLog(@"%@", result);
    
    if (!error) {
        NSArray *data = [[result objectForKey:@"likes"] objectForKey:@"data"];
        
        for (NSDictionary *likeData in data) {
            NSString *likeID = [likeData objectForKey:@"id"];
            NSLog(@"User ID: %@, Likes: %@", user.identifier, likeID);
            
            Like *like = [self checkExistenceWithEntityName:@"Like" identifier:likeID];
            if (like == nil) {
                like = [NSEntityDescription insertNewObjectForEntityForName:@"Like" inManagedObjectContext:self.managedObjectContext];
                
                if (like != nil) {
                    
                    like.identifier = likeID;
                    like.name = [likeData objectForKey:@"name"];
                } else {
                    NSLog(@"Failed to create the new object");
                }
            }
            [user addLikesObject:like];
        }
        [self saveManagedObjectContext];
        
    } else {
        NSLog(@"RequestCompletedForLikes Error: %@, %@", error, [error userInfo]);
    }
}

- (void)sendFBRequestForCheckinsOfUser:(User *)user
{
    FBRequestConnection *connection = [[FBRequestConnection alloc] init];
    
    FBRequest *request = [[FBRequest alloc] initWithSession:[FBSession activeSession] graphPath:@"/me?fields=checkins.fields(place)"];
    
    [connection addRequest:request completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        [self requestCompletedForCheckins:connection withUser:user result:result error:error];
    }];
    
    [connection start];
}

- (void)requestCompletedForCheckins:(FBRequestConnection *)connection withUser:(User *)user result:(id)result error:(NSError *)error
{
    //    NSLog(@"%@", result);
    
    if (!error) {
        NSArray *data = [[result objectForKey:@"checkins"] objectForKey:@"data"];
        
        for (NSDictionary *placeDic in data) {
            NSDictionary *place = [placeDic objectForKey:@"place"];
            NSString *placeID = [place objectForKey:@"id"];
            
            NSLog(@"User ID: %@, Checkin: %@", user.identifier, placeID);
            
            Checkin *checkin = [self checkExistenceWithEntityName:@"Checkin" identifier:placeID];
            if (checkin == nil) {
                checkin = [NSEntityDescription insertNewObjectForEntityForName:@"Checkin" inManagedObjectContext:self.managedObjectContext];
                
                if (checkin != nil) {
                    
                    checkin.identifier = placeID;
                    checkin.name = [place objectForKey:@"name"];
                } else {
                    NSLog(@"Failed to create the new object");
                }
            }
            [user addCheckinsObject:checkin];
        }
        [self saveManagedObjectContext];
        
    } else {
        NSLog(@"RequestCompletedForCheckins Error: %@, %@", error, [error userInfo]);
    }
}

- (void)sendFBRequestForFirendsWithUser:(User *)user
{
    FBRequestConnection *connection = [[FBRequestConnection alloc] init];
    
    FBRequest *request = [[FBRequest alloc] initWithSession:FBSession.activeSession graphPath:@"/me?fields=friends"];
    
    [connection addRequest:request completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        [self requestCompletedForFriends:connection withUser:user result:result error:error];
    }];
    
    [connection start];
}

- (void)requestCompletedForFriends:(FBRequestConnection *)connection withUser:(User *)user result:(id)result error:(NSError *)error
{
    //    NSLog(@"%@", result);
    
    if (!error) {
        NSArray *data = [[result objectForKey:@"friends"] objectForKey:@"data"];
        
        NSMutableArray *friends = [[NSMutableArray alloc] init];
        
        for (NSDictionary *friendData in data) {
            NSString *fID = [friendData objectForKey:@"id"];
            
            NSLog(@"Friend ID: %@", fID);
            
            Friend *friend = [self checkExistenceWithEntityName:@"Friend" identifier:fID];
            if (friend == nil) {
                friend = (Friend *)[NSEntityDescription insertNewObjectForEntityForName:@"Friend" inManagedObjectContext:self.managedObjectContext];
                if (friend != nil) {
                    
                    friend.identifier = fID;
                    friend.name = [friendData objectForKey:@"name"];
                    
                } else {
                    NSLog(@"Failed to create the new object");
                }
            }
            [user addFriendsObject:friend];
            
            [friends addObject:friend];
            
//            if (friends.count == 50) {
            if (friends.count == loadFriendLimit) {
                [self sendFBRequestForLikesOfFriends:friends];
                [self performSelector:@selector(sendFBRequestForCheckinsOfFriends:) withObject:friends afterDelay:10];
//                [self sendFBRequestForCheckinsOfFriends:friends];
                
                friends = [[NSMutableArray alloc] init];
                break;
            }
        }
        [self saveManagedObjectContext];
    } else {
        NSLog(@"RequestCompletedForFriends Error: %@, %@", error, [error userInfo]);
    }
}

- (void)sendFBRequestForLikesOfFriends:(NSArray *)friends
{
    currentFriendLikeCount += [friends count];
    
    FBRequestConnection *connection = [[FBRequestConnection alloc] init];
    
    for (Friend *friend in friends) {
        NSString *graphPath = [NSString stringWithFormat:@"/%@?fields=likes", friend.identifier];
        FBRequest *request = [[FBRequest alloc] initWithSession:[FBSession activeSession] graphPath:graphPath];
        
        [connection addRequest:request completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            [self requestCompletedForLikes:connection withFriend:friend result:result error:error];
        }];
    }
    
    [connection start];
}

- (void)requestCompletedForLikes:(FBRequestConnection *)connection withFriend:(Friend *)friend result:(id)result error:(NSError *)error
{
    //    NSLog(@"%@", result);
    
    if (!error) {
        NSArray *data = [[result objectForKey:@"likes"] objectForKey:@"data"];
        
        for (NSDictionary *likeData in data) {
            NSString *likeID = [likeData objectForKey:@"id"];
            
            NSLog(@"Friend ID: %@, Likes: %@", friend.identifier, likeID);
            
            Like *like = [self checkExistenceWithEntityName:@"Like" identifier:likeID];
            if (like == nil) {
                like = [NSEntityDescription insertNewObjectForEntityForName:@"Like" inManagedObjectContext:self.managedObjectContext];
                
                if (like != nil) {
                    
                    like.identifier = likeID;
                    like.name = [likeData objectForKey:@"name"];
                } else {
                    NSLog(@"Failed to create the new object");
                }
            }
            [friend addLikesObject:like];
        }
        [self saveManagedObjectContext];
        
    } else {
        NSLog(@"RequestCompletedForLikes Error: %@, %@", error, [error userInfo]);
    }
    
    if (--currentFriendLikeCount == 0) {
        [self compareLikes];
    }
}

- (void)sendFBRequestForCheckinsOfFriends:(NSArray *)friends
{
    currentFriendCheckinCount += [friends count];
    
    FBRequestConnection *connection = [[FBRequestConnection alloc] init];
    
    for (Friend *friend in friends) {
        NSString *graphPath = [NSString stringWithFormat:@"/%@?fields=checkins.fields(place)", friend.identifier];
        FBRequest *request = [[FBRequest alloc] initWithSession:[FBSession activeSession] graphPath:graphPath];
        
        [connection addRequest:request completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            [self requestCompletedForCheckins:connection withFriend:friend result:result error:error];
        }];
    }
    
    [connection start];
}

- (void)requestCompletedForCheckins:(FBRequestConnection *)connection withFriend:(Friend *)friend result:(id)result error:(NSError *)error
{
    //    NSLog(@"%@", result);
    
    if (!error) {
        NSArray *data = [[result objectForKey:@"checkins"] objectForKey:@"data"];
        
        for (NSDictionary *placeDic in data) {
            NSDictionary *place = [placeDic objectForKey:@"place"];
            NSString *placeID = [place objectForKey:@"id"];
            
            NSLog(@"Friend ID: %@, Checkin: %@", friend.identifier, placeID);
            
            Checkin *checkin = [self checkExistenceWithEntityName:@"Checkin" identifier:placeID];
            if (checkin == nil) {
                checkin = [NSEntityDescription insertNewObjectForEntityForName:@"Checkin" inManagedObjectContext:self.managedObjectContext];
                
                if (checkin != nil) {
                    checkin.identifier = placeID;
                    checkin.name = [place objectForKey:@"name"];
                } else {
                    NSLog(@"Failed to create the new object");
                }
            }
            [friend addCheckinsObject:checkin];
        }
        [self saveManagedObjectContext];
        
    } else {
        NSLog(@"RequestCompletedForCheckins Error: %@, %@", error, [error userInfo]);
    }
    
    if (--currentFriendCheckinCount == 0) {
        [self compareCheckins];
    }
}

#pragma mark Compare Score

- (void)compareLikes
{
    User *user = [[self getAllInstanceWithEntityName:@"User"] lastObject];
    
    for (Friend *friend in user.friends) {
        int scoreOfLike = 0;
        
        for (Like *friendLike in friend.likes) {
            for (Like *userLike in user.likes) {
                if ([friendLike.identifier isEqualToString:userLike.identifier]) {
                    scoreOfLike++;
                }
            }
        }
        
        friend.scoreOfLikes = @(scoreOfLike);
        int sum = [friend.sumOfScore intValue] + scoreOfLike;
        friend.sumOfScore = @(sum);
    }
    [self saveManagedObjectContext];
    NSLog(@"Compare Like finished, Time: %@", [NSDate date]);
    [self compareAllFinished];
}

- (void)compareCheckins
{
    User *user = [[self getAllInstanceWithEntityName:@"User"] lastObject];
    
    for (Friend *friend in user.friends) {
        int scoreOfCheckin = 0;
        
        for (Checkin *friendCheckin in friend.checkins) {
            for (Checkin *userCheckin in user.checkins) {
                if ([friendCheckin.identifier isEqualToString:userCheckin.identifier]) {
                    scoreOfCheckin++;
                }
            }
        }
        
        friend.scoreOfCheckins = @(scoreOfCheckin);
        int sum = [friend.sumOfScore intValue] + scoreOfCheckin*2;
        friend.sumOfScore = @(sum);
    }
    [self saveManagedObjectContext];
    NSLog(@"Compare Checkin finished, Time: %@", [NSDate date]);
    [self compareAllFinished];
}

- (void)compareAllFinished
{
    if ((currentFriendLikeCount == 0) && (currentFriendCheckinCount == 0)) {
        [self saveManagedObjectContext];
        
        hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"check.png"]];
        hud.mode = MBProgressHUDModeCustomView;
        hud.labelText = @"Completed";
        [hud hide:YES afterDelay:1.0];
    }
}

#pragma mark - hudDelegate

- (void)hudWasHidden:(MBProgressHUD *)hud_ {
	// Remove HUD from screen when the HUD was hidded
    
    [hud_ removeFromSuperViewOnHide];
    hud_ = nil;
    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    UIViewController* FirstViewController = [storyboard instantiateViewControllerWithIdentifier:@"MainViewController"];
    FirstViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:FirstViewController animated:YES completion:nil];
}

@end
