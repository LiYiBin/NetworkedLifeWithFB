//
//  DetialViewController.h
//  NetworkedLifeWithFB
//
//  Created by yang on 13/5/18.
//  Copyright (c) 2013年 YiBin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Friend.h"
#import "User.h"
#import "MoPhotograph.h"

@interface DetialViewController : UIViewController{
    IBOutlet UIButton*  like;
    IBOutlet UIButton*  location;
}

@property(nonatomic,readwrite,retain)Friend *friends;
@property(nonatomic,readwrite,retain)User *user;
@property(nonatomic,readwrite,retain)IBOutlet MoPhotograph *headImage;
@property(nonatomic,readwrite,retain)IBOutlet UITableView *table;
@property(nonatomic,readwrite,retain)IBOutlet UILabel *label;
@property(nonatomic,readwrite,retain)IBOutlet UIButton* checkInButton;

-(IBAction)btn_click:(id)sender;

-(IBAction)CheckIn:(id)sender;
@end
