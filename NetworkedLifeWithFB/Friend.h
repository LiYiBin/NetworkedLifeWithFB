//
//  Friend.h
//  NetworkedLifeWithFB
//
//  Created by YiBin on 13/5/14.
//  Copyright (c) 2013年 YiBin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Friend : NSManagedObject

@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * scoreOfLikes;
@property (nonatomic, retain) NSNumber * scoreOfCheckins;
@property (nonatomic, retain) NSNumber * sumOfScore;

@end
