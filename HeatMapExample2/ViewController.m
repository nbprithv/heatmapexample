//
//  ViewController.m
//  HeatMapExample2
//
//  Created by Niranjan Prithviraj on 8/19/14.
//  Copyright (c) 2014 Niranjan Prithviraj. All rights reserved.
//

#import "ViewController.h"
#import "parseCSV.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *locationName;
@property (weak, nonatomic) IBOutlet UILabel *locationAddr;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak,nonatomic) CLLocation *currentUserLocation;
- (NSDictionary *)heatMapData;

@end

@implementation ViewController

@synthesize mapView = _mapView;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.mapView.delegate = self;
    
    HeatMap *hm = [[HeatMap alloc] initWithData:[self heatMapData]];
    [self.mapView addOverlay:hm];
    [self.mapView setVisibleMapRect:[hm boundingMapRect] animated:YES];
    
    
    self.locationName.text = self.currentLocation.name;
    self.locationAddr.text = self.currentLocation.address;
    
    
    NSString *location = self.currentLocation.address;
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:location
                 completionHandler:^(NSArray* placemarks, NSError* error){
                     if (placemarks && placemarks.count > 0) {
                         CLPlacemark *topResult = [placemarks objectAtIndex:0];
                         MKPlacemark *placemark = [[MKPlacemark alloc] initWithPlacemark:topResult];
                         
                         CLLocationCoordinate2D noLocation;
                         MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(noLocation, 50000, 50000);
                         MKCoordinateRegion region = [self.mapView regionThatFits:viewRegion];
                         region.center = placemark.region.center;
                         region.span.longitudeDelta /= 8.0;
                         region.span.latitudeDelta /= 8.0;
                         
                         [self.mapView setRegion:region animated:YES];
                         [self.mapView addAnnotation:placemark];
                     }
                 }
     ];
    
    
    
    
}

- (NSDictionary *)heatMapData
{
    CSVParser *parser = [CSVParser new];
    NSString *csvFilePath = [[NSBundle mainBundle] pathForResource:@"Breweries_clean" ofType:@"csv"];
    [parser openFile:csvFilePath];
    NSArray *csvContent = [parser parseFile];
    
    NSMutableDictionary *toRet = [[NSMutableDictionary alloc] initWithCapacity:[csvContent count]];
    
    for (NSArray *line in csvContent) {
        
        MKMapPoint point = MKMapPointForCoordinate(
                                                   CLLocationCoordinate2DMake([[line objectAtIndex:1] doubleValue],
                                                                              [[line objectAtIndex:0] doubleValue]));
        
        NSValue *pointValue = [NSValue value:&point withObjCType:@encode(MKMapPoint)];
        [toRet setObject:[NSNumber numberWithInt:1] forKey:pointValue];
    }
    
    return toRet;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark -
#pragma mark MKMapViewDelegate

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    return [[HeatMapView alloc] initWithOverlay:overlay];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
