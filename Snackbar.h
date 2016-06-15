#import <UIKit/UIKit.h>
#import <Cobalt/CobaltAbstractPlugin.h>

@interface Snackbar : UIView

+ (instancetype) showWithText: (NSString *) text
                  andDuration: (int) duration
                    andAction: (NSDictionary *) action
            andViewController: (CobaltViewController *) viewController
                  andCallback: (NSString *) callback;

@end
