//
//  ViewController.h
//  enClose
//
//  Created by Erfan Reed on 1/20/15.
//  Copyright (c) 2015 malouf. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <AVFoundation/AVFoundation.h>

@interface ViewController : UIViewController <UIWebViewDelegate> {

    NSMutableDictionary *queryStringDictionary;
    NSString *iosParameters;

}

@property (weak, nonatomic) IBOutlet UIWebView *enCloseWebView;

@end

