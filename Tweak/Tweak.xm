#import "Tweak.h"

#ifndef SIMULATOR
HBPreferences *preferences;
#endif

BOOL enabled;
BOOL hapticFeedbackEnabled;


%group PanCake

UIPanGestureRecognizer *panGestureRecognizer;
// UINavigationController *lastNavVC;

BOOL shouldRecognizeSimultaneousGestures;


static BOOL panGestureIsSwipingLeftToRight(UIPanGestureRecognizer *panGest) {
    CGPoint velocity = [panGestureRecognizer velocityInView:panGest.view];
    DLog(@"panGestureIsSwipingLeftToRight %@", NSStringFromCGPoint(velocity));

    if (fabs(velocity.x) > fabs(velocity.y)) { //horizontal
        if (velocity.x > 0) { //from left to right
            return YES;
        }
    }

    if (velocity.x == 0 && velocity.y == 0) {
        return YES; //workaround a bug that would happened in some apps (like LinkedIn) with conflicting scroll view, that lead to velocity={0,0} after the first incomplete swipe
    }

    return NO;
}


%hook UINavigationController

-(void)_layoutTopViewController {
    %orig;

    UIViewController *viewController = [self topViewController];

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"

    UIView *viewForGesture = viewController.view;

    if (!viewForGesture) return;
    
    if (viewController != [viewController.navigationController.viewControllers objectAtIndex:0]) { //if it's not rootviewcontroller
        if (![viewForGesture.gestureRecognizers containsObject:panGestureRecognizer]) {
            DLog(@"Adding gesture on view : %@", self._cachedInteractionController);

            if ([self._cachedInteractionController respondsToSelector:@selector(handleNavigationTransition:)]) {
                panGestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self._cachedInteractionController action:@selector(handleNavigationTransition:)];
                panGestureRecognizer.delegate = self;
                [viewForGesture addGestureRecognizer:panGestureRecognizer];
            }
        }
    }
    
#pragma clang diagnostic pop
}

//Limit conflicts with some UIScrollView and swipes from right to left
%new
- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)panGestureRecognizer {
    return panGestureIsSwipingLeftToRight(panGestureRecognizer);
}

%new
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (shouldRecognizeSimultaneousGestures) {
        if (gestureRecognizer == panGestureRecognizer) {
            return panGestureIsSwipingLeftToRight(panGestureRecognizer); //Messenger app requires this additional check (swiping side)
        }
    }

    return NO;
}

%end //hook UINavigationController


%hook _UINavigationInteractiveTransitionBase

-(void)handleNavigationTransition:(UIPanGestureRecognizer*)arg1 {
    // DLog(@"handleNavigationTransition %@", arg1);

    %orig;
}

%end //hook _UINavigationInteractiveTransitionBase

%end //group PanCake


%group HapticFeedback

%hook UINavigationController

-(void)_finishInteractiveTransition:(double)arg1 transitionContext:(id)arg2 {
    %orig;

    if (hapticFeedbackEnabled) {
        [[[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight] impactOccurred];
    }
}

%end //hook UINavigationController

%end //group HapticFeedback


// %group SpotifySpecialHandling

//TODO

// %end //group SpotifySpecialHandling


void setDefaultBlacklistedApps() {
    NSArray* defaultBlacklistedApp = @[
        //already natively implemented
        @"com.atebits.Tweetie2",
        @"com.burbn.instagram",
        @"com.facebook.Facebook",
        @"com.christianselig.Apollo",
        @"ph.telegra.Telegraph",

        //gesture conflicts
        @"com.spotify.client" //adding song to the queue
    ];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:PLIST_FILE]) { //only on first install
        DLog(@"PLIST_FILE doesn't exists");

        NSMutableDictionary *plistDict = [[NSMutableDictionary alloc] init];

        for (NSString *blacklistedApp in defaultBlacklistedApp) {
            DLog(@"blacklisting app %@", blacklistedApp);
            [plistDict setValue:@"YES" forKey:blacklistedApp];
        }

        [plistDict writeToFile:PLIST_FILE atomically:YES];
    }
}

static BOOL appIsBlacklisted(NSString *appName) {
    return pref_getBool(appName);
}

static BOOL tweakShouldLoad() {
    // https://www.reddit.com/r/jailbreak/comments/4yz5v5/questionremote_messages_not_enabling/d6rlh88/
    BOOL shouldLoad = NO;
    NSArray *args = [[NSClassFromString(@"NSProcessInfo") processInfo] arguments];
    NSUInteger count = args.count;
    if (count != 0) {
        NSString *executablePath = args[0];
        if (executablePath) {
            NSString *processName = [executablePath lastPathComponent];
            DLog(@"Processname : %@", processName);
            BOOL isApplication = [executablePath rangeOfString:@"/Application/"].location != NSNotFound || [executablePath rangeOfString:@"/Applications/"].location != NSNotFound;
            // BOOL isSpringBoard = [processName isEqualToString:@"SpringBoard"];
            BOOL isFileProvider = [[processName lowercaseString] rangeOfString:@"fileprovider"].location != NSNotFound;
            BOOL skip = [processName isEqualToString:@"AdSheet"]
                        || [processName isEqualToString:@"CoreAuthUI"]
                        || [processName isEqualToString:@"InCallService"]
                        || [processName isEqualToString:@"MessagesNotificationViewService"]
                        || [processName isEqualToString:@"PassbookUIService"]
                        || [executablePath rangeOfString:@".appex/"].location != NSNotFound;
            if (!isFileProvider && isApplication && !skip) {
                shouldLoad = YES;
            }
        }
    }

    return shouldLoad;
}

%ctor {
    if (!tweakShouldLoad()) {
        NSLog(@"PanCake: shouldn't run in this process");
        return;
    }

    #ifndef SIMULATOR
    preferences = [[HBPreferences alloc] initWithIdentifier:@"com.anthopak.pancake"];
    [preferences registerBool:&enabled default:YES forKey:@"enabled"];
    [preferences registerBool:&hapticFeedbackEnabled default:YES forKey:@"hapticFeedbackEnabled"];
    #else
    enabled = YES;
    hapticFeedbackEnabled = YES;
    #endif
    setDefaultBlacklistedApps();

    if (enabled) {
        NSString *appName = [[NSBundle mainBundle] bundleIdentifier];
        if (appName && !appIsBlacklisted(appName)) {
            DLog(@"PanCake: Hooking app %@", appName);
        
            if ([appName isEqualToString:@"com.apple.MobileSMS"] || [appName isEqualToString:@"com.facebook.Messenger"]) {
                shouldRecognizeSimultaneousGestures = YES;
            }

            %init(PanCake);
        }
        
        //HapticFeedback is splitted so that it can be performed even in blacklisted apps
        if (hapticFeedbackEnabled) {
            %init(HapticFeedback);
        }
    }
}
