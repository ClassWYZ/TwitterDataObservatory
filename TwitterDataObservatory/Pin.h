//
//  Pin.h
//  TwitterDataObservatory
//
//  Created by Wenyu Zhang on 12/15/15.
//  Copyright (c) 2015 Wenyu Zhang. All rights reserved.
//

#ifndef TwitterDataObservatory_Pin_h
#define TwitterDataObservatory_Pin_h


#import <Foundation/Foundation.h>
@import MapKit;

@interface Pin : NSObject <MKAnnotation>

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;

- (id)initWithCoordinate:(CLLocationCoordinate2D)newCoordinate;

@end

#endif
