//
//  ViewController.m
//  enClose WKWebView
//
//  Created by Work on 2/27/18.
//  Copyright © 2018 cvb.inc. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (strong, nonatomic) WKWebView *webView;

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	queryStringDictionary = [[NSMutableDictionary alloc] init];

	WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
	WKUserContentController *controller = [[WKUserContentController alloc] init];
	[controller addScriptMessageHandler:self name:@"enClose"];
	configuration.userContentController = controller;
	
	NSURL *requestURL = [[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:@"index" ofType:@"html" inDirectory:@"www"]];
	
	_webView = [[WKWebView alloc] initWithFrame:self.view.frame configuration:configuration];
	[[_webView scrollView] setBounces:NO];
	[_webView loadRequest:[NSURLRequest requestWithURL:requestURL]];
	[self.view addSubview:_webView];

	// set debug mode
	debugMode = YES;
	
}

- (void)userContentController:(WKUserContentController *)userContentController
	  didReceiveScriptMessage:(WKScriptMessage *)message {
	
	NSString *requestURL =[NSString stringWithFormat:@"%@", message.body];

	if ([requestURL hasPrefix:@"ios:"]) {
		
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
		
		if(debugMode == YES) {
			NSLog(@"requestURL: %@", requestURL);
			NSLog(@"queryStringDictionary: %@", queryStringDictionary);
		}

	}

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

- (BOOL)prefersStatusBarHidden {
	return YES;
}

/*
 --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
 helloWorld
 --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
 */
- (void)helloWorld {
	
	// play system alet sound
	AVSpeechSynthesizer *synthesizer = [[AVSpeechSynthesizer alloc]init];
	AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:[queryStringDictionary objectForKey:@"message"]];
	[utterance setRate: [[queryStringDictionary objectForKey:@"speed"] floatValue]];
	[synthesizer speakUtterance:utterance];
	
	// process nativeCall successCallback function and send data to web UI
	NSString *successResponse = @"You have successfully called this native function.";
	if([[queryStringDictionary objectForKey:@"callback"] isEqualToString:@""] == NO) {
		NSString *javaScript = [NSString stringWithFormat:@"%@('%@');", [queryStringDictionary objectForKey:@"successCallback"], successResponse];
		[_webView evaluateJavaScript:javaScript completionHandler:nil];

	}
	
}

@end
