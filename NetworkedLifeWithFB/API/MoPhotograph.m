//
//  MoPhotograph.m
//  Record
//
//  Created by CANUOVRX on 12/12/8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MoPhotograph.h"
#import <QuartzCore/QuartzCore.h>

@implementation MoPhotograph
@synthesize photoSize;

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {

    }
    return self;
}

-(void)loadRequestURL:(NSString*)url user_id:(NSString*)uid{
    self.image = nil;
    [self resetShadow];
    
    photoSize = MoPhotographSize180x180;
    

    uid_ = [NSString stringWithFormat:@"%@",uid];
    
    NSString* path = [NSTemporaryDirectory() stringByAppendingFormat:@"%@%@.jpg",@"FBPhoto:",uid_];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [self setImage:[UIImage imageWithContentsOfFile:path]];
    }else {
        if (url) {

            ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
            request.delegate = self;
            [request setDownloadDestinationPath:path];
            [request startAsynchronous];
            /*
            activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            [activity setFrame:CGRectMake(0, 0, 50, 50)];
            [self addSubview:activity];
            
            [activity startAnimating];
            */
        }
    }
}

/*
-(void)requestFailed:(ASIHTTPRequest *)request{
    [activity stopAnimating];
    [activity removeFromSuperview];
    [activity release];
    activity = nil;
}
 */
-(void)resetShadow{
    [self.layer setCornerRadius:5];

}

-(void)requestFinished:(ASIHTTPRequest *)request{
//    [activity stopAnimating];
//    [activity removeFromSuperview];
//    [activity release];
//    activity = nil;
    
    NSString* path = [NSTemporaryDirectory() stringByAppendingFormat:@"FBPhoto:%@.jpg",uid_];
    UIImage* image = [UIImage imageWithContentsOfFile:path];
    [self setImage:image];
}

@end
