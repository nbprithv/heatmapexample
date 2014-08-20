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
