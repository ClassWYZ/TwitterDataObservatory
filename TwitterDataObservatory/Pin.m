//
//  Pin.m
//  TwitterDataObservatory
//
//  Created by Wenyu Zhang on 12/15/15.
//  Copyright (c) 2015 Wenyu Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Pin.h"

@implementation Pin

- (id)initWithCoordinate:(CLLocationCoordinate2D)newCoordinate {
    
    self = [super init];
    if (self) {
        _coordinate = newCoordinate;
        _title = @"Hello";
        _subtitle = @"Are you still there?";
    }
    return self;
}

@end