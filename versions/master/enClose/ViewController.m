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

- (void)loadView {

	queryStringDictionary = [[NSMutableDictionary alloc] init];
	iosParameters = @"";
	debugMode = YES;

	WKUserContentController *controller = [[WKUserContentController alloc] init];
	[controller addScriptMessageHandler:self name:@"enClose"];

	WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
	configuration.userContentController = controller;

	_webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:configuration];
	[_webView setUIDelegate:self];
	[_webView setNavigationDelegate:self];
	[[_webView scrollView] setBounces:NO];
	self.view = _webView;
	
}
	
- (void)viewDidLoad {
	[super viewDidLoad];
	
	NSURL *url = [[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:@"index" ofType:@"html" inDirectory:@"www"]];
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	[_webView loadRequest:request];
	
}

// disable user text selection
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
	
	NSString *javascriptStyle = @"var css = '*{-webkit-touch-callout:none;-webkit-user-select:none}'; var head = document.head || document.getElementsByTagName('head')[0]; var style = document.createElement('style'); style.type = 'text/css'; style.appendChild(document.createTextNode(css)); head.appendChild(style);";
	[_webView evaluateJavaScript:javascriptStyle completionHandler:nil];
	
}
	
// enclose
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
	[synthesizer speakUtterance:utterance];
	
	// process nativeCall successCallback function and send data to web UI
	NSString *successResponse = @"You have successfully called a native function from javascript, and you got schwifty!";
	if([[queryStringDictionary objectForKey:@"callback"] isEqualToString:@""] == NO) {
		NSString *javaScript = [NSString stringWithFormat:@"%@('%@');", [queryStringDictionary objectForKey:@"successCallback"], successResponse];
		[_webView evaluateJavaScript:javaScript completionHandler:nil];

	}
	
}

@end
