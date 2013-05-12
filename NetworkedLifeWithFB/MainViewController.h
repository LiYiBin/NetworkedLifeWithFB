//
//  MainViewController.h
//  NetworkedLifeWithFB
//
//  Created by YiBin on 13/5/2.
//  Copyright (c) 2013年 YiBin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapView.h"
#import "DetailView.h"
#import "FacebookNetwork.h"

@interface MainViewController : UIViewController{
    BOOL    inMapView;
    
    MapView*    mapView;
    DetailView* detailView;
}

-(IBAction)switchView:(id)sender;

@end
