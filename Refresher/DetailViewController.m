#import "DetailViewController.h"

@interface DetailViewController ()

@property (nonatomic, strong) UILabel *detailDescriptionLabel;

@end

@implementation DetailViewController

- (void)setDetailItem:(id)detailItem
{
    if (_detailItem != detailItem) {
        _detailItem = detailItem;
        
        [self configureView];
    }
}

- (void)configureView
{
    if (self.detailItem) {
        self.detailDescriptionLabel.text = [self.detailItem description];
    }
}

- (UILabel *)detailDescriptionLabel
{
    if (!_detailDescriptionLabel) {
        
        _detailDescriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 280, 18)];
        _detailDescriptionLabel.center = self.view.center;
        _detailDescriptionLabel.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin  |
                                          UIViewAutoresizingFlexibleRightMargin |
                                          UIViewAutoresizingFlexibleTopMargin   |
                                          UIViewAutoresizingFlexibleBottomMargin);
        [_detailDescriptionLabel setTextAlignment:NSTextAlignmentCenter];
        [_detailDescriptionLabel setAccessibilityIdentifier:@"detailLabel"];
    }
    return _detailDescriptionLabel;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"Detail";
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.detailDescriptionLabel];
    [self configureView];
}


- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    self.detailDescriptionLabel.center = self.view.center;
}

@end
