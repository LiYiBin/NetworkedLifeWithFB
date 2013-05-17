//
//  Cell.m
//  naivegrid
//
//  Created by Apirom Na Nakorn on 3/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Cell.h"
#import <QuartzCore/QuartzCore.h> 

@implementation Cell

@synthesize image;
@synthesize title;
@synthesize subtitle;

- (id)init {
    if (self = [super init]) {
		
		self.image.layer.cornerRadius = 10.0;
		self.image.layer.masksToBounds = YES;
		self.image.layer.borderColor = [UIColor clearColor].CGColor;
		self.image.layer.borderWidth = 1.0;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/


@end
