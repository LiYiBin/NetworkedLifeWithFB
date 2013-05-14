//
//  MainViewController.m
//  NetworkedLifeWithFB
//
//  Created by YiBin on 13/5/2.
//  Copyright (c) 2013年 YiBin. All rights reserved.
//

#import "MainViewController.h"
#import <MapKit/MapKit.h>
#import "FacebookNetwork.h"

@interface MainViewController () <facebookDelegate,MKMapViewDelegate>{
    NSMutableArray *friendlist;
}

@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [FacebookNetwork shareFacebook].delegate = self;
    [[FacebookNetwork shareFacebook] login];
    friendlist = [[NSMutableArray alloc] init];
}

-(void)facebookLoginSuccess{
//    NSLog(@"loginSuccess");
//    [[FacebookNetwork shareFacebook]requestMyLike];
    [[FacebookNetwork shareFacebook] requestFriendInfo];
}

#pragma mark - facebookDelegate

-(void)facebookRequestDidFinish:(id)result{
    NSLog(@"%@",result);
    if ([FacebookNetwork shareFacebook].fbState == FacebookStateTypeFriendList) {
        int loadFriendLimit = 1;
        NSArray* data = [result objectForKey:@"data"];
        NSDictionary* friendID = nil;
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        
        NSString* name = nil;
        for (int i = 0; i< loadFriendLimit; i++) {
            friendID = [data objectAtIndex:i];
            [friendlist addObject:[friendID objectForKey:@"id"]];
            
            [[FacebookNetwork shareFacebook] requestFriendCheckinsBYUID:[friendID objectForKey:@"id"]];
            name = [friendID objectForKey:@"name"];
//            [defaults setObject:name forKey:[NSString stringWithFormat:@"FB%dname",i]];
        }
//        [defaults synchronize];
        
    } else if ([FacebookNetwork shareFacebook].fbState == FacebookStateTypeFriendLikes){
        NSString *uid = [result objectForKey:@"id"];
        NSArray* data = [((NSDictionary*)[result objectForKey:@"likes"]) objectForKey:@"data"];
        
        NSLog(@"likes-------%@-------",uid);
        for (NSDictionary *dic in data) {
            NSString *like_id = [dic objectForKey:@"id"];
            NSString *like_name = [dic objectForKey:@"name"];
            NSLog(@"id:%@  name:%@",like_id,like_name);
        }
    } else if([FacebookNetwork shareFacebook].fbState == FacebookStateTypeFriendCheckins){
        
        NSString *uid = [result objectForKey:@"id"];
        NSArray* data = [((NSDictionary*)[result objectForKey:@"checkins"]) objectForKey:@"data"];
        
        NSLog(@"checkins-------%@-------",uid);
        for (NSDictionary *dic in data) {
            NSDictionary *place = [dic objectForKey:@"place"];
            NSString *place_id = [place objectForKey:@"id"];
            NSString *place_name = [place objectForKey:@"name"];
            NSLog(@"placeid:%@  placename:%@",place_id,place_name);
        }
    }
}

@end
