#import "Preferences.h"

#define prefPath [NSString stringWithFormat:@"%@/Library/Preferences/%@", NSHomeDirectory(), @"com.anthopak.pancake.plist"]
#define headerColor [UIColor colorWithRed:0.192 green:0.298 blue:0.365 alpha:1]

static NSInteger headerPaddingTopBottom = 40;
static NSInteger headerPaddingLeftRight = 10;

@implementation PCPrefsListController

- (instancetype)init {
    self = [super init];

    if (self) {
        HBAppearanceSettings *appearanceSettings = [[HBAppearanceSettings alloc] init];
        // appearanceSettings.tintColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:1];
        appearanceSettings.tableViewCellSeparatorColor = [UIColor colorWithWhite:0 alpha:0];
        appearanceSettings.navigationBarBackgroundColor = [self getHeaderColorFromColor:headerColor];
        appearanceSettings.tintColor = headerColor;
        appearanceSettings.statusBarTintColor = [UIColor whiteColor];
        appearanceSettings.navigationBarTintColor = [UIColor whiteColor];
        appearanceSettings.navigationBarTitleColor = [UIColor whiteColor];
        self.hb_appearanceSettings = appearanceSettings;

        [self setupNavigationTitleView];
        [self setupNavigationRespringButton];
    }

    return self;
}

-(void) viewDidLoad {
    [super viewDidLoad];

    [self setupHeaderView];

    self.table.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    CGRect frame = self.table.bounds;
    frame.origin.y = -frame.size.height;

    self.navigationController.navigationController.navigationBar.barTintColor = [self getHeaderColorFromColor:headerColor];
    [self.navigationController.navigationController.navigationBar setShadowImage: [UIImage new]];
    self.navigationController.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    // self.navigationController.navigationController.navigationBar.translucent = NO;
}

- (id)specifiers {
    if(_specifiers == nil) {
        _specifiers = [[self loadSpecifiersFromPlistName:@"Prefs" target:self] retain];
    }
    return _specifiers;
}

- (void)respring:(id)sender {
    [HBRespringController respring];
}


#pragma mark - Header style
//Courtesy of Nepeta (Axon)

-(void) setupNavigationTitleView {
    self.navigationItem.titleView = [UIView new];
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,10,10)];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.titleLabel.text = @"PanCake";
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.navigationItem.titleView addSubview:self.titleLabel];

    self.iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,10,10)];
    self.iconView.contentMode = UIViewContentModeScaleAspectFit;
    self.iconView.image = [UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/PanCakePrefs.bundle/icon_transparent.png"];    
    self.iconView.translatesAutoresizingMaskIntoConstraints = NO;
    self.iconView.alpha = 0.0;
    [self.navigationItem.titleView addSubview:self.iconView];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.titleLabel.topAnchor constraintEqualToAnchor:self.navigationItem.titleView.topAnchor],
        [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.navigationItem.titleView.leadingAnchor],
        [self.titleLabel.trailingAnchor constraintEqualToAnchor:self.navigationItem.titleView.trailingAnchor],
        [self.titleLabel.bottomAnchor constraintEqualToAnchor:self.navigationItem.titleView.bottomAnchor],
        [self.iconView.topAnchor constraintEqualToAnchor:self.navigationItem.titleView.topAnchor],
        [self.iconView.leadingAnchor constraintEqualToAnchor:self.navigationItem.titleView.leadingAnchor],
        [self.iconView.trailingAnchor constraintEqualToAnchor:self.navigationItem.titleView.trailingAnchor],
        [self.iconView.bottomAnchor constraintEqualToAnchor:self.navigationItem.titleView.bottomAnchor],
    ]];
}

-(void) setupNavigationRespringButton {
    self.respringButton = [[UIBarButtonItem alloc] initWithTitle:@"Respring" 
                                style:UIBarButtonItemStylePlain
                                target:self 
                                action:@selector(respring:)];
    self.respringButton.tintColor = [UIColor whiteColor];
//    self.navigationItem.rightBarButtonItem = self.respringButton;
}

-(void) setupHeaderView {
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,200,200)];
    self.headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,200,200)];
    self.headerImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.headerImageView.image = [UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/PanCakePrefs.bundle/header.png"];
    self.headerImageView.translatesAutoresizingMaskIntoConstraints = NO;

    [self.headerView addSubview:self.headerImageView];
    [NSLayoutConstraint activateConstraints:@[
        [self.headerImageView.topAnchor constraintEqualToAnchor:self.headerView.topAnchor constant:headerPaddingTopBottom],
        [self.headerImageView.leadingAnchor constraintEqualToAnchor:self.headerView.leadingAnchor constant:headerPaddingLeftRight],
        [self.headerImageView.trailingAnchor constraintEqualToAnchor:self.headerView.trailingAnchor constant:-headerPaddingLeftRight],
        [self.headerImageView.bottomAnchor constraintEqualToAnchor:self.headerView.bottomAnchor constant:-headerPaddingTopBottom],
    ]];

    self.table.tableHeaderView = self.headerView;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetY = scrollView.contentOffset.y;

    if (offsetY > 70) {
        [UIView animateWithDuration:0.2 animations:^{
            self.iconView.alpha = 1.0;
            self.titleLabel.alpha = 0.0;
        }];
    } else {
        [UIView animateWithDuration:0.2 animations:^{
            self.iconView.alpha = 0.0;
            self.titleLabel.alpha = 1.0;
        }];
    }
    
    if (offsetY > -headerPaddingTopBottom/2) offsetY = -headerPaddingTopBottom/2; //have incidence on "padding bottom" under image while scrolling down
    self.headerImageView.frame = CGRectMake(headerPaddingLeftRight, offsetY + 64 + headerPaddingTopBottom, self.headerView.frame.size.width - headerPaddingLeftRight*2, 200 - offsetY - 64 - headerPaddingTopBottom*2);
}

- (double)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0 || section == 4) {
        return 0;
    } else if (section == 3) { //my other tweaks
        return 60;
    } else {
        return 45;
    }
}


- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
    [super setPreferenceValue:value specifier:specifier];
    
    NSMutableDictionary *preferences = [NSMutableDictionary dictionaryWithContentsOfFile:prefPath];

    NSString *key = [specifier propertyForKey:@"key"];

    if ([key isEqualToString:@"enabled"] || [key isEqualToString:@"hapticFeedbackEnabled"]) {
        self.navigationItem.rightBarButtonItem = self.respringButton;
    }

    [preferences setObject:value forKey:key];
    [preferences writeToFile:prefPath atomically:YES];
    CFStringRef post = (CFStringRef)CFBridgingRetain(specifier.properties[@"PostNotification"]);
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), post, NULL, NULL, YES);
}


#pragma mark - Misc

//"cancel" the alpha of the NavigationBar (https://stackoverflow.com/questions/437113/how-to-get-rgb-values-from-uicolor)
//Le but est d'obtenir la même couleur que celle passée en paramètre, sachant qu'elle sera utilisée avec un alpha (ce qui change la couleur)
-(UIColor*) getHeaderColorFromColor:(UIColor*)fromColor {
    CGFloat a1 = 0.85; //alpha of navbar
    //r1 = (r3 - r2 + r2*a1)/a1
    UIColor *backgroundColor = [UIColor whiteColor];
    CGFloat r2 = 0.0, g2 = 0.0, b2 = 0.0, a2 =0.0;
    [backgroundColor getRed:&r2 green:&g2 blue:&b2 alpha:&a2];

    CGFloat r3 = 0.0, g3 = 0.0, b3 = 0.0, a3 =0.0;
    [fromColor getRed:&r3 green:&g3 blue:&b3 alpha:&a3];

    CGFloat r1 = (r3 - r2 + r2 * a1) / a1;
    CGFloat g1 = (g3 - g2 + g2 * a1) / a1;
    CGFloat b1 = (b3 - b2 + b2 * a1) / a1;

    return [UIColor colorWithRed:r1 green:g1 blue:b1 alpha:1];
}

@end