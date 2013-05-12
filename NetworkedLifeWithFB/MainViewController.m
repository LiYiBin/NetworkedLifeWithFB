//
//  MainViewController.m
//  NetworkedLifeWithFB
//
//  Created by YiBin on 13/5/2.
//  Copyright (c) 2013年 YiBin. All rights reserved.
//

#import "MainViewController.h"
#import <MapKit/MapKit.h>
#import "CustomAnnotation.h"

@interface MainViewController () <MKMapViewDelegate>

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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Test Add annotation method
    CustomAnnotation *annotation = [[CustomAnnotation alloc] initWithLocation:CLLocationCoordinate2DMake(23.855698,120.893555)];
    annotation.title = @"Title";
    annotation.subtitle = @"This is subtitle";
    [self addCustomAnnotion:annotation];
    
    [mapView.map setCenterCoordinate:CLLocationCoordinate2DMake(23.855698,120.893555)];
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

#pragma mark - Custom MapView Methods

- (void)addCustomAnnotion:(CustomAnnotation *)annotation
{
    [mapView.map addAnnotation:annotation];
}

#pragma mark - MKMapViewDelegate

// It can show a custom annotation view
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKAnnotationView* aView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                            reuseIdentifier:@"MyCustomAnnotation"];
    aView.image = [UIImage imageNamed:@"myimage.png"];
    aView.centerOffset = CGPointMake(10, -20);
    
    return aView;
}

@end
