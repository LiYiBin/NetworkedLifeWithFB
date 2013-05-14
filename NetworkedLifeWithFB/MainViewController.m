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
#import "DetailLocationViewController.h"
#import "FacebookNetwork.h"

@interface MainViewController () <facebookDelegate,MKMapViewDelegate>{
    NSMutableArray *friendlist;
}

@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view, typically from a nib.
    inMapView = YES;

    NSArray* nibObjs = [[NSBundle mainBundle] loadNibNamed:@"DetailView" owner:nil options:nil];
    detailView = [nibObjs lastObject];
    [self.view addSubview:detailView];
    
    nibObjs = [[NSBundle mainBundle] loadNibNamed:@"MapView" owner:nil options:nil];
    mapView = [nibObjs lastObject];
    [self.view addSubview:mapView];
    
    mapView.map.delegate = self;
    
    [FacebookNetwork shareFacebook].delegate = self;
    [[FacebookNetwork shareFacebook] login];
    friendlist = [[NSMutableArray alloc] init];
}

-(void)facebookLoginSuccess{
//    NSLog(@"loginSuccess");
//    [[FacebookNetwork shareFacebook]requestMyLike];
    [[FacebookNetwork shareFacebook] requestFriendInfo];
}

-(void)facebookRequestDidFinish:(id)result{
//    NSLog(@"%@",result);
    if ([FacebookNetwork shareFacebook].fbState == FacebookStateTypeFriendList) {
        int loadFriendLimit = 10;
        NSArray* data = [result objectForKey:@"data"];
        NSDictionary* friendID = nil;
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        
        NSString* name = nil;
        for (int i = 0; i< loadFriendLimit; i++) {
            friendID = [data objectAtIndex:i];
            [friendlist addObject:[friendID objectForKey:@"id"]];
            
            [[FacebookNetwork shareFacebook] requestFriendCheckinsBYUID:[friendID objectForKey:@"id"]];
            name = [friendID objectForKey:@"name"];
//            [defaults setObject:name forKey:[NSString stringWithFormat:@"FB%dname",i]];
        }
//        [defaults synchronize];
        
    }else if ([FacebookNetwork shareFacebook].fbState == FacebookStateTypeFriendLikes){
        NSString *uid = [result objectForKey:@"id"];
        NSArray* data = [((NSDictionary*)[result objectForKey:@"likes"]) objectForKey:@"data"];
        
        NSLog(@"likes-------%@-------",uid);
        for (NSDictionary *dic in data) {
            NSString *like_id = [dic objectForKey:@"id"];
            NSString *like_name = [dic objectForKey:@"name"];
            NSLog(@"id:%@  name:%@",like_id,like_name);
        }
    }else if([FacebookNetwork shareFacebook].fbState == FacebookStateTypeFriendCheckins){
        
        NSString *uid = [result objectForKey:@"id"];
        NSArray* data = [((NSDictionary*)[result objectForKey:@"checkins"]) objectForKey:@"data"];
        
        NSLog(@"checkins-------%@-------",uid);
        for (NSDictionary *dic in data) {
            NSDictionary *place = [dic objectForKey:@"place"];
            NSString *place_id = [place objectForKey:@"id"];
            NSString *place_name = [place objectForKey:@"name"];
            NSLog(@"placeid:%@  placename:%@",place_id,place_name);
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Test addCustomAnnotion
    [self addCustomAnnotion:CLLocationCoordinate2DMake(23.855698,120.893555) withTitle:@"Title" subtitle:@"subtitle"];
    // Test setCenterCoordinateOfMapViewWithAddress
    [self setCenterCoordinateOfMapViewWithAddress:@"Taipei" animated:YES];
    
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

- (void)addCustomAnnotion:(CLLocationCoordinate2D)coor withTitle:(NSString *)title subtitle:(NSString *)subtitle
{
    CustomAnnotation *annotation = [[CustomAnnotation alloc] initWithLocation:coor];
    annotation.title = title;
    annotation.subtitle = subtitle;
    
    [mapView.map addAnnotation:annotation];
}

- (void)setCenterCoordinateOfMapViewWithLocation:(CLLocationCoordinate2D)coor animated:(BOOL)animated
{
    [mapView.map setCenterCoordinate:coor animated:animated];
}

- (void)setCenterCoordinateOfMapViewWithAddress:(NSString *)address animated:(BOOL)animated
{
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    [geocoder geocodeAddressString:address completionHandler:^(NSArray *placemarks, NSError *error) {
        
        if (placemarks.count > 0) {
            CLPlacemark *placemark = placemarks[0];
            
            CLLocationCoordinate2D coor = placemark.location.coordinate;
            
            [mapView.map setCenterCoordinate:coor animated:animated];
        }
        else {
            NSLog(@"Can't find address: %@", address);
        }
    }];
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    UIStoryboard *main = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    DetailLocationViewController *viewController = [main instantiateViewControllerWithIdentifier:@"DetailLocationViewController"];
    viewController.title = [view.annotation title];
    
    [self.navigationController pushViewController:viewController animated:YES];
}

// It can show a custom annotation view
//- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
//{
//    MKAnnotationView* aView = [[MKAnnotationView alloc] initWithAnnotation:annotation
//                                                            reuseIdentifier:@"MyCustomAnnotation"];
//    aView.image = [UIImage imageNamed:@"myimage.png"];
//    aView.centerOffset = CGPointMake(10, -20);
//    
//    return aView;
//}

@end
