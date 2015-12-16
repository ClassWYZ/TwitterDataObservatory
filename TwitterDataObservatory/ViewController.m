//
//  ViewController.m
//  TwitterDataObservatory
//
//  Created by Wenyu Zhang on 11/27/15.
//  Copyright (c) 2015 Wenyu Zhang. All rights reserved.
//

#import "ViewController.h"
#import "Pin.h"
#import "TweetAnnotation.h"
#import <float.h>
@import Twitter;
@import Social;
@import Accounts;

@interface ViewController ()

@property (nonatomic, strong) NSURLConnection *twitterConnection;
@property (strong, nonatomic) CLLocationManager *manager;
@property (assign, nonatomic) NSInteger pinCounter;

@end

@implementation ViewController

NSString* const sentimentEngine = @"http://www.sentiment140.com/api/bulkClassifyJson?appid=wyzhang8@outlook.com";

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.manager requestAlwaysAuthorization];
    self.pinCounter = 0;
    self.mapView.delegate = self;
    //[self startLocations];
    CLLocationCoordinate2D sampleCoordinate = CLLocationCoordinate2DMake(40.7903, -73.9597);
    //MKPointAnnotation *sampleAnnotation = [[MKPointAnnotation alloc] init];
    TweetAnnotation *sampleAnnotation = [[TweetAnnotation alloc] initWithCoordinate:sampleCoordinate withPolarity:4];
    NSMutableArray *sampleAnnotations = [[NSMutableArray alloc] init];
    [sampleAnnotations addObject:sampleAnnotation];
    sampleAnnotation.coordinate = sampleCoordinate;
    //dispatch_async(dispatch_get_main_queue(), ^{
        [self.mapView addAnnotations:sampleAnnotations];
    //});
    MKCoordinateRegion region;
    region.center = sampleCoordinate;
    region.span.latitudeDelta = 0.01;
    region.span.longitudeDelta = 0.01;
    
    [self.mapView setRegion:region animated:YES];
    NSLog(@"aa");
    // Do any additional setup after loading the view, typically from a nib.
    //self.label.text = [NSString stringWithFormat:@"success!"];
    //self.mainLabel.text = [NSString stringWithFormat:@"success!"];
    //First, we need to obtain the account instance for the user's Twitter account
    ACAccountStore *store = [[ACAccountStore alloc] init];
    ACAccountType *twitterAccountType = [store accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    //  Request permission from the user to access the available Twitter accounts
    [store requestAccessToAccountsWithType:twitterAccountType
                     withCompletionHandler:^(BOOL granted, NSError *error) {
                         if (!granted) {
                             // The user rejected your request
                             NSLog(@"User rejected access to the account.");
                         }
                         else {
                             // Grab the available accounts
                             NSArray *twitterAccounts = [store accountsWithAccountType:twitterAccountType];
                             if ([twitterAccounts count] > 0) {
                                 // Use the first account for simplicity
                                 ACAccount *account = [twitterAccounts objectAtIndex:0];
                                 NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
                                 [params setObject:@"" forKey:@"q"];
                                 [params setObject:@"40.7903,-73.9597,10mi" forKey:@"geocode"];
                                 [params setObject:@"100" forKey:@"count"];
                                 //set any other criteria to track
                                 //params setObject:@"words, to, track" forKey@"track"];
                                 
                                 //  The endpoint that we wish to call
                                 NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/search/tweets.json"];
                                 
                                 //  Build the request with our parameter
                                 SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                                         requestMethod:SLRequestMethodGET
                                                                                   URL:url
                                                                            parameters:params];
                                 // Attach the account object to this request
                                 [request setAccount:account];
                                 
                                 //NSURLRequest *signedReq = [request preparedURLRequest];
                                 [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                                     //NSString *dataString1 = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                                     NSError *e = nil;
                                     NSArray *responseJson = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&e];
                                     NSArray *tweetsStatus = [responseJson valueForKey:@"statuses"];
                                     NSMutableArray *tweetsTextArray = [[NSMutableArray alloc] init];
                                     for (int i = 0; i < tweetsStatus.count; ++i) {
                                         [tweetsTextArray addObject:[tweetsStatus[i] valueForKey:@"text"]];
                                     }
                                     NSMutableArray *tweetsJSONArray = [[NSMutableArray alloc] init];
                                     for (int i = 0; i < tweetsTextArray.count; ++i) {
                                        [tweetsJSONArray addObject:@{@"text":tweetsTextArray[i], @"id":@(i)}];
                                     }
                                     NSDictionary *sentimentJSON = @{@"data": tweetsJSONArray};
                                     NSData *json = nil;
                                     NSError *error2 = nil;
                                     NSString *jsonString;
                                     if ([NSJSONSerialization isValidJSONObject:sentimentJSON]) {
                                        json = [NSJSONSerialization dataWithJSONObject:sentimentJSON options:NSJSONWritingPrettyPrinted error:&error2];
                                        if (json != nil && error2 == nil)
                                        {
                                            jsonString = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
                                            
                                            json = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
                                            id jsonObject = [NSJSONSerialization JSONObjectWithData:json options:kNilOptions error:&error2];
                                            //NSLog(@"JSON: %@", jsonString);
                                        }
                                     }
                                     if (json) {
                                         NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
                                         [request setURL:[NSURL URLWithString:sentimentEngine]];
                                         [request setHTTPMethod:@"POST"];
                                         [request setValue:@"application/json; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
                                         [request setHTTPBody:json];
                                         NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
                                         NSError *error3 = [[NSError alloc] init];
                                         NSHTTPURLResponse *responseCode = nil;
                                         
                                         NSData *oResponseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error3];
                                         
                                         if([responseCode statusCode] != 200){
                                             NSLog(@"Error getting %@, HTTP status code %li", url, (long) [responseCode statusCode]);
                                         }
                                         
                                         NSString *dataStr;
                                         dataStr = [[NSString alloc] initWithData:oResponseData encoding:NSASCIIStringEncoding];
                                         if (!dataStr)
                                         {
                                             NSLog(@"ASCII not working, will try utf-8!");
                                             dataStr = [[NSString alloc] initWithData:oResponseData encoding:NSUTF8StringEncoding];
                                         }
                                         
                                         NSData *jsonData = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
                                         NSError *jsonError;
                                         NSDictionary *analyzedData = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&jsonError];
                                         NSArray *dataInAnalyzedData = analyzedData[@"data"];
                                         NSMutableArray *analyzedTweets = [[NSMutableArray alloc] init];
                                         for (int i = 0; i < dataInAnalyzedData.count; ++i) {
                                             NSDictionary *newlyConstructedElement = [dataInAnalyzedData[i] mutableCopy];
                                            [newlyConstructedElement setValue:[tweetsStatus[i] valueForKey:@"place"] forKey:@"geo"];
                                             [analyzedTweets addObject:newlyConstructedElement];
                                         }
                                         
                                         RegionBounding mapBounding = [self caculateRegionBounding:analyzedTweets];
                                         //[self updateRegionInMapView:mapBounding];
                                         [self updatePinInMapView:analyzedTweets];
                                         
                                         NSLog(@"aaaa");
                                         
                                     }
                                 }];
                                 
                             }
                         }
                }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"Receive response from Twitter");
    //self.webData = [[NSMutableData alloc] init];
}


- (void)connection:(NSURLConnection *)connection
    didReceiveData:(NSData *)data {
    NSLog(@"Data received from Twitter");
    NSError *error = nil;
    NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    BOOL testJson = [NSJSONSerialization isValidJSONObject:data];
    //[self.webData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"A");
    //[self.uiWebView loadData:self.webData MIMEType: @"text/html" textEncodingName: @"UTF-8" baseURL:nil];
    
}

- (IBAction)setMap:(id)sender {
    switch (((UISegmentedControl *) sender).selectedSegmentIndex) {
        case 0:
            self.mapView.mapType = MKMapTypeStandard;
            break;
        case 1:
            self.mapView.mapType = MKMapTypeSatellite;
            break;
        case 2:
            self.mapView.mapType = MKMapTypeHybrid;
            break;
        default:
            break;
    }
}

#pragma mark - Twitter Location Management

- (RegionBounding)caculateRegionBounding:(NSArray *)locations {
    RegionBounding result;
    result.leftBound = DBL_MAX;
    result.rightBound = DBL_MIN;
    result.upperBound = DBL_MIN;
    result.lowerBound = DBL_MAX;
    for (NSDictionary *element in locations) {
        NSDictionary *currentGeoInfo = element[@"geo"];
        if (![currentGeoInfo isKindOfClass:[NSDictionary class]]) {
            return result;
        }
        NSDictionary *currentBoundingBox = currentGeoInfo[@"bounding_box"];
        NSArray *currentCoordinates = currentBoundingBox[@"coordinates"];
        CLLocationCoordinate2D currentCenter;
        for (NSArray *point in currentCoordinates[0]) {
            NSNumber* currentLatitude = point[1];
            NSNumber* currentLongtitude = point[0];
            currentCenter.latitude += [currentLatitude doubleValue];
            currentCenter.longitude += [currentLongtitude doubleValue];
        }
        currentCenter.latitude /= 4;
        currentCenter.longitude /= 4;
        result.leftBound = MIN(result.leftBound, currentCenter.longitude);
        result.rightBound = MAX(result.rightBound, currentCenter.longitude);
        result.upperBound = MAX(result.upperBound, currentCenter.latitude);
        result.lowerBound = MIN(result.lowerBound, currentCenter.latitude);
    }
    return result;
}

- (void)updateRegionInMapView:(RegionBounding) mapBounding {
    CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake((mapBounding.upperBound +mapBounding.lowerBound) / 2, (mapBounding.leftBound + mapBounding.rightBound) / 2);
    MKCoordinateRegion updatedRegion;
    updatedRegion.center = centerCoordinate;
    updatedRegion.span.latitudeDelta = mapBounding.upperBound - mapBounding.lowerBound;
    updatedRegion.span.longitudeDelta = mapBounding.rightBound - mapBounding.leftBound;
    [self.mapView setRegion:updatedRegion animated:YES];
}

- (void)updatePinInMapView:(NSArray *) tweets {
    for (NSDictionary *element in tweets) {
        NSDictionary *currentGeoInfo = element[@"geo"];
        if (![currentGeoInfo isKindOfClass:[NSDictionary class]]) {
            continue;
        }
        NSDictionary *currentBoundingBox = currentGeoInfo[@"bounding_box"];
        NSArray *currentCoordinates = currentBoundingBox[@"coordinates"];
        CLLocationCoordinate2D currentCenter;
        currentCenter.latitude = 0;
        currentCenter.longitude = 0;
        for (NSArray *point in currentCoordinates[0]) {
            NSNumber* currentLatitude = point[1];
            NSNumber* currentLongtitude = point[0];
            currentCenter.latitude += [currentLatitude doubleValue];
            currentCenter.longitude += [currentLongtitude doubleValue];
        }
        currentCenter.latitude /= 4;
        currentCenter.longitude /= 4;
        //MKPointAnnotation *currentAnnotation = [[MKPointAnnotation alloc] init];
        //currentAnnotation.coordinate = currentCenter;
        long currentPolarity = [element[@"polarity"] longValue];
        TweetAnnotation *currentAnnotation = [[TweetAnnotation alloc] initWithCoordinate:currentCenter withPolarity:currentPolarity];
        //[self.mapView addAnnotation:currentAnnotation];
        //dispatch_async(dispatch_get_main_queue(), ^{
            [self.mapView addAnnotation:currentAnnotation];
        //});
        //[self.view addSubview:self.mapView];
        //[self.mapView addAnnotation:currentAnnotation];
        self.pinCounter++;
    }
}

#pragma mark - MKMapViewDelegate Methods

- (MKAnnotationView *) mapView:(MKMapView *)thisMapView
             viewForAnnotation:(TweetAnnotation *)annotation {
    
    //the annotation view objects act like cells in a tableview.  When off screen,
    //they are added to a queue waiting to be reused.  This code mirrors that for
    //getting a table cell.  First check if the queue has available annotation views
    //of the right type, identified by the identifier string.  If nil is returned,
    //then allocate a new annotation view.
    
    static NSString *tweetLocationIdentifier = @"tweetLocationIdentifier";
    
    //the result of the call is being cast (MKPinAnnotationView *) to the correct
    //view class or else the compiler complains
    MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[thisMapView
                                                                  dequeueReusableAnnotationViewWithIdentifier:tweetLocationIdentifier];
    if (annotationView == nil) {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:tweetLocationIdentifier];
    }
    
    if (annotation.polarity == 0) {
        annotationView.pinColor = MKPinAnnotationColorGreen;
    }
    else if (annotation.polarity == 2) {
        annotationView.pinColor = MKPinAnnotationColorRed;
    }
    else if (annotation.polarity == 4) {
        annotationView.pinColor = MKPinAnnotationColorPurple;
    }
    
    //pin drops when it first appears
    annotationView.animatesDrop=TRUE;
    
    //tapping the pin produces a gray box which shows title and subtitle
    annotationView.canShowCallout = NO;
    
    return annotationView;
}

#pragma mark - Location Manager

- (CLLocationManager *)manager {
    if (!_manager) {
        _manager = [[CLLocationManager alloc]init];
        _manager.delegate = self;
        _manager.desiredAccuracy = kCLLocationAccuracyBest;
    }
    return _manager;
}

- (void)startLocations {
    
    // create and start the location manager
    
    [self.manager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    //self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"blue"]];
    
    // grab current location and display it in a label
    CLLocation *currentLocation = [locations lastObject];
    
    NSString *longText = [NSString stringWithFormat:@"%f", currentLocation.coordinate.longitude];
    NSString *latText = [NSString stringWithFormat:@"%f", currentLocation.coordinate.latitude];
    NSString *accuracy = [NSString stringWithFormat:@"%f", currentLocation.horizontalAccuracy];
    
    //self.longLabel.text = longText;
    //self.latLabel.text = latText;
    //self.accuracyLabel.text = accuracy;
    
    // and update our Map View
    [self updateMapView:currentLocation];
}

#pragma mark - Map Kit

- (void)updateMapView:(CLLocation *)location {
    
    // create a region and pass it to the Map View
    MKCoordinateRegion region;
    region.center.latitude = location.coordinate.latitude;
    region.center.longitude = location.coordinate.longitude;
    region.span.latitudeDelta = 0.001;
    region.span.longitudeDelta = 0.001;
    
    [self.mapView setRegion:region animated:YES];
    
    // remove previous marker
    MKPlacemark *previousMarker = [self.mapView.annotations lastObject];
    [self.mapView removeAnnotation:previousMarker];
    
    // create a new marker in the middle
    MKPlacemark *marker = [[MKPlacemark alloc]initWithCoordinate:location.coordinate addressDictionary:nil];
    [self.mapView addAnnotation:marker];
    
    // create an address from our coordinates
    /*
    CLGeocoder *geocoder = [[CLGeocoder alloc]init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        
        CLPlacemark *placemark = [placemarks lastObject];
        NSString *address = [NSString stringWithFormat:@"%@, %@, %@, %@", placemark.thoroughfare, placemark.locality, placemark.administrativeArea, placemark.postalCode];
        if (placemark.thoroughfare != NULL) {
            self.addressLabel.text = address;
        } else {
            self.addressLabel.text = @"";
        }
        
    }];
    */
}

// let the user add their own pins

- (void)addPin:(UIGestureRecognizer *)recognizer {
    
    if (recognizer.state != UIGestureRecognizerStateBegan) {
        return;
    }
    
    // convert touched position to map coordinate
    CGPoint userTouch = [recognizer locationInView:self.mapView];
    CLLocationCoordinate2D mapPoint = [self.mapView convertPoint:userTouch toCoordinateFromView:self.mapView];
    
    // and add it to our view
    Pin *newPin = [[Pin alloc]initWithCoordinate:mapPoint];
    [self.mapView addAnnotation:newPin];
    
}

@end
