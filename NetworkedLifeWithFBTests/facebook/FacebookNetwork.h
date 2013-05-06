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

@optional
-(void)facebookLoginSuccess;
-(void)facebookRequestDidFinish:(id)result;
-(void)facebookRequestFail;
@end


@interface FacebookNetwork : NSObject <FBSessionDelegate , FBRequestDelegate, FBDialogDelegate>{
    NSUserDefaults* defaults;
}
@property(nonatomic, readwrite, assign)id<facebookDelegate> delegate;
@property(nonatomic, readwrite, retain)Facebook*            facebook;
@property (nonatomic, assign) BOOL appUsageCheckEnabled;

+(FacebookNetwork*)shareFacebook;

-(void)login;

-(void)requestProfileInfo;
-(void)requestFriendInfo;

- (void)sendRequest:(NSArray *) targeted ;
-(void)requestWithGraphPath:(NSString*)path;
@end
