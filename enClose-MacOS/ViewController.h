//
//  ViewController.h
//  enClose-MacOS
//
//  Created by Work on 9/14/18.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#include <AVFoundation/AVFoundation.h>

@interface ViewController : NSViewController <WKScriptMessageHandler> {

	NSMutableDictionary *queryStringDictionary;
	NSString *iosParameters;
	bool debugMode;
	
}

@property(strong,nonatomic) WKWebView* webView;

@end

