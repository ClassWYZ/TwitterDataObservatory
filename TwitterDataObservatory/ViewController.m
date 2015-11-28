//
//  ViewController.m
//  TwitterDataObservatory
//
//  Created by Wenyu Zhang on 11/27/15.
//  Copyright (c) 2015 Wenyu Zhang. All rights reserved.
//

#import "ViewController.h"
@import Twitter;
@import Social;
@import Accounts;

@interface ViewController ()

@property (nonatomic, strong) NSURLConnection *twitterConnection;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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
                                 [params setObject:@"40.8075,-73.9619,1.5mi" forKey:@"geocode"];
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
                                     NSString *dataString1 = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                                     NSError *e = nil;
                                     NSArray *responseJson = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&e];
                                     //NSLog(dataString1);
                                 }];
                                 /*
                                 // make the connection, ensuring that it is made on the main runloop
                                 self.twitterConnection = [[NSURLConnection alloc] initWithRequest:signedReq delegate:self startImmediately: NO];
                                 [self.twitterConnection scheduleInRunLoop:[NSRunLoop mainRunLoop]
                                                                   forMode:NSDefaultRunLoopMode];
                                 [self.twitterConnection start];
                                 */
                                 
                             }
                         }
                     }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
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
    //[self.uiWebView loadData:self.webData MIMEType: @"text/html" textEncodingName: @"UTF-8" baseURL:nil];
    
}
 */
@end
