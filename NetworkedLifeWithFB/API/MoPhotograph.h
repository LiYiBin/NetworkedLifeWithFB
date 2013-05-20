//
//  MoPhotograph.h
//  Record
//
//  Created by CANUOVRX on 12/12/8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
typedef enum {
    MoPhotographSize48x48,//twitter
    MoPhotographSize50x50,//sinaweibo, facebook
    MoPhotographSize73x73,//twitter
    MoPhotographSize100x100,//facebook
    MoPhotographSize180x180,//sinaweibo
}MoPhotographSize;

@interface MoPhotograph : UIImageView <ASIHTTPRequestDelegate>{
//    UIActivityIndicatorView* activity;
    NSString*                uid_;
}
@property(nonatomic, readwrite, assign)MoPhotographSize photoSize;

-(void)loadRequestURL:(NSString*)url user_id:(NSString*)uid;
-(void)resetShadow;
@end
