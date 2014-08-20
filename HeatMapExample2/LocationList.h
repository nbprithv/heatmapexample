//
//  LocationList.h
//  HeatMapExample2
//
//  Created by Niranjan Prithviraj on 8/19/14.
//  Copyright (c) 2014 Niranjan Prithviraj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "ViewController.h"

@interface LocationList : UIViewController <UITableViewDataSource, UITableViewDelegate, UIApplicationDelegate, CLLocationManagerDelegate> {
    NSString *response;
    NSString *getPlacesAPI;
    CLLocationManager *locationManager;
    CLLocation *crnLoc;
}

@end
