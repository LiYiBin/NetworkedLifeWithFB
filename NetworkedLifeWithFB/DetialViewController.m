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
#import <Social/Social.h>
#import <QuartzCore/QuartzCore.h>

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
    
    likeName = [[NSMutableArray alloc]init];
    checkinName = [[NSMutableArray alloc]init];
    
    
    [like.layer setCornerRadius:3.0];
    [like.layer setShadowColor:[UIColor blackColor].CGColor];
    [like.layer setShadowOpacity:1.0];
    [like.layer setShadowOffset:CGSizeMake(1, 1)];
    
    [location.layer setCornerRadius:3.0];
    [location.layer setShadowColor:[UIColor blackColor].CGColor];
    [location.layer setShadowOpacity:1.0];
    [location.layer setShadowOffset:CGSizeMake(1, 1)];
    
    
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
    
    
    NSString* path = [NSTemporaryDirectory() stringByAppendingFormat:@"%@%@.jpg",@"FBPhoto:",friends.identifier];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        headImage.image = [UIImage imageWithContentsOfFile:path];
        [headImage resetShadow];
        [[headImage layer] setShadowOffset:CGSizeMake(1.0, 1.0)];
        [[headImage layer] setShadowOpacity:1.0];
        [[headImage layer] setShadowColor:[UIColor blackColor].CGColor];
    }
    
    self.title = self.friends.name;
}


-(IBAction)btn_click:(id)sender{
    UIButton *btn = (UIButton*)sender;
    type = btn.tag;
    
    if (type == 0) {
        _checkInButton.alpha = 0.0;
        _checkInButton.enabled = NO;
        
        label.text = [NSString stringWithFormat:@"你和 %@ 都喜歡的是",friends.name];
    }else{

        [UIView  animateWithDuration:0.5f animations:^(void){
            if ([checkinName count] == 0) {
                //尚未有交流
                _checkInButton.alpha = 1.0;
                label.text = [NSString stringWithFormat:@"你和 %@ 尚未有交流 ,立即打卡吧",friends.name];
            }else{
                _checkInButton.alpha = 0.0;
                label.text = [NSString stringWithFormat:@"你和 %@ 都去過",friends.name];
            }
        } completion:^(BOOL finsih){
            if ([checkinName count] == 0) {
                //尚未有交流
                _checkInButton.enabled = YES;
            }else{
                _checkInButton.enabled = NO;
            }
        }];

    }
    UIButton* icon = sender;
    [UIView animateWithDuration:0.3f animations:^(void){
        CGAffineTransform scale = CGAffineTransformMakeScale(1.2f, 1.2f);
        icon.transform = scale;
        [UIView animateWithDuration:0.3f animations:^(void){
            icon.transform = CGAffineTransformMakeScale(1.0f, 1.0f);;
        }];
    }];


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

-(IBAction)CheckIn:(id)sender{
    SLComposeViewController *composer = [SLComposeViewController
                                         composeViewControllerForServiceType:SLServiceTypeFacebook];
    [composer setCompletionHandler:^(SLComposeViewControllerResult result) {
        //        [self dismissViewControllerAnimated:YES completion:^{
        //
        //        }];
    }];
    [composer setInitialText:[NSString stringWithFormat:@"我跟 %@ 在台科大上課噢",friends.name]];
//    [composer addImage:self.shareImage];
    [self presentViewController:composer animated:YES completion:NULL];
}


@end
