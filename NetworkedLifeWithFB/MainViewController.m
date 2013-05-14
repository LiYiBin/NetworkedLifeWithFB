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
    NSMutableDictionary *friendlikes;
    NSMutableDictionary *friendcheckins;
    NSMutableArray *mycheckins;
    NSMutableArray *mylikes;
    int getCount;
    
    int loadFriendLimit;
}

-(void)loadDataFinish;
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
    friendcheckins = [[NSMutableDictionary alloc] init];
    friendlikes = [[NSMutableDictionary alloc] init];
    mycheckins = [[NSMutableArray alloc] init];
    mylikes = [[NSMutableArray alloc] init];
    getCount = 0;
    
    loadFriendLimit = 10;
}

-(void)facebookLoginSuccess{
    NSLog(@"loginSuccess");
    [[FacebookNetwork shareFacebook]requestMyLike];
//    [[FacebookNetwork shareFacebook] requestFriendInfo];
}

-(void)facebookRequestDidFinish:(id)result{
    if ([FacebookNetwork shareFacebook].fbState == FacebookStateTypeMyLikes) {
        NSLog(@"getMyLikes");
        /*=================自己按贊資料============================*/
//        NSString *uid = [result objectForKey:@"id"];
        NSArray* data = [((NSDictionary*)[result objectForKey:@"likes"]) objectForKey:@"data"];
        for (NSDictionary *dic in data) {
            NSString *like_id = [dic objectForKey:@"id"];
            NSString *like_name = [dic objectForKey:@"name"];
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                                 like_id,@"like_id",
                                 like_name,@"like_name",nil];
            [mylikes addObject:dic];
        }
//        NSLog(@"mylikes%@",mylikes);
        [[FacebookNetwork shareFacebook] requestMyCheckins];
        
    }else if ([FacebookNetwork shareFacebook].fbState == FacebookStateTypeMyCheckins) {
        NSLog(@"getMyCheckins");
        /*=================自己打卡資料============================*/
            NSArray* data = [((NSDictionary*)[result objectForKey:@"checkins"]) objectForKey:@"data"];
            for (NSDictionary *dic in data) {
                
                NSDictionary *place = [dic objectForKey:@"place"];
                NSString *place_id = [place objectForKey:@"id"];
                NSString *place_name = [place objectForKey:@"name"];
                NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                                     place_id,@"place_id",
                                     place_name,@"place_name",nil];
                [mycheckins addObject:dic];
            }
//        NSLog(@"mycheckins%@",mycheckins);
            [[FacebookNetwork shareFacebook] requestFriendInfo];
    }else if ([FacebookNetwork shareFacebook].fbState == FacebookStateTypeFriendList) {
        /*=================朋友資料============================*/
        NSLog(@"getFriendData");
//        loadFriendLimit = 1;
        NSArray* data = [result objectForKey:@"data"];
        for (NSDictionary *friendID in data) {
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [friendID objectForKey:@"id"],@"id",
                                 [friendID objectForKey:@"name"],@"name", nil];
            [friendlist addObject:dic];
        }
        getCount = 0;
//        for (NSDictionary *dic in friendlist) {
        if (loadFriendLimit >[friendlist count]) {
            loadFriendLimit = [friendlist count];
        }
        for (int i=0 ; i<loadFriendLimit ;i++) {
            NSDictionary *dic = [friendlist objectAtIndex:i];
            [[FacebookNetwork shareFacebook] requestFriendLikeBYUID:[dic objectForKey:@"id"]];
        }
//        NSLog(@"friend :  %@",friendlist);
    }else if ([FacebookNetwork shareFacebook].fbState == FacebookStateTypeFriendLikes){
        /*=================朋友按贊資料============================*/
        getCount++;
        NSString *uid = [result objectForKey:@"id"];
        NSArray* data = [((NSDictionary*)[result objectForKey:@"likes"]) objectForKey:@"data"];
        NSMutableArray *like = [[NSMutableArray alloc] init];
        NSLog(@"likes-------%@-------",uid);
        for (NSDictionary *dic in data) {
            NSString *like_id = [dic objectForKey:@"id"];
            NSString *like_name = [dic objectForKey:@"name"];
//            NSLog(@"id:%@  name:%@",like_id,like_name);
            
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                                 like_id,@"like_id",
                                 like_name,@"like_name",nil];
            [like addObject:dic];
        }
        [friendlikes setObject:like forKey:uid];
//        if (getCount >= [friendlist count]) {
        
        if (getCount >= loadFriendLimit) {
            getCount = 0;
//            for (NSDictionary *dic in friendlist) {
//                [[FacebookNetwork shareFacebook] requestFriendCheckinsBYUID:[dic objectForKey:@"id"]];
//            }
            
            for (int i=0 ; i<loadFriendLimit ;i++) {
                NSDictionary *dic = [friendlist objectAtIndex:i];
                [[FacebookNetwork shareFacebook] requestFriendCheckinsBYUID:[dic objectForKey:@"id"]];
            }
        
        }
    }else if([FacebookNetwork shareFacebook].fbState == FacebookStateTypeFriendCheckins){
        getCount++;
        /*=================朋友打卡資料============================*/
        
        NSString *uid = [result objectForKey:@"id"];
        NSArray* data = [((NSDictionary*)[result objectForKey:@"checkins"]) objectForKey:@"data"];
        
        NSMutableArray *checkin = [[NSMutableArray alloc] init];
        NSLog(@"checkins-------%@-------",uid);
        for (NSDictionary *dic in data) {
            NSDictionary *place = [dic objectForKey:@"place"];
            NSString *place_id = [place objectForKey:@"id"];
            NSString *place_name = [place objectForKey:@"name"];
//            NSLog(@"placeid:%@  placename:%@",place_id,place_name);
            
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                                 place_id,@"place_id",
                                 place_name,@"place_name",nil];
            [checkin addObject:dic];
        }
        
        [friendcheckins setObject:checkin forKey:uid];
//        if (getCount >= [friendlist count]) {
        
        if (getCount >= loadFriendLimit) {
            getCount = 0;
            [self loadDataFinish];
        }
    }
}

-(void)loadDataFinish{
    NSLog(@"loadDataFinish");
    NSLog(@"friend :%@",friendlist);
    /* friendlist 是一個arry 存nsdictionary   key id是fb的id   name是人名*/
    NSLog(@"friendlike :%@",friendlikes);
    /* friendlikes 是一個nsmutabledictionary   
        用[friendlikes objectForKey:@"id"]  拿到一個存放id這個人的按贊紀錄array
        array裡面存nsdictionary   key like_id是按贊的id   like_name是按讚的名稱
     */
    NSLog(@"friendcheckin :%@",friendcheckins);
    /* friendcheckins 是一個nsmutabledictionary
     用[friendcheckins objectForKey:@"id"]  拿到一個存放id這個人的打卡紀錄array
     array裡面存nsdictionary   key place_id是打卡的id   place_name是打卡的名稱
     */
    
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
