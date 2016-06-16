#import <UIKit/UIKit.h>
#import <Cobalt/Cobalt.h>
#import <Cobalt/CobaltAbstractPlugin.h>

@interface Snackbar : UIView

+ (instancetype) showWithText: (NSString *) text
                  andDuration: (int) duration
                    andAction: (NSString *) action
               andActionColor: (NSString *) actionColor
            andViewController: (CobaltViewController *) viewController
                  andCallback: (NSString *) callback;

@end
