#import "DetailViewController.h"

@interface DetailViewController ()

@property (nonatomic, strong) UILabel *detailDescriptionLabel;

@end

@implementation DetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)setDetailItem:(id)detailItem
{
    if (_detailItem != detailItem) {
        _detailItem = detailItem;
        
        // Update the view.
        [self configureView];
    }
}

- (void)configureView
{
    // Update the user interface for the detail item.
    
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
    
    
	// Do any additional setup after loading the view.
}


- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    self.detailDescriptionLabel.center = self.view.center;

}

@end
