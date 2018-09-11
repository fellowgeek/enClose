//
//  ViewController.h
//  enClose WKWebView
//
//  Created by Work on 2/27/18.
//  Copyright © 2018 cvb.inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#include <AVFoundation/AVFoundation.h>

@interface ViewController : UIViewController <WKScriptMessageHandler> {

	NSMutableDictionary *queryStringDictionary;
	NSString *iosParameters;
	bool debugMode;
	
}

@end

