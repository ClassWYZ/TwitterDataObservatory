//
//  TweetAnnotation.h
//  TwitterDataObservatory
//
//  Created by Wenyu Zhang on 12/16/15.
//  Copyright (c) 2015 Wenyu Zhang. All rights reserved.
//

#ifndef TwitterDataObservatory_TweetAnnotation_h
#define TwitterDataObservatory_TweetAnnotation_h

#import <Foundation/Foundation.h>
@import MapKit;

@interface TweetAnnotation : NSObject <MKAnnotation>

@property (readwrite, nonatomic) CLLocationCoordinate2D coordinate;
@property (readwrite, copy, nonatomic) NSString *title;
@property (readwrite, copy, nonatomic) NSString *subtitle;
@property (readwrite, assign, nonatomic) NSInteger polarity;

//programmer provided init function to create the annotation objects
-(id)initWithCoordinate:(CLLocationCoordinate2D)coordinate andPolarity:(NSInteger)polarity andTitle:(NSString *)title andSubtitle:(NSString *)subtitle;


@end
#endif
