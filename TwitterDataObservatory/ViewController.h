//
//  ViewController.h
//  TwitterDataObservatory
//
//  Created by Wenyu Zhang on 11/27/15.
//  Copyright (c) 2015 Wenyu Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
@import MapKit;
@import CoreLocation;

typedef struct {
    CLLocationDegrees upperBound;
    CLLocationDegrees lowerBound;
    CLLocationDegrees leftBound;
    CLLocationDegrees rightBound;
} RegionBounding;

@interface ViewController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate>

extern NSString* const sentimentEngine;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
- (IBAction)setMap:(id)sender;

@end

