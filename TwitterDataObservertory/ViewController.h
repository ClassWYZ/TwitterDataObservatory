//
//  ViewController.h
//  TwitterDataObservertory
//
//  Created by Wenyu Zhang on 11/23/15.
//  Copyright (c) 2015 Wenyu Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController {
}

@property (weak, nonatomic) IBOutlet UITextField *label;
@property (weak, nonatomic) IBOutlet UILabel *mainLabel;
@property (weak, nonatomic) IBOutlet UIWebView *uiWebView;
- (IBAction)press:(id)sender;

@end

