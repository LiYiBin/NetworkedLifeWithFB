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

-(void)loadRequestURL:(NSString*)url user_id:(NSString*)uid{

    photoSize = MoPhotographSize180x180;
    
    [self.layer setCornerRadius:5];
    [self.layer setShadowColor:[UIColor blackColor].CGColor];
    [[self layer] setShadowOpacity:0.7f];
    [[self layer] setShadowOffset:CGSizeMake(1.0, 1.0)];
    [self.layer setShadowRadius:5];
    
    
    [[self layer] setShadowPath:[UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:5].CGPath];
    
    [self setClipsToBounds:YES];
//    [self.layer setMasksToBounds:YES];
//    uid_ = [NSString stringWithString:uid];
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
