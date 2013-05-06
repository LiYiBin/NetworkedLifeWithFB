//
//  MainViewController.m
//  NetworkedLifeWithFB
//
//  Created by YiBin on 13/5/2.
//  Copyright (c) 2013年 YiBin. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    [[FacebookNetwork shareFacebook] login];
    
	// Do any additional setup after loading the view, typically from a nib.
    inMapView = YES;

    NSArray* nibObjs = [[NSBundle mainBundle] loadNibNamed:@"DetailView" owner:nil options:nil];
    detailView = [nibObjs lastObject];
    [self.view addSubview:detailView];
    
    nibObjs = [[NSBundle mainBundle] loadNibNamed:@"MapView" owner:nil options:nil];
    mapView = [nibObjs lastObject];
    [self.view addSubview:mapView];

    

    
}

-(IBAction)switchView:(UIBarButtonItem*)sender{
    inMapView = !inMapView;
    
    float  duration = 0.5f;
    if (inMapView) {
        [sender setTitle:@"路線"];
        [UIView transitionFromView:detailView toView:mapView  duration:duration options:UIViewAnimationOptionTransitionFlipFromLeft completion:nil];
    }else{
        [sender setTitle:@"地圖"];
        [UIView transitionFromView:mapView toView:detailView duration:duration options:UIViewAnimationOptionTransitionFlipFromRight completion:nil];
    }
    
}

@end
