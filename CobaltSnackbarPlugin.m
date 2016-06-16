#import "CobaltSnackbarPlugin.h"

@implementation CobaltSnackbarPlugin

- (instancetype) init {
    self = [super init];

    return self;
}

- (void) onMessageFromCobaltController: (CobaltViewController *) viewController
                               andData: (NSDictionary *) data {
    [self onMessageWithCobaltController: viewController
                                andData: data];
}

- (void) onMessageFromWebLayerWithCobaltController: (CobaltViewController *) viewController
                                           andData: (NSDictionary *) data {
    [self onMessageWithCobaltController: viewController
                                andData: data];
}

- (void) onMessageWithCobaltController: (CobaltViewController *) viewController
                               andData: (NSDictionary *) data {

    NSDictionary * options = [data objectForKey: kJSData];

    if (options != nil) {
        NSString * text = [options objectForKey: @"text"];
        if (text == nil) {
            text = @"Your snackbar text";
        }

        NSNumber * durationOption = [options objectForKey: @"duration"];
        int duration = 1500;
        if (durationOption != nil) {
            duration = [durationOption intValue];
        }

        NSString * action = [options objectForKey: @"button"];
        NSString * actionColor = [options objectForKey: @"buttonColor"];

        NSString * callback = [data objectForKey: kJSCallback];

        if (action == nil) {
            callback = nil;
        }

        [Snackbar showWithText: text
                   andDuration: duration
                     andAction: action
                andActionColor: actionColor
             andViewController: viewController
                   andCallback: callback];
    }
    else {
        NSLog(@"CobaltSnackbarPlugin onMessageWithCobaltController:andData: data is nil");
    }
}

@end
