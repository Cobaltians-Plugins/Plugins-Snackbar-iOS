#import <Cobalt/CobaltAbstractPlugin.h>
#import "Snackbar.h"

@interface CobaltSnackbarPlugin: CobaltAbstractPlugin

- (instancetype) init;
- (void) onAction: (NSDictionary *) userData;

@end
