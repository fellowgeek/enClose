//
//  ViewController.m
//  enClose
//
//  Created by Erfan Reed on 1/20/15.
//  Copyright (c) 2015 malouf. All rights reserved.
//

/*

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 
*/


#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize enCloseWebView;

/*
 --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
 application startup
 --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    // do any additional setup after loading the view, typically from a nib.
    queryStringDictionary = [[NSMutableDictionary alloc] init];
    
    // start the web view and load index.html
    NSURL *requestURL = [[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:@"index" ofType:@"html" inDirectory:@"www"]];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:requestURL];
    enCloseWebView.delegate = self;
    [enCloseWebView loadRequest:request];
    enCloseWebView.scrollView.bounces = NO;
    enCloseWebView.keyboardDisplayRequiresUserAction = NO;

    // set debug mode
    debugMode = YES;

}

/*
 --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
 operations to be taken place right after webpage finished loading (UIWebViewDelegate)
 --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
 */
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    // i.e. call a javascript function on web view
    NSLog(@"Ready.");
    
}

/*
 --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
 handle native calls from web using ios: url protocol (UIWebViewDelegate)
 --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
 */
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    NSString *requestURL =[NSString stringWithFormat:@"%@", [[request URL] fragment]];
    
    if ([requestURL hasPrefix:@"ios:"]) {
        
        if(debugMode == YES) { NSLog(@"%@", requestURL); }
        
        // call the native method if exists
        NSRange range;
        range = NSMakeRange(0, [requestURL rangeOfString:@"?"].location);
        NSString *iosMethod = [requestURL substringWithRange:range];
        iosMethod = [iosMethod stringByReplacingOccurrencesOfString:@"ios:" withString: @""];
        
        range = NSMakeRange(([requestURL rangeOfString:@"?"].location + 1), ([requestURL length] - [requestURL rangeOfString:@"?"].location) - 1);
        iosParameters = [requestURL substringWithRange:range];
        
        [queryStringDictionary removeAllObjects];
        NSArray *urlComponents = [iosParameters componentsSeparatedByString:@"&"];
        for(NSString *keyValuePair in urlComponents) {
            NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
            NSString *key = [[pairComponents firstObject] stringByRemovingPercentEncoding];
            NSString *value = [[pairComponents lastObject] stringByRemovingPercentEncoding];
            [queryStringDictionary setValue:value forKey:key];
        }
        
        SEL selector = NSSelectorFromString(iosMethod);
        if([self respondsToSelector: selector] == YES) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [self performSelector:selector];
#pragma clang diagnostic pop
        }
        // cancel the location change
        return NO;
    }
    return YES;
    
}
/*
 --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
 system
 --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
 */
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews {
    enCloseWebView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

/*
 --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
 helloWorld
 --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
 */
- (void)helloWorld {
    
    NSLog(@"\n%@", queryStringDictionary);
    
    // play system alet sound
    AVSpeechSynthesizer *synthesizer = [[AVSpeechSynthesizer alloc]init];
    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:[queryStringDictionary objectForKey:@"message"]];
    [utterance setRate: [[queryStringDictionary objectForKey:@"speed"] floatValue]];
    [synthesizer speakUtterance:utterance];
    
    // process nativeCall successCallback function and send data to web UI
    NSString *successResponse = @"You have successfully called this native function.";
    if([[queryStringDictionary objectForKey:@"callback"] isEqualToString:@""] == NO) {
        NSString *javaScript = [NSString stringWithFormat:@"%@('%@');", [queryStringDictionary objectForKey:@"successCallback"], successResponse];
        [self.enCloseWebView stringByEvaluatingJavaScriptFromString:javaScript];
    }
    
}

@end
