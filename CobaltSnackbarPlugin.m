#import "CobaltSnackbarPlugin.h"

@implementation CobaltSnackbarPlugin

- (void)onMessageFromWebView:(WebViewType)webView
          inCobaltController:(nonnull CobaltViewController *)viewController
                  withAction:(nonnull NSString *)action
                        data:(nullable NSDictionary *)data
          andCallbackChannel:(nullable NSString *)callbackChannel{
    

    if (data != nil) {
        NSString * text = [data objectForKey: @"text"];
        if (text == nil) {
            text = @"Your snackbar text";
        }

        NSNumber * durationOption = [data objectForKey: @"duration"];
        int duration = 1500;
        if (durationOption != nil) {
            duration = [durationOption intValue];
        }

        NSString * action = [data objectForKey: @"button"];
        NSString * actionColor = [data objectForKey: @"buttonColor"];

        [Snackbar showWithText: text
                   andDuration: duration
                     andAction: action
                andActionColor: actionColor
             andViewController: viewController
                   andCallback: callbackChannel];
    }
    else {
        NSLog(@"CobaltSnackbarPlugin onMessageWithCobaltController:andData: data is nil");
    }
}

@end
