//
//  DetialViewController.m
//  NetworkedLifeWithFB
//
//  Created by yang on 13/5/18.
//  Copyright (c) 2013年 YiBin. All rights reserved.
//

#import "DetialViewController.h"
#import "Like.h"
#import "Checkin.h"

@interface DetialViewController ()<UITableViewDataSource,UITableViewDelegate>{
    NSMutableArray *likeName;
    NSMutableArray *checkinName;
    int type;  //0 = like   1 = checkin
}

@end

@implementation DetialViewController
@synthesize friends;
@synthesize user;
@synthesize headImage;
@synthesize table;
@synthesize label;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    type = 0;
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]]];
    
    [headImage loadRequestURL:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=square",friends.identifier] user_id:friends.identifier];
    
    likeName = [[NSMutableArray alloc]init];
    checkinName = [[NSMutableArray alloc]init];
    
    
    
    for (Like *friendLike in friends.likes) {
        for (Like *userLike in user.likes) {
            if ([friendLike.identifier isEqualToString:userLike.identifier]) {
                [likeName addObject:userLike.name];
            }
        }
    }
    
    for (Checkin *friendLike in friends.checkins) {
        for (Checkin *userLike in user.checkins) {
            if ([friendLike.identifier isEqualToString:userLike.identifier]) {
                [checkinName addObject:userLike.name];
            }
        }
    }
    
    label.text = [NSString stringWithFormat:@"你和 %@ 都喜歡的是",friends.name];
    [table setBackgroundColor:[UIColor clearColor]];
}


-(IBAction)btn_click:(id)sender{
    UIButton *btn = (UIButton*)sender;
    type = btn.tag;
    
    if (type == 0) {
        label.text = [NSString stringWithFormat:@"你和 %@ 都喜歡的是",friends.name];
    }else{
        label.text = [NSString stringWithFormat:@"你和 %@ 都去過",friends.name];
    }
    
    [table reloadData];
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (type == 0) {
        return [likeName count];
    }
    return [checkinName count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellD";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    [cell setBackgroundColor:[UIColor clearColor]];
    [cell setMultipleTouchEnabled:NO];
    cell.textLabel.font = [cell.textLabel.font fontWithSize:16];
    cell.textLabel.textColor = [UIColor blueColor];
    
    if (type == 0) {
        cell.textLabel.text = [likeName objectAtIndex:[indexPath row]];
    }else{
        cell.textLabel.text = [checkinName objectAtIndex:[indexPath row]];
        
    }

    return cell;
}


@end
