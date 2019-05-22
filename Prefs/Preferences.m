#import "Preferences.h"

@implementation PCPrefsListController

- (instancetype)init {
    self = [super init];

    if (self) {
        HBAppearanceSettings *appearanceSettings = [[HBAppearanceSettings alloc] init];
        appearanceSettings.tintColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:1];
        appearanceSettings.tableViewCellSeparatorColor = [UIColor colorWithWhite:0 alpha:0];
        self.hb_appearanceSettings = appearanceSettings;

        if ([[NSFileManager defaultManager] fileExistsAtPath:@"/var/lib/dpkg/info/com.anthopak.pancake.list"]) {
            NSLog(@"PanCake: Official tweak source (y)");
        } else {
            NSLog(@"PanCake: Hello cracker!");
        }
    }

    return self;
}

- (id)specifiers {
    if(_specifiers == nil) {
        _specifiers = [[self loadSpecifiersFromPlistName:@"Prefs" target:self] retain];
    }
    return _specifiers;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

    CGRect frame = self.table.bounds;
    frame.origin.y = -frame.size.height;
	
    [self.navigationController.navigationController.navigationBar setShadowImage: [UIImage new]];
    self.navigationController.navigationController.navigationBar.translucent = YES;
}

// - (void)respring:(id)sender {
//     NSTask *t = [[[NSTask alloc] init] autorelease];
//     [t setLaunchPath:@"/usr/bin/killall"];
//     [t setArguments:[NSArray arrayWithObjects:@"backboardd", nil]];
//     [t launch];
// }
@end