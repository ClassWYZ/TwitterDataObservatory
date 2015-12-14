//
//  ViewController.h
//  TwitterDataObservatory
//
//  Created by Wenyu Zhang on 11/27/15.
//  Copyright (c) 2015 Wenyu Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
@import MapKit;

@interface ViewController : UIViewController

extern NSString* const sentimentEngine;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;

@end

