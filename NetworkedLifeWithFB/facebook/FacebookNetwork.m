//
//  FacebookNetwork.m
//  petDog
//
//  Created by CANUOVRX on 12/12/11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "FacebookNetwork.h"
//#import "FBWebDialogs.h"

#warning Need to be filled out in your credentials!!!
NSString * const kFacebookAppID = @"461239953945314";


@implementation FacebookNetwork
static FacebookNetwork* facebooks = nil;

+(FacebookNetwork*)shareFacebook{
    if (facebooks == nil) {
        facebooks = [[FacebookNetwork alloc] init];
    }
    return facebooks;
}

@synthesize delegate;
@synthesize facebook;
@synthesize fbState;
@synthesize appUsageCheckEnabled;

-(id)init{
    self = [super init];
    if (self) {
        if (facebook == nil) {
            facebook = [[Facebook alloc] initWithAppId:kFacebookAppID andDelegate:self];
        }
        defaults = [NSUserDefaults standardUserDefaults];
        
        if ([defaults objectForKey:@"FBAccessTokenKey"] 
            && [defaults objectForKey:@"FBExpirationDateKey"]) {
            facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
            facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
        }
        
        if (![facebook isSessionValid]) {
            [facebook authorize:nil];
        }
        
        
        //發送朋友邀請
        self.appUsageCheckEnabled = YES;
        if ([defaults objectForKey:@"AppUsageCheck"]) {
            self.appUsageCheckEnabled = [defaults boolForKey:@"AppUsageCheck"];
        }
    }
    return self;
}
-(void)login{
    NSLog(@"login");
    if ([facebook isSessionValid] == NO) {
        NSArray *permissions = [[NSArray alloc] initWithObjects:
                                @"user_about_me",	// 個人資訊
                                @"read_stream",		// 瀏覽塗鴉牆、修改閱讀權限..
                                @"publish_actions",	// 到別人牆上貼文
                                @"publish_stream",	// 到別人牆上貼文
                                @"email",
                                @"user_photos",
                                @"user_likes",
                                @"friends_likes",
                                @"offline_access",
                                @"user_checkins",
                                @"friends_checkins",
                                @"friends_photos", 
                                @"friends_about_me",
                                nil];
        [facebook authorize:permissions];
//        [permissions release];
    }else {
        [self fbDidLogin];
    }
    
//    if (self.appUsageCheckEnabled && [self checkAppUsageTrigger]) {
//        // If the user should be prompter to invite friends, show
//        // an alert with the choices.
//        UIAlertView *alert = [[UIAlertView alloc]
//                              initWithTitle:@"Invite Friends"
//                              message:@"If you enjoy using this app, would you mind taking a moment to invite a few friends that you think will also like it?"
//                              delegate:self
//                              cancelButtonTitle:@"No Thanks"
//                              otherButtonTitles:@"Tell Friends!", @"Remind Me Later", nil];
//        [alert show];
//    }
}
#pragma mark -
#pragma mark apprequest
- (void)sendRequest {
//    NSMutableDictionary* params =   [NSMutableDictionary dictionaryWithObjectsAndKeys:nil];
//    [FBWebDialogs presentRequestsDialogModallyWithSession:nil
//                                                  message:[NSString stringWithFormat:@"I just smashed %d friends! Can you beat it?", 20]
//                                                    title:nil
//                                               parameters:params
//                                                  handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
//                                                      if (error) {
//                                                          // Case A: Error launching the dialog or sending request.
//                                                          NSLog(@"Error sending request.");
//                                                      } else {
//                                                          if (result == FBWebDialogResultDialogNotCompleted) {
//                                                              // Case B: User clicked the "x" icon
//                                                              NSLog(@"User canceled request.");
//                                                          } else {
//                                                              NSLog(@"Request Sent.");
//                                                          }
//                                                      }}];
//    // Display the requests dialog
//    [FBRequest  ]
//    [FBDialog
//     presentRequestsDialogModallyWithSession:nil
//     message:@"Learn how to make your iOS apps social."
//     title:nil
//     parameters:nil
//     handler:nil];
}
/*
 * When the alert is dismissed check which button was clicked so
 * you can take appropriate action, such as displaying the request
 * dialog, or setting a flag not to prompt the user again.
 */

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        // User has clicked on the No Thanks button, do not ask again
        [defaults setBool:YES forKey:@"AppUsageCheck"];
        [defaults synchronize];
        self.appUsageCheckEnabled = NO;
    } else if (buttonIndex == 1) {
        // User has clicked on the Tell Friends button
        [self performSelector:@selector(sendRequest)
                   withObject:nil afterDelay:0.5];
    }
}

- (BOOL) checkAppUsageTrigger {
    // Initialize the app active count
    NSInteger appActiveCount = 0;
    // Read the stored value of the counter, if it exists
    if ([defaults objectForKey:@"AppUsedCounter"]) {
        appActiveCount = [defaults integerForKey:@"AppUsedCounter"];
    }
    
    // Increment the counter
    appActiveCount++;
    BOOL trigger = NO;
    // Only trigger the prompt if the facebook session is valid and
    // the counter is greater than a certain value, 3 in this sample
    if (appActiveCount >= 3) {
        trigger = YES;
        appActiveCount = 0;
    }
    // Save the updated counter
    [defaults setInteger:appActiveCount forKey:@"AppUsedCounter"];
    [defaults synchronize];
    return trigger;
}

- (void)sendRequest:(NSArray *) targeted {
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   @"It's your turn, quit slacking.",  @"message",
                                   nil];
    
    // Filter and only show targeted friends
    if (targeted != nil && [targeted count] > 0) {
        NSString *selectIDsStr = [targeted componentsJoinedByString:@","];
        [params setObject:selectIDsStr forKey:@"suggestions"];
    }
    
    [facebook dialog:@"apprequests"
                andParams:params
              andDelegate:self];
}
#pragma mark data request

-(void)requestMyLike{
    fbState = FacebookStateTypeMyLikes;
    [self requestWithGraphPath:@"me?fields=likes"];
    
//    NSString* fql = @"SELECT uid, name, pic_square FROM user WHERE uid = me() OR uid IN (SELECT uid2 FROM friend WHERE uid1 = me())";

//    NSString *fql = @"SELECT user_id, object_id, object_type FROM like WHERE user_id IN (SELECT uid2 FROM friend WHERE uid1 = me())";
//    // Create a params dictionary
//    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObject:fql forKey:@"query"];
//    
//    // Make the request
//    [facebook requestWithMethodName:@"fql.query" andParams:params andHttpMethod:@"GET" andDelegate:self];
    
    // Query to fetch the active user's friends, limit to 25.
    //    NSString *query =
    //    @"SELECT uid, name, pic_square FROM user WHERE uid IN "
    //    @"(SELECT uid2 FROM friend WHERE uid1 = me() LIMIT 25)";
    //    // Set up the query parameter
    //    NSDictionary *queryParam =
    //    [NSDictionary dictionaryWithObjectsAndKeys:query, @"q", nil];
    //    // Make the API request that uses FQL
    //    [facebook startWithGraphPath:@"/fql"
    //                                 parameters:queryParam
    //                                 HTTPMethod:@"GET"
    //                          completionHandler:^(FBRequestConnection *connection,
    //                                              id result,
    //                                              NSError *error) {
    //                              if (error) {
    //                                  NSLog(@"Error: %@", [error localizedDescription]);
    //                              } else {
    //                                  NSLog(@"Result: %@", result);
    //                              }
    //                          }];
    
}

-(void)requestMyCheckins{
    fbState = FacebookStateTypeMyCheckins;
    [self requestWithGraphPath:@"me?fields=checkins"];
}

-(void)requestFriendLikeBYUID:(NSString*)uid{
    
    fbState = FacebookStateTypeFriendLikes;
    [self requestWithGraphPath:[NSString stringWithFormat:@"%@?fields=likes",uid]];
}
-(void)requestFriendCheckinsBYUID:(NSString*)uid{

    fbState = FacebookStateTypeFriendCheckins;
    [self requestWithGraphPath:[NSString stringWithFormat:@"%@?fields=checkins.fields(id,from,place)",uid]];
}


-(void)requestProfileInfo{
    //    [self requestWithGraphPath:@"me"];
    [self requestWithGraphPath:@"me?fields=friends.fields(picture)"];
}


-(void)requestFriendInfo{
    fbState = FacebookStateTypeFriendList;
    [self requestWithGraphPath:@"me/friends"];
}
-(void)requestFriendAlbum:(NSArray*)lists{
    int i = 0;
    [self requestWithGraphPath:[NSString stringWithFormat:@"%@?fields=photos.fields(source,place,name)",[lists objectAtIndex:i]]];
//    for (int i = 0; i<[lists count]; i++) {
//        [self requestWithGraphPath:[NSString stringWithFormat:@"%@?fields=photos.fields(source,place,name)",[lists objectAtIndex:i]]];
//    }

}
-(void)requestFriendsPhoto:(NSArray*)fLists{
    for (int i = 0; i < [fLists count]; i++) {
        NSLog(@"%@",[fLists objectAtIndex:i]);

//        [self requestWithGraphPath:[NSString stringWithFormat:@"%@/picture?type=large",[fLists objectAtIndex:i]]];
//        [self requestWithGraphPath:[NSString stringWithFormat:@"501442114/picture?width=500&height=500",[fLists objectAtIndex:i]]];
    }

}

-(void)requestWithGraphPath:(NSString*)path{
    [self.facebook requestWithGraphPath:path andDelegate:self];
}
#pragma mark login - 
- (void)fbDidLogin {
    NSLog(@"login success");
    [defaults setObject:[facebook accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];

    if ([delegate respondsToSelector:@selector(facebookLoginSuccess)]) {
        [delegate facebookLoginSuccess];
    }
}
- (void) fbDidLogout {
    // Remove saved authorization information if it exists
    if ([defaults objectForKey:@"FBAccessTokenKey"]) {
        [defaults removeObjectForKey:@"FBAccessTokenKey"];
        [defaults removeObjectForKey:@"FBExpirationDateKey"];
        [defaults synchronize];
    }
}

- (void)fbDidNotLogin:(BOOL)cancelled{

}
- (void)fbDidExtendToken:(NSString*)accessToken
               expiresAt:(NSDate*)expiresAt{

}
- (void)fbSessionInvalidated{
    NSLog(@"fbSessionInvalidated");
}

#pragma mark - FBRequestDelegate
- (void)request:(FBRequest *)request didFailWithError:(NSError *)error{
	NSLog(@"request fail.  error: %@", error);
    if ([delegate respondsToSelector:@selector(facebookRequestFail)]) {
        [delegate facebookRequestFail];
    }
}

- (void)request:(FBRequest *)request didLoad:(id)result{
    NSLog(@"request finish");
    if ([delegate respondsToSelector:@selector(facebookRequestDidFinish:)]) {
        [delegate facebookRequestDidFinish:result];
    }

}



@end
