//
//  FacebookNetwork.h
//  petDog
//
//  Created by CANUOVRX on 12/12/11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FBConnect.h"

@protocol facebookDelegate <NSObject>

typedef enum facebookStateType{
    FacebookStateTypeMyCheckins,
    FacebookStateTypeMyLikes,
    FacebookStateTypeFriendList,
    FacebookStateTypeFriendCheckins,
    FacebookStateTypeFriendLikes,  
    FacebookStateTypeFriendAboutME,
}FacebookStateType;


@optional
-(void)facebookLoginSuccess;
-(void)facebookRequestDidFinish:(id)result;
-(void)facebookRequestFail;
@end


@interface FacebookNetwork : NSObject <FBSessionDelegate , FBRequestDelegate, FBDialogDelegate>{
    NSUserDefaults* defaults;
    FacebookStateType fbState;
}
@property(nonatomic,readwrite,assign)FacebookStateType fbState;
@property(nonatomic, readwrite, weak)id<facebookDelegate> delegate;
@property(nonatomic, readwrite, strong)Facebook*            facebook;
@property (nonatomic, assign) BOOL appUsageCheckEnabled;

+(FacebookNetwork*)shareFacebook;

-(void)login;

-(void)requestProfileInfo;
-(void)requestFriendInfo;
-(void)requestMyLike;
-(void)requestMyCheckins;
-(void)requestFriendLikeBYUID:(NSString*)uid;
-(void)requestFriendCheckinsBYUID:(NSString*)uid;

- (void)sendRequest:(NSArray *) targeted ;
-(void)requestWithGraphPath:(NSString*)path;
-(void)requestFriendAlbum:(NSArray*)lists;
-(void)requestFriendsPhoto:(NSArray*)fLists;
@end
