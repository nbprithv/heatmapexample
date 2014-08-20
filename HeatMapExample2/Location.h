//
//  Location.h
//  Mapthem
//
//  Created by Niranjan Prithviraj on 8/19/14.
//  Copyright (c) 2014 Niranjan Prithviraj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface Location : NSObject

@property (nonatomic) NSString *icon;
@property (nonatomic) NSString *latitude;
@property (nonatomic) NSString *longitude;
@property (nonatomic) NSString *address;
@property (nonatomic) NSString *name;
@property (nonatomic) CLLocation *userLocation;

@end
