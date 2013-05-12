//
//  CustomAnnotation.m
//  NetworkedLifeWithFB
//
//  Created by YiBin on 13/5/12.
//  Copyright (c) 2013年 YiBin. All rights reserved.
//

#import "CustomAnnotation.h"

@interface CustomAnnotation ()

@property (nonatomic) CLLocationCoordinate2D coordinate;

@end

@implementation CustomAnnotation

- (id)initWithLocation:(CLLocationCoordinate2D)coord {
    self = [super init];
    if (self) {
        _coordinate = coord;
    }
    return self;
}

@end
