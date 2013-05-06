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
NSString * const kFacebookAppID = @"382862428455191";


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
@synthesize appUsageCheckEnabled;

-(id)init{
    self = [super init];
    if (self) {
        if (facebook == nil) {
            facebook = [[Facebook alloc] initWithAppId:kFacebookAppID andDelegate:self];
        }
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
    if ([facebook isSessionValid] == NO) {
        NSArray *permissions = [[NSArray alloc] initWithObjects:
                                @"user_about_me",	// 個人資訊
                                @"read_stream",		// 瀏覽塗鴉牆、修改閱讀權限..
                                @"publish_actions",	// 到別人牆上貼文
                                @"publish_stream",	// 到別人牆上貼文
                                @"email",
                                nil];
        [facebook authorize:permissions];
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
-(void)requestProfileInfo{
    //    [self requestWithGraphPath:@"me"];
    [self requestWithGraphPath:@"me?fields=friends.fields(picture)"];
}

-(void)requestFriendInfo{
    [self requestWithGraphPath:@"me/friends"];
}

-(void)requestWithGraphPath:(NSString*)path{
    [self.facebook requestWithGraphPath:path andDelegate:self];
}
#pragma mark login - 
- (void)fbDidLogin {
//    NSLog(@"login success");
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
