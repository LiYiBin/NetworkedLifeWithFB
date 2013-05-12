//
//  CustomAnnotation.h
//  NetworkedLifeWithFB
//
//  Created by YiBin on 13/5/12.
//  Copyright (c) 2013年 YiBin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface CustomAnnotation : NSObject <MKAnnotation>

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *subtitle;

- (id)initWithLocation:(CLLocationCoordinate2D)coord;

@end
