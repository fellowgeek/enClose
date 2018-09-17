//
//  ViewController.m
//  enClose-MacOS
//
//  Created by Work on 9/14/18.
//

#import "ViewController.h"

@implementation ViewController

/*
 --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
 enClose
 --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
*/

- (void)loadView {
	
	[super loadView];

	queryStringDictionary = [[NSMutableDictionary alloc] init];
	
	WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
	WKUserContentController *controller = [[WKUserContentController alloc] init];
	[controller addScriptMessageHandler:self name:@"enClose"];
	configuration.userContentController = controller;

	_webView = [[WKWebView alloc] initWithFrame:[[self view] bounds] configuration:configuration];
	[self setView: _webView];
	
	// set debug mode
	debugMode = YES;
	
}

- (void)viewDidLoad {
	
	[super viewDidLoad];

	// Do any additional setup after loading the view.
	
	NSURL *requestURL = [[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:@"index" ofType:@"html" inDirectory:@"www"]];
 	[_webView loadRequest: [NSURLRequest requestWithURL:requestURL]];

}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {

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

- (void)setRepresentedObject:(id)representedObject {
	[super setRepresentedObject:representedObject];

	// Update the view, if already loaded.
}

/*
 --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
 helloWorld
 --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- ---------
*/
- (void)helloWorld {
	
	// play system alet sound
	NSSpeechSynthesizer *synthesizer = [[NSSpeechSynthesizer alloc]init];
	
	[synthesizer  startSpeakingString:[queryStringDictionary objectForKey:@"message"]];
	
	// process nativeCall successCallback function and send data to web UI
	NSString *successResponse = @"You have successfully called this native function.";
	if([[queryStringDictionary objectForKey:@"callback"] isEqualToString:@""] == NO) {
		NSString *javaScript = [NSString stringWithFormat:@"%@('%@');", [queryStringDictionary objectForKey:@"successCallback"], successResponse];
		[_webView evaluateJavaScript:javaScript completionHandler:nil];
	}
	
}

@end
