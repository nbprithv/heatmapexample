//
//  LocationList.m
//  HeatMapExample2
//
//  Created by Niranjan Prithviraj on 8/19/14.
//  Copyright (c) 2014 Niranjan Prithviraj. All rights reserved.
//

#import "LocationList.h"

@interface LocationList (){
    NSMutableArray *locations;
    NSDictionary *placesList;
    NSArray *placesArr;
    UIActivityIndicatorView *indicator;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *currentAddrLabel;

@end

@implementation LocationList

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
    indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicator.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
    indicator.center = self.view.center;
    [self.view addSubview:indicator];
    [indicator bringSubviewToFront:self.view];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
    
    [indicator startAnimating];

    [super viewDidLoad];

    [self getCurrentLoc];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) getCurrentLoc {
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    if ([CLLocationManager locationServicesEnabled]) {
        NSLog(@"Location not allowedqqqqq");
    }
    [locationManager requestWhenInUseAuthorization];
    [locationManager requestAlwaysAuthorization];
    [locationManager startUpdatingLocation];
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"There was an error retrieving your location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [errorAlert show];
    NSLog(@"Error: %@",error.description);
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locs {
            NSLog(@"trying to get placesaaaaa");
    crnLoc = [locs lastObject];
    [self getPlaces:crnLoc];
    [locationManager stopUpdatingLocation];
    [self getCurrAddress:crnLoc];
}

- (void) getPlaces:(CLLocation*)currentLoc {
    NSLog(@"trying to get places");
        getPlacesAPI = [NSString stringWithFormat:@"http://ec2-54-68-50-228.us-west-2.compute.amazonaws.com:3000/place?action=get_places&currlat=%.8f&currlong=%.8f",currentLoc.coordinate.latitude,currentLoc.coordinate.longitude];
    NSLog(@"trying to get places");
    //getPlacesAPI = @"http://aqueous-caverns-8294.herokuapp.com/place?action=get_places&currlat=37.78735890&currlong=-122.40822700";
    NSURL *urlObj = [NSURL URLWithString:getPlacesAPI];
    
    [self getCurrentLoc];
    NSURLRequest *req = [NSURLRequest requestWithURL:urlObj];
    
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:req delegate:self];
    
    if (conn) {
        
    } else {
        
    }
}

- (void) getCurrAddress:(CLLocation*)currentLoc {
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:currentLoc completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *placemark = [placemarks objectAtIndex:0];
        if (error == nil && [placemarks count] > 0)
        {
            placemark = [placemarks lastObject];
            
            // strAdd -> take bydefault value nil
            NSString *strAdd = nil;
            
            if ([placemark.subThoroughfare length] != 0)
                strAdd = placemark.subThoroughfare;
            
            if ([placemark.thoroughfare length] != 0)
            {
                // strAdd -> store value of current location
                if ([strAdd length] != 0)
                    strAdd = [NSString stringWithFormat:@"%@, %@",strAdd,[placemark thoroughfare]];
                else
                {
                    // strAdd -> store only this value,which is not null
                    strAdd = placemark.thoroughfare;
                }
            }
            
            if ([placemark.postalCode length] != 0)
            {
                if ([strAdd length] != 0)
                    strAdd = [NSString stringWithFormat:@"%@, %@",strAdd,[placemark postalCode]];
                else
                    strAdd = placemark.postalCode;
            }
            
            if ([placemark.locality length] != 0)
            {
                if ([strAdd length] != 0)
                    strAdd = [NSString stringWithFormat:@"%@, %@",strAdd,[placemark locality]];
                else
                    strAdd = placemark.locality;
            }
            
            if ([placemark.administrativeArea length] != 0)
            {
                if ([strAdd length] != 0)
                    strAdd = [NSString stringWithFormat:@"%@, %@",strAdd,[placemark administrativeArea]];
                else
                    strAdd = placemark.administrativeArea;
            }
            
            if ([placemark.country length] != 0)
            {
                if ([strAdd length] != 0)
                    strAdd = [NSString stringWithFormat:@"%@, %@",strAdd,[placemark country]];
                else
                    strAdd = placemark.country;
            }
            NSString *alertMsg = [NSString stringWithFormat:@"Lat: %.8f Long: %.8f, Address: %@", currentLoc.coordinate.latitude, currentLoc.coordinate.longitude, strAdd];
            [self.currentAddrLabel setText:alertMsg];
        }
        
    }];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    placesList = [NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    placesArr = [placesList valueForKey:@"results"];
    
    [indicator stopAnimating];
    //NSLog(@"%@", placesArr);
    [self.tableView reloadData];
}

- (void)startStandardUpdates
{
    if (nil == locationManager)
        locationManager = [[CLLocationManager alloc] init];
    
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    
    // Set a movement threshold for new events.
    locationManager.distanceFilter = 50; // meters

    
    [locationManager startUpdatingLocation];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return placesArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    NSURL *imageURL = [NSURL URLWithString:[placesArr[indexPath.row] valueForKey:@"icon"]];
    NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
    UIImage *image = [UIImage imageWithData:imageData];
    //    UIImageView *cellImage = (UIImageView *)[cell.imageView viewWithTag:8];
    
    UIImageView *cellImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15,10,75,75)];
    cellImageView.tag = 8;
    cellImageView.image = image;
    [cell addSubview:cellImageView];
    
    
    NSString *cellText = [placesArr[indexPath.row] valueForKey:@"name"];
    NSString *cellDetailText = [NSString stringWithFormat:@"%@ mi",[placesArr[indexPath.row] valueForKey:@"distance_miles"]];
    
    NSString *cellAddressText = [placesArr[indexPath.row] valueForKey:@"address"];
    
    UILabel *locationName = (UILabel *)[cell.contentView viewWithTag:10];
    UILabel *locationDistance = (UILabel *)[cell.contentView viewWithTag:12];
    UILabel *locationAddress = (UILabel *)[cell.contentView viewWithTag:14];
    [locationName setText:cellText];
    [locationDistance setText:cellDetailText];
    [locationAddress setText:cellAddressText];
    
    return cell;
}


#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    ViewController *locationDetails = [segue destinationViewController];
    
    // Pass the selected object to the new view controller.
    NSIndexPath *path = [self.tableView indexPathForSelectedRow];
    Location *currentLoc = [[Location alloc] init];
    
    currentLoc.name = [placesArr[path.row] valueForKey:@"name"];
    currentLoc.address = [placesArr[path.row] valueForKey:@"address"];
    currentLoc.longitude = [placesArr[path.row] valueForKey:@"longitude"];
    currentLoc.latitude = [placesArr[path.row] valueForKey:@"latitude"];
    currentLoc.icon = [placesArr[path.row] valueForKey:@"icon"];
    currentLoc.userLocation = crnLoc;
    
    [locationDetails setCurrentLocation:currentLoc];
}


@end
