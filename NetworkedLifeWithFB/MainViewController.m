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
    NSMutableDictionary *friendlikes;
    NSMutableDictionary *friendcheckins;
    NSMutableArray *mycheckins;
    NSMutableArray *mylikes;
    int getCount;
    
    int loadFriendLimit;
}

-(void)loadDataFinish;
@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [FacebookNetwork shareFacebook].delegate = self;
    [[FacebookNetwork shareFacebook] login];
    friendlist = [[NSMutableArray alloc] init];
    friendcheckins = [[NSMutableDictionary alloc] init];
    friendlikes = [[NSMutableDictionary alloc] init];
    mycheckins = [[NSMutableArray alloc] init];
    mylikes = [[NSMutableArray alloc] init];
    getCount = 0;
    
    loadFriendLimit = 10;
}

-(void)facebookLoginSuccess{
    NSLog(@"loginSuccess");
    [[FacebookNetwork shareFacebook]requestMyLike];
//    [[FacebookNetwork shareFacebook] requestFriendInfo];
}

#pragma mark - facebookDelegate

-(void)facebookRequestDidFinish:(id)result{
    if ([FacebookNetwork shareFacebook].fbState == FacebookStateTypeMyLikes) {
        NSLog(@"getMyLikes");
        /*=================自己按贊資料============================*/
//        NSString *uid = [result objectForKey:@"id"];
        NSArray* data = [((NSDictionary*)[result objectForKey:@"likes"]) objectForKey:@"data"];
        for (NSDictionary *dic in data) {
            NSString *like_id = [dic objectForKey:@"id"];
            NSString *like_name = [dic objectForKey:@"name"];
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                                 like_id,@"like_id",
                                 like_name,@"like_name",nil];
            [mylikes addObject:dic];
        }
//        NSLog(@"mylikes%@",mylikes);
        [[FacebookNetwork shareFacebook] requestMyCheckins];
        
    }else if ([FacebookNetwork shareFacebook].fbState == FacebookStateTypeMyCheckins) {
        NSLog(@"getMyCheckins");
        /*=================自己打卡資料============================*/
            NSArray* data = [((NSDictionary*)[result objectForKey:@"checkins"]) objectForKey:@"data"];
            for (NSDictionary *dic in data) {
                
                NSDictionary *place = [dic objectForKey:@"place"];
                NSString *place_id = [place objectForKey:@"id"];
                NSString *place_name = [place objectForKey:@"name"];
                NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                                     place_id,@"place_id",
                                     place_name,@"place_name",nil];
                [mycheckins addObject:dic];
            }
//        NSLog(@"mycheckins%@",mycheckins);
            [[FacebookNetwork shareFacebook] requestFriendInfo];
    }else if ([FacebookNetwork shareFacebook].fbState == FacebookStateTypeFriendList) {
        /*=================朋友資料============================*/
        NSLog(@"getFriendData");
//        loadFriendLimit = 1;
        NSArray* data = [result objectForKey:@"data"];
        for (NSDictionary *friendID in data) {
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [friendID objectForKey:@"id"],@"id",
                                 [friendID objectForKey:@"name"],@"name", nil];
            [friendlist addObject:dic];
        }
        getCount = 0;
//        for (NSDictionary *dic in friendlist) {
        if (loadFriendLimit >[friendlist count]) {
            loadFriendLimit = [friendlist count];
        }
        for (int i=0 ; i<loadFriendLimit ;i++) {
            NSDictionary *dic = [friendlist objectAtIndex:i];
            [[FacebookNetwork shareFacebook] requestFriendLikeBYUID:[dic objectForKey:@"id"]];
        }
//        NSLog(@"friend :  %@",friendlist);
    }else if ([FacebookNetwork shareFacebook].fbState == FacebookStateTypeFriendLikes){
        /*=================朋友按贊資料============================*/
        getCount++;
        NSString *uid = [result objectForKey:@"id"];
        NSArray* data = [((NSDictionary*)[result objectForKey:@"likes"]) objectForKey:@"data"];
        NSMutableArray *like = [[NSMutableArray alloc] init];
        NSLog(@"likes-------%@-------",uid);
        for (NSDictionary *dic in data) {
            NSString *like_id = [dic objectForKey:@"id"];
            NSString *like_name = [dic objectForKey:@"name"];
//            NSLog(@"id:%@  name:%@",like_id,like_name);
            
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                                 like_id,@"like_id",
                                 like_name,@"like_name",nil];
            [like addObject:dic];
        }
        [friendlikes setObject:like forKey:uid];
//        if (getCount >= [friendlist count]) {
        
        if (getCount >= loadFriendLimit) {
            getCount = 0;
//            for (NSDictionary *dic in friendlist) {
//                [[FacebookNetwork shareFacebook] requestFriendCheckinsBYUID:[dic objectForKey:@"id"]];
//            }
            
            for (int i=0 ; i<loadFriendLimit ;i++) {
                NSDictionary *dic = [friendlist objectAtIndex:i];
                [[FacebookNetwork shareFacebook] requestFriendCheckinsBYUID:[dic objectForKey:@"id"]];
            }
        
        }
    }else if([FacebookNetwork shareFacebook].fbState == FacebookStateTypeFriendCheckins){
        getCount++;
        /*=================朋友打卡資料============================*/
        
        NSString *uid = [result objectForKey:@"id"];
        NSArray* data = [((NSDictionary*)[result objectForKey:@"checkins"]) objectForKey:@"data"];
        
        NSMutableArray *checkin = [[NSMutableArray alloc] init];
        NSLog(@"checkins-------%@-------",uid);
        for (NSDictionary *dic in data) {
            NSDictionary *place = [dic objectForKey:@"place"];
            NSString *place_id = [place objectForKey:@"id"];
            NSString *place_name = [place objectForKey:@"name"];
//            NSLog(@"placeid:%@  placename:%@",place_id,place_name);
            
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                                 place_id,@"place_id",
                                 place_name,@"place_name",nil];
            [checkin addObject:dic];
        }
        
        [friendcheckins setObject:checkin forKey:uid];
//        if (getCount >= [friendlist count]) {
        
        if (getCount >= loadFriendLimit) {
            getCount = 0;
            [self loadDataFinish];
        }
    }
}

-(void)loadDataFinish{
    NSLog(@"loadDataFinish");
    NSLog(@"friend :%@",friendlist);
    /* friendlist 是一個arry 存nsdictionary   key id是fb的id   name是人名*/
    NSLog(@"friendlike :%@",friendlikes);
    /* friendlikes 是一個nsmutabledictionary   
        用[friendlikes objectForKey:@"id"]  拿到一個存放id這個人的按贊紀錄array
        array裡面存nsdictionary   key like_id是按贊的id   like_name是按讚的名稱
     */
    NSLog(@"friendcheckin :%@",friendcheckins);
    /* friendcheckins 是一個nsmutabledictionary
     用[friendcheckins objectForKey:@"id"]  拿到一個存放id這個人的打卡紀錄array
     array裡面存nsdictionary   key place_id是打卡的id   place_name是打卡的名稱
     */
    
}

@end
