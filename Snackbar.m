#import "Snackbar.h"

static float const ShortDuration = 1.5;
static float const LongDuration = 2.75;

static int const MaxHeight = 48;
static int const MaxWidth = 400;
static int const Margin = 5;
static float const TransitionDuration = 0.2;

static Snackbar * currentSnackbar = nil;

@interface Snackbar ()

@property (nonatomic) BOOL infiniteTimer;
@property (nonatomic) NSTimeInterval duration;
@property (nonatomic) NSTimer * timer;

@property (nonatomic) BOOL hasActionButton;
@property (nonatomic, weak) CobaltViewController * viewController;
@property (nonatomic) NSString * callback;

@property (nonatomic) UILabel * text;
@property (nonatomic) UIView * separator;
@property (nonatomic) UIButton * action;

@property (nonatomic) NSArray * verticalHiddenConstraints;
@property (nonatomic) NSArray * verticalShownConstraints;

@property (nonatomic) UIDeviceOrientation lastOrientation;

@end

@implementation Snackbar

+ (instancetype) showWithText: (NSString *) text
                  andDuration: (int) duration
                    andAction: (NSString *) action
               andActionColor: (NSString *) actionColor
            andViewController: (CobaltViewController *) viewController
                  andCallback: (NSString *) callback
{
    return [[self alloc] initWithText: text
                          andDuration: duration
                            andAction: action
                       andActionColor: actionColor
                    andViewController: viewController
                          andCallback: callback];
}

- (instancetype) initWithText: (NSString *) text
                  andDuration: (int) duration
                    andAction: (NSString *) action
               andActionColor: (NSString *) actionColor
            andViewController: (CobaltViewController *) viewController
                  andCallback: (NSString *) callback
{
    if (self = [super initWithFrame: CGRectMake(0, 0, 0, 0)]) {
        _lastOrientation = UIDeviceOrientationUnknown;

        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.opaque = NO;

        // Setup text label
        _text = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, 0, 0)];
        _text.text = text;
        _text.translatesAutoresizingMaskIntoConstraints = NO;
        _text.numberOfLines = 2;
        _text.font = [UIFont systemFontOfSize: 14.0];
        _text.textColor = [UIColor whiteColor];
        [self addSubview: _text];

        _viewController = viewController;
        _callback = callback;

        if (action != nil && [action length] > 0) {
            _hasActionButton = action != nil;

            if (_hasActionButton) {
                // Setup action button
                _action = [UIButton buttonWithType: UIButtonTypeSystem];
                _action.translatesAutoresizingMaskIntoConstraints = NO;
                _action.titleLabel.font = [UIFont systemFontOfSize: 14.0 weight: UIFontWeightBold];
                [_action setTitle: action forState: UIControlStateNormal];
                UIColor * color = [Cobalt colorFromHexString: actionColor];
                if (color == nil) {
                    color = [UIColor whiteColor];
                }
                [_action setTitleColor: color forState: UIControlStateNormal];
                [_action sizeToFit];
                [_action addTarget: self action: @selector(executeAction:) forControlEvents: UIControlEventTouchUpInside];
                [_action setContentCompressionResistancePriority: UILayoutPriorityRequired forAxis: UILayoutConstraintAxisHorizontal];
                [self addSubview: _action];

                // Setup separator
                _separator = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 0, 0)];
                _separator.translatesAutoresizingMaskIntoConstraints = NO;
                _separator.backgroundColor = [UIColor colorWithWhite: 1.0 alpha: 0.1];
                [self addSubview: _separator];
            }
        }
        else {
            _hasActionButton = NO;
        }

        // Calculate duration
        _infiniteTimer = NO;
        if (duration == 0) {
            _duration = LongDuration;
        }
        else if (duration == -1) {
            _duration = ShortDuration;
        }
        else if (duration <= -2) {
            if (!_hasActionButton) {
                NSLog(@"Snackbar Plugin: Snackbars with INFINITE duration must have an action, using LONG instead");
                _duration = LongDuration;
            }
            else {
                _infiniteTimer = YES;
            }
        }
        else {
            _duration = duration / 1000.0;
        }
        _duration += TransitionDuration;

        [self show];
    }

    return self;
}

- (void) layoutSubviews
{
    UIDeviceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;

    if (_lastOrientation == UIDeviceOrientationUnknown) {
        _lastOrientation= orientation;
    }
    else if (_lastOrientation != orientation) {
        [self dismissWithAnimation: YES];
    }
}

- (void) show
{
    BOOL shouldReplaceCurrentSnackbar = currentSnackbar != nil;

    if (shouldReplaceCurrentSnackbar) {
        [currentSnackbar dismissWithAnimation: YES];
    }

    UIViewController * topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (topController.presentedViewController != nil) {
        topController = topController.presentedViewController;
    }
    UIView * superview = topController.view;
    superview = _viewController.view;

    [superview addSubview: self];
    [superview addConstraints: [self horizontalConstraints]];
    [superview addConstraints: [self verticalHiddenConstraints]];
    [superview layoutIfNeeded];

    [self addConstraints: [self contentConstraints]];
    [self layoutIfNeeded];

    [superview removeConstraints: [self verticalHiddenConstraints]];
    [superview addConstraints: [self verticalShownConstraints]];

    [UIView animateWithDuration: TransitionDuration
                          delay: shouldReplaceCurrentSnackbar ? TransitionDuration : 0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations: ^{ [superview layoutIfNeeded]; }
                     completion: nil];

    if (!_infiniteTimer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval: _duration
                                                  target: self
                                                selector: @selector(timeout:)
                                                userInfo: nil
                                                 repeats: NO];
    }

    currentSnackbar = self;
}

- (instancetype) initWithFrame: (CGRect) frame
{
    self = [super initWithFrame: frame];

    return self;
}

- (void) drawRect: (CGRect) rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    CGContextSaveGState(ctx);

    [[UIColor colorWithWhite: 0.1
                       alpha: 0.9] setFill];
    UIBezierPath * clippath = [UIBezierPath bezierPathWithRoundedRect: rect
                                                         cornerRadius: 3];
    [clippath fill];

    CGContextRestoreGState(ctx);
}

- (void) timeout: (NSTimer *) timer
{
    [self dismissWithAnimation: YES];
}

- (void) dismissWithAnimation: (BOOL) animated
{
    [_timer invalidate];
    _timer = nil;

    [self.superview removeConstraints: [self verticalShownConstraints]];
    [self.superview addConstraints: [self verticalHiddenConstraints]];

    currentSnackbar = nil;

    if (animated) {
        [UIView animateWithDuration: TransitionDuration
                              delay: 0
                            options: UIViewAnimationOptionCurveEaseIn
                         animations: ^{ [self.superview layoutIfNeeded]; }
                         completion: ^(BOOL finished) { [self removeFromSuperview]; }];
    }
    else {
        [self removeFromSuperview];
    }
}

- (IBAction) executeAction: (id) sender
{
    [self dismissWithAnimation: YES];

    if (_viewController != nil) {
        [_viewController sendCallback: _callback
                             withData: nil];
    }
}

- (NSArray *) verticalShownConstraints
{
    if (_verticalShownConstraints == nil) {
        _verticalShownConstraints = [NSLayoutConstraint constraintsWithVisualFormat: @"V:[snackbar(maxHeight)]-(margin)-|"
                                                                            options: 0
                                                                            metrics: @{ @"maxHeight": @(MaxHeight), @"margin": @(Margin) }
                                                                              views: @{ @"snackbar": self }];
    }

    return _verticalShownConstraints;
}

- (NSArray *) verticalHiddenConstraints
{
    if (_verticalHiddenConstraints == nil) {
        _verticalHiddenConstraints = [NSLayoutConstraint constraintsWithVisualFormat: @"V:[snackbar(maxHeight)]-(hide)-|"
                                                                             options: 0
                                                                             metrics: @{ @"maxHeight": @(MaxHeight), @"hide": @(-MaxHeight - Margin) }
                                                                               views: @{ @"snackbar": self }];
    }

    return _verticalHiddenConstraints;
}

- (NSArray *) horizontalConstraints
{
    NSMutableArray * constraints = [NSMutableArray new];

    // Set the minimum margin on the sides and the maximum width
    [constraints addObjectsFromArray: [NSLayoutConstraint constraintsWithVisualFormat: @"H:|-(>=margin)-[snackbar(<=maxWidth)]-(>=margin)-|"
                                                                              options: 0
                                                                              metrics: @{ @"margin": @(Margin), @"maxWidth": @(MaxWidth) }
                                                                                views: @{ @"snackbar": self }]];

    // Center horizontally
    [constraints addObject: [NSLayoutConstraint constraintWithItem: self
                                                         attribute: NSLayoutAttributeCenterX
                                                         relatedBy: NSLayoutRelationEqual
                                                            toItem: self.superview
                                                         attribute: NSLayoutAttributeCenterX
                                                        multiplier: 1.0
                                                          constant: 0.0]];

    // Set the width at '100% - 2 * margin'
    NSLayoutConstraint * secondaryWidthConstraint = [NSLayoutConstraint constraintWithItem: self
                                                                         attribute: NSLayoutAttributeWidth
                                                                         relatedBy: NSLayoutRelationEqual
                                                                            toItem: self.superview
                                                                         attribute: NSLayoutAttributeWidth
                                                                        multiplier: 1.0
                                                                          constant: -(2 * Margin)];
    // Lower priority so that the max width constraint always wins over this one
    secondaryWidthConstraint.priority = UILayoutPriorityDefaultHigh;
    [constraints addObject: secondaryWidthConstraint];

    return constraints;
}

- (NSArray *) contentConstraints
{
    NSMutableArray * constraints = [NSMutableArray new];

    if (_hasActionButton) {
        [constraints addObjectsFromArray: [NSLayoutConstraint constraintsWithVisualFormat: @"H:|-8-[text]-(>=8)-[separator(1)]-8-[action]-8-|"
                                                                                  options: NSLayoutFormatAlignAllCenterY
                                                                                  metrics: nil
                                                                                    views: @{ @"text": _text, @"action": _action, @"separator": _separator }]];

        [constraints addObjectsFromArray: [NSLayoutConstraint constraintsWithVisualFormat: @"V:|-4-[separator]-4-|"
                                                                                  options: 0
                                                                                  metrics: nil
                                                                                    views: @{ @"separator": _separator }]];
    }
    else {
        [constraints addObjectsFromArray: [NSLayoutConstraint constraintsWithVisualFormat: @"H:|-8-[text]-8-|"
                                                                                  options: NSLayoutFormatAlignAllCenterY
                                                                                  metrics: nil
                                                                                    views: @{ @"text": _text }]];
    }

    [constraints addObject: [NSLayoutConstraint constraintWithItem: _text
                                                         attribute: NSLayoutAttributeCenterY
                                                         relatedBy: NSLayoutRelationEqual
                                                            toItem: self
                                                         attribute: NSLayoutAttributeCenterY
                                                        multiplier: 1.0
                                                          constant: 0.0]];

    return constraints;
}

@end
