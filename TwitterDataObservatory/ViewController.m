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

NSString* const sentimentEngine = @"http://www.sentiment140.com/api/bulkClassifyJson?appid=wyzhang8@outlook.com";

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
                                 [params setObject:@"40.7903,-73.9597,1mi" forKey:@"geocode"];
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
                                            NSLog(@"JSON: %@", jsonString);
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
                                         NSLog(analyzedTweets);
                                        
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

@end
