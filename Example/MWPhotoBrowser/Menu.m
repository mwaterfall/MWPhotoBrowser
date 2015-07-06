//
//  Menu.m
//  MWPhotoBrowser
//
//  Created by Michael Waterfall on 21/10/2010.
//  Copyright 2010 d3i. All rights reserved.
//

#import <Photos/Photos.h>
#import "Menu.h"
#import "SDImageCache.h"
#import "MWCommon.h"

@implementation Menu

#pragma mark -
#pragma mark Initialization

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
		self.title = @"MWPhotoBrowser";
        
        // Clear cache for testing
        [[SDImageCache sharedImageCache] clearDisk];
        [[SDImageCache sharedImageCache] clearMemory];
        
        _segmentedControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Push", @"Modal", nil]];
        _segmentedControl.selectedSegmentIndex = 0;
        [_segmentedControl addTarget:self action:@selector(segmentChange) forControlEvents:UIControlEventValueChanged];
        
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:_segmentedControl];
        self.navigationItem.rightBarButtonItem = item;
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:nil action:nil];

        [self loadAssets];
        
    }
    return self;
}

- (void)segmentChange {
    [self.tableView reloadData];
}


#pragma mark -
#pragma mark View

- (void)viewDidLoad {
    [super viewDidLoad];
    // Test toolbar hiding
//    [self setToolbarItems: @[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:nil action:nil]]];
//    [[self navigationController] setToolbarHidden:NO animated:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    self.navigationController.navigationBar.barTintColor = [UIColor greenColor];
//    self.navigationController.navigationBar.translucent = NO;
//    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
//    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationNone;
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows = 7;
    @synchronized(_assets) {
        if (_assets.count) rows++;
    }
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	// Create
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    cell.accessoryType = _segmentedControl.selectedSegmentIndex == 0 ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;

    // Configure
	switch (indexPath.row) {
		case 0: {
            cell.textLabel.text = @"Single photo";
            cell.detailTextLabel.text = @"with caption, no grid button";
            break;
        }
		case 1: {
            cell.textLabel.text = @"Multiple photos";
            cell.detailTextLabel.text = @"with captions";
            break;
        }
		case 2: {
            cell.textLabel.text = @"Multiple photo grid";
            cell.detailTextLabel.text = @"showing grid first, nav arrows enabled";
            break;
        }
		case 3: {
            cell.textLabel.text = @"Photo selections";
            cell.detailTextLabel.text = @"selection enabled";
            break;
        }
		case 4: {
            cell.textLabel.text = @"Photo selection grid";
            cell.detailTextLabel.text = @"selection enabled, start at grid";
            break;
        }
		case 5: {
            cell.textLabel.text = @"Web photos";
            cell.detailTextLabel.text = @"photos from web";
            break;
        }
		case 6: {
            cell.textLabel.text = @"Web photo grid";
            cell.detailTextLabel.text = @"showing grid first";
            break;
        }
		case 7: {
            cell.textLabel.text = @"Library photos";
            cell.detailTextLabel.text = @"photos from device library";
            break;
        }
		default: break;
	}
    return cell;
	
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	// Browser
	NSMutableArray *photos = [[NSMutableArray alloc] init];
	NSMutableArray *thumbs = [[NSMutableArray alloc] init];
    MWPhoto *photo;
    BOOL displayActionButton = YES;
    BOOL displaySelectionButtons = NO;
    BOOL displayNavArrows = NO;
    BOOL enableGrid = YES;
    BOOL startOnGrid = NO;
	switch (indexPath.row) {
		case 0:
            // Photos
            photo = [MWPhoto photoWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"photo2" ofType:@"jpg"]]];
            photo.caption = @"The London Eye is a giant Ferris wheel situated on the banks of the River Thames, in London, England.";
			[photos addObject:photo];
            // Options
            enableGrid = NO;
			break;
		case 1: {
            // Photos
            photo = [MWPhoto photoWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"photo5" ofType:@"jpg"]]];
            photo.caption = @"Fireworks";
			[photos addObject:photo];
            photo = [MWPhoto photoWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"photo2" ofType:@"jpg"]]];
            photo.caption = @"The London Eye is a giant Ferris wheel situated on the banks of the River Thames, in London, England.";
			[photos addObject:photo];
            photo = [MWPhoto photoWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"photo3" ofType:@"jpg"]]];
            photo.caption = @"York Floods";
			[photos addObject:photo];
            photo = [MWPhoto photoWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"photo4" ofType:@"jpg"]]];
            photo.caption = @"Campervan";
			[photos addObject:photo];
            // Options
            enableGrid = NO;
			break;
        }
		case 2: {
            // Photos
            photo = [MWPhoto photoWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"photo5" ofType:@"jpg"]]];
            photo.caption = @"White Tower";
			[photos addObject:photo];
            photo = [MWPhoto photoWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"photo2" ofType:@"jpg"]]];
            photo.caption = @"The London Eye is a giant Ferris wheel situated on the banks of the River Thames, in London, England.";
			[photos addObject:photo];
            photo = [MWPhoto photoWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"photo3" ofType:@"jpg"]]];
            photo.caption = @"York Floods";
			[photos addObject:photo];
            photo = [MWPhoto photoWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"photo4" ofType:@"jpg"]]];
            photo.caption = @"Campervan";
			[photos addObject:photo];
            // Thumbs
            photo = [MWPhoto photoWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"photo5t" ofType:@"jpg"]]];
			[thumbs addObject:photo];
            photo = [MWPhoto photoWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"photo2t" ofType:@"jpg"]]];
			[thumbs addObject:photo];
            photo = [MWPhoto photoWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"photo3t" ofType:@"jpg"]]];
			[thumbs addObject:photo];
            photo = [MWPhoto photoWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"photo4t" ofType:@"jpg"]]];
			[thumbs addObject:photo];
            // Options
            startOnGrid = YES;
            displayNavArrows = YES;
			break;
        }
		case 3:
		case 4: {
            // Photos
            photo = [MWPhoto photoWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"photo4" ofType:@"jpg"]]];
			[photos addObject:photo];
            photo = [MWPhoto photoWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"photo1" ofType:@"jpg"]]];
			[photos addObject:photo];
            photo = [MWPhoto photoWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"photo2" ofType:@"jpg"]]];
			[photos addObject:photo];
            photo = [MWPhoto photoWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"photo3" ofType:@"jpg"]]];
			[photos addObject:photo];
            // Thumbs
            photo = [MWPhoto photoWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"photo4t" ofType:@"jpg"]]];
			[thumbs addObject:photo];
            photo = [MWPhoto photoWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"photo1t" ofType:@"jpg"]]];
			[thumbs addObject:photo];
            photo = [MWPhoto photoWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"photo2t" ofType:@"jpg"]]];
			[thumbs addObject:photo];
            photo = [MWPhoto photoWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"photo3t" ofType:@"jpg"]]];
			[thumbs addObject:photo];
            // Options
            displayActionButton = NO;
            displaySelectionButtons = YES;
            startOnGrid = indexPath.row == 4;
            enableGrid = NO;
			break;
        }
		case 5:
            // Photos
			[photos addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3567/3523321514_371d9ac42f_b.jpg"]]];
			[photos addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3629/3339128908_7aecabc34b_b.jpg"]]];
			[photos addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3364/3338617424_7ff836d55f_b.jpg"]]];
			[photos addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3590/3329114220_5fbc5bc92b_b.jpg"]]];
			[photos addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm3.static.flickr.com/2449/4052876281_6e068ac860_b.jpg"]]];
            // Thumbs
			[thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3567/3523321514_371d9ac42f_q.jpg"]]];
			[thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3629/3339128908_7aecabc34b_q.jpg"]]];
			[thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3364/3338617424_7ff836d55f_q.jpg"]]];
			[thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3590/3329114220_5fbc5bc92b_q.jpg"]]];
			[thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm3.static.flickr.com/2449/4052876281_6e068ac860_q.jpg"]]];
            // Options
			break;
		case 6:
            // Photos & thumbs
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3779/9522424255_28a5a9d99c_b.jpg"]];
            photo.caption = @"Tube";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3779/9522424255_28a5a9d99c_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3777/9522276829_fdea08ffe2_b.jpg"]];
            photo.caption = @"Flat White at Elliot's";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3777/9522276829_fdea08ffe2_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm9.static.flickr.com/8379/8530199945_47b386320f_b.jpg"]];
            photo.caption = @"Woburn Abbey";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm9.static.flickr.com/8379/8530199945_47b386320f_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm9.static.flickr.com/8364/8268120482_332d61a89e_b.jpg"]];
            photo.caption = @"Frosty walk";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm9.static.flickr.com/8364/8268120482_332d61a89e_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm8.static.flickr.com/7109/7604416018_f23733881b_b.jpg"]];
            photo.caption = @"Jury's Inn";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm8.static.flickr.com/7109/7604416018_f23733881b_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm7.static.flickr.com/6002/6020924733_b21874f14c_b.jpg"]];
            photo.caption = @"Heavy Rain";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm7.static.flickr.com/6002/6020924733_b21874f14c_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm5.static.flickr.com/4012/4501918517_5facf1a8c4_b.jpg"]];
            photo.caption = @"iPad Application Sketch Template v1";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm5.static.flickr.com/4012/4501918517_5facf1a8c4_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm3.static.flickr.com/2667/4072710001_f36316ddc7_b.jpg"]];
            photo.caption = @"Grotto of the Madonna";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm3.static.flickr.com/2667/4072710001_f36316ddc7_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm3.static.flickr.com/2449/4052876281_6e068ac860_b.jpg"]];
            photo.caption = @"Beautiful Eyes";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm3.static.flickr.com/2449/4052876281_6e068ac860_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3528/4052875665_53e5b4dc61_b.jpg"]];
            photo.caption = @"Cousin Portrait";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3528/4052875665_53e5b4dc61_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3520/3846053408_6ecf775a3e_b.jpg"]];
            photo.caption = @"iPhone Application Sketch Template v1.3";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3520/3846053408_6ecf775a3e_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3624/3559209373_003152b4fd_b.jpg"]];
            photo.caption = @"Door Knocker of Capitanía General";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3624/3559209373_003152b4fd_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3551/3523421738_30455b63e0_b.jpg"]];
            photo.caption = @"Parroquia Sta Maria del Mar";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3551/3523421738_30455b63e0_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3224/3523355044_6551552f93_b.jpg"]];
            photo.caption = @"Central Atrium in Casa Batlló";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3224/3523355044_6551552f93_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3567/3523321514_371d9ac42f_b.jpg"]];
            photo.caption = @"Gaudí's Casa Batlló spiral ceiling";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3567/3523321514_371d9ac42f_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3629/3339128908_7aecabc34b_b.jpg"]];
            photo.caption = @"The Royal Albert Hall";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3629/3339128908_7aecabc34b_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3338/3339119002_e0d8ec2f2e_b.jpg"]];
            photo.caption = @"Midday & Midnight at the RAH";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3338/3339119002_e0d8ec2f2e_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3364/3338617424_7ff836d55f_b.jpg"]];
            photo.caption = @"Westminster Bridge";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3364/3338617424_7ff836d55f_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3604/3328356821_5503b332aa_b.jpg"]];
            photo.caption = @"Prime Meridian Sculpture";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3604/3328356821_5503b332aa_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3590/3329114220_5fbc5bc92b_b.jpg"]];
            photo.caption = @"Docklands";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3590/3329114220_5fbc5bc92b_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3602/3329107762_64a1454080_b.jpg"]];
            photo.caption = @"Planetarium";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3602/3329107762_64a1454080_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3122/3143635211_80b29ab354_b.jpg"]];
            photo.caption = @"Eurostar Perspective";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3122/3143635211_80b29ab354_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3091/3144451298_db6f6da3f9_b.jpg"]];
            photo.caption = @"The Meeting Place";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3091/3144451298_db6f6da3f9_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3110/3143623585_a12fa172fc_b.jpg"]];
            photo.caption = @"Embrace";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3110/3143623585_a12fa172fc_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3107/3143613445_d9562105ea_b.jpg"]];
            photo.caption = @"See to the Sky with the Station Saver";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3107/3143613445_d9562105ea_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3203/3144431930_db55ee05a2_b.jpg"]];
            photo.caption = @"Sir John Betjeman";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3203/3144431930_db55ee05a2_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3102/3143588227_5d0d806b43_b.jpg"]];
            photo.caption = @"St Pancras, London";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3102/3143588227_5d0d806b43_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3194/2987143528_2ee4a9e3cc_b.jpg"]];
            photo.caption = @"Shelter from the Storm";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3194/2987143528_2ee4a9e3cc_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3219/2983541189_467dc559ed_b.jpg"]];
            photo.caption = @"Alexander, Molly & George";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3219/2983541189_467dc559ed_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3277/2978593618_25a24b5348_b.jpg"]];
            photo.caption = @"It's Eerie Underground";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3277/2978593618_25a24b5348_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3043/2977609977_241fe844be_b.jpg"]];
            photo.caption = @"VW Camper";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3043/2977609977_241fe844be_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3257/2871822885_890c7d969d_b.jpg"]];
            photo.caption = @"York Floods - September 2008";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3257/2871822885_890c7d969d_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3170/2860137277_ecefb94bb9_b.jpg"]];
            photo.caption = @"Still Standing";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3170/2860137277_ecefb94bb9_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3209/2799943935_81840a6dcc_b.jpg"]];
            photo.caption = @"The Edge of the World";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3209/2799943935_81840a6dcc_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3269/2800788836_8ae7c988a9_b.jpg"]];
            photo.caption = @"Beautiful Bark";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3269/2800788836_8ae7c988a9_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3080/2800766694_5c87a0238c_b.jpg"]];
            photo.caption = @"What's the name of this flower?";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3080/2800766694_5c87a0238c_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3110/2799879647_f9ee50054e_b.jpg"]];
            photo.caption = @"Flamborough Lighthouse";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3110/2799879647_f9ee50054e_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3176/2575404273_6f2f135801_b.jpg"]];
            photo.caption = @"Looking into London's Eye";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3176/2575404273_6f2f135801_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3147/2575402639_3e1e60a0e7_b.jpg"]];
            photo.caption = @"Large Ben";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3147/2575402639_3e1e60a0e7_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3002/2576229168_276565ac08_b.jpg"]];
            photo.caption = @"The Leaning Tower of London";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3002/2576229168_276565ac08_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3290/2530710337_90d3160da0_b.jpg"]];
            photo.caption = @"Monkey Features";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3290/2530710337_90d3160da0_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm3.static.flickr.com/2342/2499163392_0c8125cbf7_b.jpg"]];
            photo.caption = @"Metal and Stone";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm3.static.flickr.com/2342/2499163392_0c8125cbf7_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3241/2499162188_1097d7280f_b.jpg"]];
            photo.caption = @"York Minster Interior";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3241/2499162188_1097d7280f_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3162/2499161250_4100c907ee_b.jpg"]];
            photo.caption = @"Colour Below a Heart";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3162/2499161250_4100c907ee_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm3.static.flickr.com/2411/2386560315_c0b237ed0e_b.jpg"]];
            photo.caption = @"Tremendous Tulip";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm3.static.flickr.com/2411/2386560315_c0b237ed0e_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm3.static.flickr.com/2140/2375307082_ea04b45d8f_b.jpg"]];
            photo.caption = @"Rose Reflection";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm3.static.flickr.com/2140/2375307082_ea04b45d8f_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3035/2375304830_e894d29141_b.jpg"]];
            photo.caption = @"Cliffords Tower, York";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3035/2375304830_e894d29141_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3197/2367543868_af828a6543_b.jpg"]];
            photo.caption = @"Cog & Chain";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3197/2367543868_af828a6543_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm3.static.flickr.com/2286/2367542014_6d8145711c_b.jpg"]];
            photo.caption = @"Rocket";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm3.static.flickr.com/2286/2367542014_6d8145711c_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3217/2323979971_3a6209b41e_b.jpg"]];
            photo.caption = @"Snowdrops";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3217/2323979971_3a6209b41e_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3182/2324797228_dec69be7b4_b.jpg"]];
            photo.caption = @"Castle Howard Fountain";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3182/2324797228_dec69be7b4_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm3.static.flickr.com/2266/2323974229_e21e0e3fe1_b.jpg"]];
            photo.caption = @"Castle Howard House Lines";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm3.static.flickr.com/2266/2323974229_e21e0e3fe1_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3018/2323969673_e6d9cc74d7_b.jpg"]];
            photo.caption = @"Castle Howard Wide";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3018/2323969673_e6d9cc74d7_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3103/2323967485_694a897d5f_b.jpg"]];
            photo.caption = @"Castle Howard House";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3103/2323967485_694a897d5f_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3086/2324784818_8cd6123633_b.jpg"]];
            photo.caption = @"Castle Howard Fountain";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3086/2324784818_8cd6123633_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm3.static.flickr.com/2318/2324783136_56bed1f7ab_b.jpg"]];
            photo.caption = @"Castle Howard House Back";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm3.static.flickr.com/2318/2324783136_56bed1f7ab_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm3.static.flickr.com/2228/2323959487_113c1c26fe_b.jpg"]];
            photo.caption = @"Castle Howard House Side";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm3.static.flickr.com/2228/2323959487_113c1c26fe_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3058/2324776658_da476bbb32_b.jpg"]];
            photo.caption = @"Castle Howard";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3058/2324776658_da476bbb32_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm3.static.flickr.com/2359/2323944883_a277e1becf_b.jpg"]];
            photo.caption = @"Peacock";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm3.static.flickr.com/2359/2323944883_a277e1becf_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm3.static.flickr.com/2172/2323940209_ae2d69fb51_b.jpg"]];
            photo.caption = @"Castle Howard Fountain";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm3.static.flickr.com/2172/2323940209_ae2d69fb51_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm3.static.flickr.com/2143/2268578601_464af2fabc_b.jpg"]];
            photo.caption = @"Outlook";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm3.static.flickr.com/2143/2268578601_464af2fabc_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm3.static.flickr.com/2165/2268575867_d3c1bc5b65_b.jpg"]];
            photo.caption = @"Stones & Sand";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm3.static.flickr.com/2165/2268575867_d3c1bc5b65_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm3.static.flickr.com/2149/2269364904_bc4a63f3e0_b.jpg"]];
            photo.caption = @"Pebbles and Stones";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm3.static.flickr.com/2149/2269364904_bc4a63f3e0_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm3.static.flickr.com/2176/2268569547_99197322f9_b.jpg"]];
            photo.caption = @"Fisherman";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm3.static.flickr.com/2176/2268569547_99197322f9_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm3.static.flickr.com/2095/2268567981_ac142a0409_b.jpg"]];
            photo.caption = @"Walking on Water";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm3.static.flickr.com/2095/2268567981_ac142a0409_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm3.static.flickr.com/2074/2268528659_e7f1d60e8f_b.jpg"]];
            photo.caption = @"Viking Boat York";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm3.static.flickr.com/2074/2268528659_e7f1d60e8f_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm3.static.flickr.com/2326/2268524733_5f40d784d4_b.jpg"]];
            photo.caption = @"Hot Air Balloon Colours";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm3.static.flickr.com/2326/2268524733_5f40d784d4_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm3.static.flickr.com/2022/2268522293_470659cdec_b.jpg"]];
            photo.caption = @"Hot Air Balloon Lift Off";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm3.static.flickr.com/2022/2268522293_470659cdec_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm3.static.flickr.com/2420/2268520049_d33bb30b6f_b.jpg"]];
            photo.caption = @"Hot Air Balloon Take Off";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm3.static.flickr.com/2420/2268520049_d33bb30b6f_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm3.static.flickr.com/2403/2269308580_24e5e8cb1d_b.jpg"]];
            photo.caption = @"Hot Air Balloon High";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm3.static.flickr.com/2403/2269308580_24e5e8cb1d_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm3.static.flickr.com/2040/2268515857_7708793db8_b.jpg"]];
            photo.caption = @"Hot Air Balloon Blue Sky";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm3.static.flickr.com/2040/2268515857_7708793db8_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm3.static.flickr.com/2176/2137556633_ce7f55d97c_b.jpg"]];
            photo.caption = @"Christmas Lights";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm3.static.flickr.com/2176/2137556633_ce7f55d97c_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm3.static.flickr.com/2256/2138335766_532c98183b_b.jpg"]];
            photo.caption = @"Christmas Dinner";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm3.static.flickr.com/2256/2138335766_532c98183b_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm3.static.flickr.com/2309/2137552857_b3a866d66a_b.jpg"]];
            photo.caption = @"Christmas Tree";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm3.static.flickr.com/2309/2137552857_b3a866d66a_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm3.static.flickr.com/2151/2137550333_30a80de9dd_b.jpg"]];
            photo.caption = @"Christmas Gifts";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm3.static.flickr.com/2151/2137550333_30a80de9dd_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm3.static.flickr.com/2217/1800632013_f5b6f430ea_b.jpg"]];
            photo.caption = @"Firework Flower";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm3.static.flickr.com/2217/1800632013_f5b6f430ea_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm3.static.flickr.com/2025/1800630921_05c119b257_b.jpg"]];
            photo.caption = @"Fireworks 1";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm3.static.flickr.com/2025/1800630921_05c119b257_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm3.static.flickr.com/2283/1800622021_a69274fe8e_b.jpg"]];
            photo.caption = @"Sunset";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm3.static.flickr.com/2283/1800622021_a69274fe8e_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm3.static.flickr.com/2296/1800493695_05e8f99119_b.jpg"]];
            photo.caption = @"Morning Fields";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm3.static.flickr.com/2296/1800493695_05e8f99119_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1318/1258684849_5423b2b0a7_b.jpg"]];
            photo.caption = @"Garden Window";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1318/1258684849_5423b2b0a7_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1169/1214182813_92ef4b864e_b.jpg"]];
            photo.caption = @"Storm Clouds";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1169/1214182813_92ef4b864e_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1060/1214995776_c6ccc7b589_b.jpg"]];
            photo.caption = @"South Light";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1060/1214995776_c6ccc7b589_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1271/1213967453_8f5927b62a_b.jpg"]];
            photo.caption = @"Cala Gal Dana, Panoramic";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1271/1213967453_8f5927b62a_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1052/1214735762_1fa7af8cf9_b.jpg"]];
            photo.caption = @"Coloured Glass";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1052/1214735762_1fa7af8cf9_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1108/1214725784_392c7236cb_b.jpg"]];
            photo.caption = @"Well";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1108/1214725784_392c7236cb_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1261/1214721656_3e50b51adb_b.jpg"]];
            photo.caption = @"Ciutadella";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1261/1214721656_3e50b51adb_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1422/1213857765_dd59feadff_b.jpg"]];
            photo.caption = @"Columbus";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1422/1213857765_dd59feadff_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1075/1214720084_9ec6163320_b.jpg"]];
            photo.caption = @"Watch Tower";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1075/1214720084_9ec6163320_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1413/1213849449_689f6c5b34_b.jpg"]];
            photo.caption = @"White Tower";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1413/1213849449_689f6c5b34_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1310/1213846529_9a1fc08f0f_b.jpg"]];
            photo.caption = @"White & Blue";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1310/1213846529_9a1fc08f0f_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1320/1213843939_6f5594ffca_b.jpg"]];
            photo.caption = @"Jesus, Monte Toro";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1320/1213843939_6f5594ffca_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1290/1213774167_804edea2a8_b.jpg"]];
            photo.caption = @"York Minster";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1290/1213774167_804edea2a8_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1340/1214632114_7587edf8dc_b.jpg"]];
            photo.caption = @"York Minster";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1340/1214632114_7587edf8dc_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1126/1213763123_b2e0ad8954_b.jpg"]];
            photo.caption = @"York Minster";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1126/1213763123_b2e0ad8954_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1157/1213707107_43444cf13b_b.jpg"]];
            photo.caption = @"Water Plant";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1157/1213707107_43444cf13b_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1033/1082797343_87d812258f_b.jpg"]];
            photo.caption = @"Micklegate, York";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1033/1082797343_87d812258f_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1106/1083643878_f9082c3f58_b.jpg"]];
            photo.caption = @"Tea Rooms";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1106/1083643878_f9082c3f58_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1188/1082780169_3d189a56d5_b.jpg"]];
            photo.caption = @"York Minster";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1188/1082780169_3d189a56d5_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1274/1083627286_9bb558047b_b.jpg"]];
            photo.caption = @"Constantine";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1274/1083627286_9bb558047b_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1276/1082759563_41eb4412d7_b.jpg"]];
            photo.caption = @"York Minster";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1276/1082759563_41eb4412d7_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1326/1082740813_e6c9b5fc87_b.jpg"]];
            photo.caption = @"I Do";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1326/1082740813_e6c9b5fc87_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1407/1083588060_c10e3abcb3_b.jpg"]];
            photo.caption = @"Hanging Basket";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1407/1083588060_c10e3abcb3_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1268/1083499110_80bfba3a27_b.jpg"]];
            photo.caption = @"Hover Fly";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1268/1083499110_80bfba3a27_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1022/1082562763_03ac6b462a_b.jpg"]];
            photo.caption = @"Pylon";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1022/1082562763_03ac6b462a_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1154/1083348824_790abf6c45_b.jpg"]];
            photo.caption = @"Drenched Cars";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1154/1083348824_790abf6c45_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1356/1082760752_204933b13c_b.jpg"]];
            photo.caption = @"Wedding Cake";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1356/1082760752_204933b13c_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1310/1081997284_f45d03e3e9_b.jpg"]];
            photo.caption = @"Wedding Rings";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1310/1081997284_f45d03e3e9_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1235/1080940411_1dbfd6e577_b.jpg"]];
            photo.caption = @"Brides Mother";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1235/1080940411_1dbfd6e577_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1352/1041732121_d1a1dab44b_b.jpg"]];
            photo.caption = @"Wedding Roses";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1352/1041732121_d1a1dab44b_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1246/1041698487_fd91c19893_b.jpg"]];
            photo.caption = @"Butterfly Bridesmaid";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1246/1041698487_fd91c19893_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1168/1042508712_877068e029_b.jpg"]];
            photo.caption = @"Bridesmaid Stairs";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1168/1042508712_877068e029_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1406/1037917833_087badcaaf_b.jpg"]];
            photo.caption = @"Red & White Night";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1406/1037917833_087badcaaf_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1202/1037911739_a2d684d0d3_b.jpg"]];
            photo.caption = @"Red & White Night Portrait";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1202/1037911739_a2d684d0d3_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1336/1038760638_42b348543d_b.jpg"]];
            photo.caption = @"Red & White Night Sign";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1336/1038760638_42b348543d_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1182/1038749330_6eeceea376_b.jpg"]];
            photo.caption = @"White Whip Light";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1182/1038749330_6eeceea376_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1121/1038747138_ed4388600e_b.jpg"]];
            photo.caption = @"Red Long Exp";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1121/1038747138_ed4388600e_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1174/1037890363_5918979b27_b.jpg"]];
            photo.caption = @"M6 Sign";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1174/1037890363_5918979b27_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1160/1037797119_e535914f06_b.jpg"]];
            photo.caption = @"Sunlit Leaf";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1160/1037797119_e535914f06_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1037/1037789909_d320b9d759_b.jpg"]];
            photo.caption = @"Water Covered Leaf";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1037/1037789909_d320b9d759_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1293/1037658807_048f125b28_b.jpg"]];
            photo.caption = @"Transparent Light Leaf";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1293/1037658807_048f125b28_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1111/1038457510_2aa6edc766_b.jpg"]];
            photo.caption = @"Winter Nettle";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1111/1038457510_2aa6edc766_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1418/1037593249_87a705a0e9_b.jpg"]];
            photo.caption = @"Frost Edged Leaf";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1418/1037593249_87a705a0e9_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1416/1038320230_14bb31307c_b.jpg"]];
            photo.caption = @"Large Sunset";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1416/1038320230_14bb31307c_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1382/1038307382_19d06a3c7f_b.jpg"]];
            photo.caption = @"Band Stand at Night";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1382/1038307382_19d06a3c7f_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1187/1037444897_9c6bb617bd_b.jpg"]];
            photo.caption = @"Stafford Street at Night";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1187/1037444897_9c6bb617bd_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1235/1020112582_892713cc72_b.jpg"]];
            photo.caption = @"Villa";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1235/1020112582_892713cc72_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1438/1019238601_78d489ab5d_b.jpg"]];
            photo.caption = @"Offshore Silhouette 2";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1438/1019238601_78d489ab5d_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1234/1020080322_572763d9f1_b.jpg"]];
            photo.caption = @"Perfect Circle";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1234/1020080322_572763d9f1_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1016/1019200909_574df6bf54_b.jpg"]];
            photo.caption = @"VW Golf";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1016/1019200909_574df6bf54_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1114/1020056296_c4dc0d50b1_b.jpg"]];
            photo.caption = @"Spanish Villa House";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1114/1020056296_c4dc0d50b1_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1197/1020049432_4db0f8efd5_b.jpg"]];
            photo.caption = @"Bend in the Road";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1197/1020049432_4db0f8efd5_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1189/1020036286_f8cf41ac69_b.jpg"]];
            photo.caption = @"DoF Blue Chair";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1189/1020036286_f8cf41ac69_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1267/1019167123_e55e1bc56f_b.jpg"]];
            photo.caption = @"Villa";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1267/1019167123_e55e1bc56f_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1116/1019157385_8faf3e3573_b.jpg"]];
            photo.caption = @"Yellow Flower";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1116/1019157385_8faf3e3573_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1191/1019151951_774b7b5402_b.jpg"]];
            photo.caption = @"Villa";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1191/1019151951_774b7b5402_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1363/1019139793_b55ce199d0_b.jpg"]];
            photo.caption = @"Luxury Spa at La Manga Club";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1363/1019139793_b55ce199d0_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1038/1019127559_0d0a57733f_b.jpg"]];
            photo.caption = @"Lonely Boat";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1038/1019127559_0d0a57733f_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1329/1019973422_b575f4961c_b.jpg"]];
            photo.caption = @"Garden Chair";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1329/1019973422_b575f4961c_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1168/1019745098_545403ede6_b.jpg"]];
            photo.caption = @"Rust for Sale!";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1168/1019745098_545403ede6_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1394/1019735146_8875d55079_b.jpg"]];
            photo.caption = @"Safety";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1394/1019735146_8875d55079_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1223/1019727992_af62bf470d_b.jpg"]];
            photo.caption = @"Monster VW";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1223/1019727992_af62bf470d_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1297/1019721148_796385dcb6_b.jpg"]];
            photo.caption = @"Yeah it is!";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1297/1019721148_796385dcb6_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1093/1018853687_a162a984ca_b.jpg"]];
            photo.caption = @"VDub Little Buggers Club";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1093/1018853687_a162a984ca_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1069/1018846077_9576590764_b.jpg"]];
            photo.caption = @"Shiny Alloys";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1069/1018846077_9576590764_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1229/1018838599_3f581eb852_b.jpg"]];
            photo.caption = @"VW Headlights";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1229/1018838599_3f581eb852_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1187/1018830961_a4f97ea5a7_b.jpg"]];
            photo.caption = @"VW Vinyl";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1187/1018830961_a4f97ea5a7_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1224/1019677202_116cc992e5_b.jpg"]];
            photo.caption = @"VW Dude";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1224/1019677202_116cc992e5_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1207/1019670340_a6268b294a_b.jpg"]];
            photo.caption = @"Large VW Logo";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1207/1019670340_a6268b294a_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1275/1018793735_a4172e3675_b.jpg"]];
            photo.caption = @"IMG_1781";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1275/1018793735_a4172e3675_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1129/1018777423_1238c3249a_b.jpg"]];
            photo.caption = @"IMG_1770";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1129/1018777423_1238c3249a_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1144/1019556448_4cd8a965f5_b.jpg"]];
            photo.caption = @"Piano DoF";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1144/1019556448_4cd8a965f5_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1373/1018689833_03ae27b7c9_b.jpg"]];
            photo.caption = @"Festive Ice";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1373/1018689833_03ae27b7c9_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1132/1019542722_3723ac58f2_b.jpg"]];
            photo.caption = @"Festivities";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1132/1019542722_3723ac58f2_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1162/1019517888_7982bcd84f_b.jpg"]];
            photo.caption = @"Christmas Lights";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1162/1019517888_7982bcd84f_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1081/1019239012_d174b5daf3_b.jpg"]];
            photo.caption = @"Water Steps";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1081/1019239012_d174b5daf3_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1241/1019218632_10255f1d43_b.jpg"]];
            photo.caption = @"Water Steps Frozen in Time";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1241/1019218632_10255f1d43_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1029/1018206545_6e8e0ec1e5_b.jpg"]];
            photo.caption = @"Daffo your Dill";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1029/1018206545_6e8e0ec1e5_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1261/1018910192_48fe1f5b6b_b.jpg"]];
            photo.caption = @"Cock";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1261/1018910192_48fe1f5b6b_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1228/1017960551_1a3d1b0a9c_b.jpg"]];
            photo.caption = @"Fountain CU";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1228/1017960551_1a3d1b0a9c_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1077/1017926975_1c9e8953e3_b.jpg"]];
            photo.caption = @"Chatsworth";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1077/1017926975_1c9e8953e3_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1213/1018743552_7d0c410416_b.jpg"]];
            photo.caption = @"Gardins";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1213/1018743552_7d0c410416_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1342/1017867885_5e90984ce5_b.jpg"]];
            photo.caption = @"Water Sun Steps";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1342/1017867885_5e90984ce5_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1047/1018622228_056b0dfcbf_b.jpg"]];
            photo.caption = @"Daffodil CU";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1047/1018622228_056b0dfcbf_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1415/1018615064_937b34cca7_b.jpg"]];
            photo.caption = @"Twin Daffodil";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1415/1018615064_937b34cca7_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1436/1017097897_73a265e346_b.jpg"]];
            photo.caption = @"Bird Sculpture";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1436/1017097897_73a265e346_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1004/1017051687_e281a77270_b.jpg"]];
            photo.caption = @"Flower with Water Drops";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1004/1017051687_e281a77270_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1150/1017031825_53ba6f6ab9_b.jpg"]];
            photo.caption = @"Bats";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1150/1017031825_53ba6f6ab9_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1381/1017008087_c0eb892b47_b.jpg"]];
            photo.caption = @"Stream Slow";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1381/1017008087_c0eb892b47_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1067/1017708680_82a427f18e_b.jpg"]];
            photo.caption = @"Dog Sculpture";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1067/1017708680_82a427f18e_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1438/1016801251_4817ff3b67_b.jpg"]];
            photo.caption = @"Beads of Water on Grass";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1438/1016801251_4817ff3b67_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1398/1017654416_d9e7ad4370_b.jpg"]];
            photo.caption = @"Beads of Water on Grass CU";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1398/1017654416_d9e7ad4370_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1035/1011726328_79c46b6af3_b.jpg"]];
            photo.caption = @"Global Fence";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1035/1011726328_79c46b6af3_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1129/1011721614_8a5de7701c_b.jpg"]];
            photo.caption = @"Barb Wire Fence";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1129/1011721614_8a5de7701c_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1152/1010860101_e9ac61fe2c_b.jpg"]];
            photo.caption = @"Barb Wire";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1152/1010860101_e9ac61fe2c_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1276/1011685542_9e5bc95aaf_b.jpg"]];
            photo.caption = @"Church Light";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1276/1011685542_9e5bc95aaf_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1008/1011667622_94607012d3_b.jpg"]];
            photo.caption = @"My Car in Snow";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1008/1011667622_94607012d3_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1408/1011656768_62713e265a_b.jpg"]];
            photo.caption = @"Frost";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1408/1011656768_62713e265a_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1351/1011575570_433c62399d_b.jpg"]];
            photo.caption = @"Memorial";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1351/1011575570_433c62399d_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1284/1011559728_ad59fa81ce_b.jpg"]];
            photo.caption = @"Cracked Cloud Sun";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1284/1011559728_ad59fa81ce_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1045/1010555983_6cca0484e9_b.jpg"]];
            photo.caption = @"Frosted Grass CU";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1045/1010555983_6cca0484e9_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1300/1010519417_00b75cc013_b.jpg"]];
            photo.caption = @"Water Leaves";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1300/1010519417_00b75cc013_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1227/1010469785_4111f8b6ae_b.jpg"]];
            photo.caption = @"Sunset Tree";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1227/1010469785_4111f8b6ae_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1099/1011324558_c8f4802d4b_b.jpg"]];
            photo.caption = @"Sunset";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1099/1011324558_c8f4802d4b_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1224/1011283712_5750c5ba8e_b.jpg"]];
            photo.caption = @"Mannequin Half Light";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1224/1011283712_5750c5ba8e_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1384/1010423817_56b81c6f24_b.jpg"]];
            photo.caption = @"Mannequin Side Light";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1384/1010423817_56b81c6f24_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1429/1011276778_e97457682a_b.jpg"]];
            photo.caption = @"Mannequin";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1429/1011276778_e97457682a_q.jpg"]]];
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1235/1010416375_fe91e5ce22_b.jpg"]];
            photo.caption = @"Mannequin DoF";
            [photos addObject:photo];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm2.static.flickr.com/1235/1010416375_fe91e5ce22_q.jpg"]]];
            // Options
            startOnGrid = YES;
			break;
		case 7: {
            @synchronized(_assets) {
                NSMutableArray *copy = [_assets copy];
                if (NSClassFromString(@"PHAsset")) {
                    // Photos library
                    UIScreen *screen = [UIScreen mainScreen];
                    CGFloat scale = screen.scale;
                    // Sizing is very rough... more thought required in a real implementation
                    CGFloat imageSize = MAX(screen.bounds.size.width, screen.bounds.size.height);
                    CGSize imageTargetSize = CGSizeMake(imageSize * scale, imageSize * scale);
                    CGSize thumbTargetSize = CGSizeMake(imageSize / 3.0 * scale, imageSize / 3.0 * scale);
                    for (PHAsset *asset in copy) {
                        [photos addObject:[MWPhoto photoWithAsset:asset targetSize:imageTargetSize]];
                        [thumbs addObject:[MWPhoto photoWithAsset:asset targetSize:thumbTargetSize]];
                    }
                } else {
                    // Assets library
                    for (ALAsset *asset in copy) {
                        [photos addObject:[MWPhoto photoWithURL:asset.defaultRepresentation.url]];
                        [thumbs addObject:[MWPhoto photoWithImage:[UIImage imageWithCGImage:asset.thumbnail]]];
                    }
                }
            }
			break;
        }
		default: break;
	}
    self.photos = photos;
    self.thumbs = thumbs;
	
	// Create browser
	MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    browser.displayActionButton = displayActionButton;
    browser.displayNavArrows = displayNavArrows;
    browser.displaySelectionButtons = displaySelectionButtons;
    browser.alwaysShowControls = displaySelectionButtons;
    browser.zoomPhotosToFill = YES;
    browser.enableGrid = enableGrid;
    browser.startOnGrid = startOnGrid;
    browser.enableSwipeToDismiss = NO;
    [browser setCurrentPhotoIndex:0];
    
    // Reset selections
    if (displaySelectionButtons) {
        _selections = [NSMutableArray new];
        for (int i = 0; i < photos.count; i++) {
            [_selections addObject:[NSNumber numberWithBool:NO]];
        }
    }
    
    // Show
    if (_segmentedControl.selectedSegmentIndex == 0) {
        // Push
        [self.navigationController pushViewController:browser animated:YES];
    } else {
        // Modal
        UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:browser];
        nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:nc animated:YES completion:nil];
    }
    
    // Release
	
	// Deselect
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // Test reloading of data after delay
    double delayInSeconds = 3;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
    
//        // Test removing an object
//        [_photos removeLastObject];
//        [browser reloadData];
//    
//        // Test all new
//        [_photos removeAllObjects];
//        [_photos addObject:[MWPhoto photoWithFilePath:[[NSBundle mainBundle] pathForResource:@"photo3" ofType:@"jpg"]]];
//        [browser reloadData];
//    
//        // Test changing photo index
//        [browser setCurrentPhotoIndex:9];
    
//        // Test updating selections
//        _selections = [NSMutableArray new];
//        for (int i = 0; i < [self numberOfPhotosInPhotoBrowser:browser]; i++) {
//            [_selections addObject:[NSNumber numberWithBool:YES]];
//        }
//        [browser reloadData];
        
    });

}

#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return _photos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < _photos.count)
        return [_photos objectAtIndex:index];
    return nil;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index {
    if (index < _thumbs.count)
        return [_thumbs objectAtIndex:index];
    return nil;
}

//- (MWCaptionView *)photoBrowser:(MWPhotoBrowser *)photoBrowser captionViewForPhotoAtIndex:(NSUInteger)index {
//    MWPhoto *photo = [self.photos objectAtIndex:index];
//    MWCaptionView *captionView = [[MWCaptionView alloc] initWithPhoto:photo];
//    return [captionView autorelease];
//}

//- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser actionButtonPressedForPhotoAtIndex:(NSUInteger)index {
//    NSLog(@"ACTION!");
//}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index {
    NSLog(@"Did start viewing photo at index %lu", (unsigned long)index);
}

- (BOOL)photoBrowser:(MWPhotoBrowser *)photoBrowser isPhotoSelectedAtIndex:(NSUInteger)index {
    return [[_selections objectAtIndex:index] boolValue];
}

//- (NSString *)photoBrowser:(MWPhotoBrowser *)photoBrowser titleForPhotoAtIndex:(NSUInteger)index {
//    return [NSString stringWithFormat:@"Photo %lu", (unsigned long)index+1];
//}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index selectedChanged:(BOOL)selected {
    [_selections replaceObjectAtIndex:index withObject:[NSNumber numberWithBool:selected]];
    NSLog(@"Photo at index %lu selected %@", (unsigned long)index, selected ? @"YES" : @"NO");
}

- (void)photoBrowserDidFinishModalPresentation:(MWPhotoBrowser *)photoBrowser {
    // If we subscribe to this method we must dismiss the view controller ourselves
    NSLog(@"Did finish modal presentation");
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Load Assets

- (void)loadAssets {
    if (NSClassFromString(@"PHAsset")) {
        
        // Check library permissions
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        if (status == PHAuthorizationStatusNotDetermined) {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusAuthorized) {
                    [self performLoadAssets];
                }
            }];
        } else if (status == PHAuthorizationStatusAuthorized) {
            [self performLoadAssets];
        }
        
    } else {
        
        // Assets library
        [self performLoadAssets];
        
    }
}

- (void)performLoadAssets {
    
    // Initialise
    _assets = [NSMutableArray new];
    
    // Load
    if (NSClassFromString(@"PHAsset")) {
        
        // Photos library iOS >= 8
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            PHFetchOptions *options = [PHFetchOptions new];
            options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
            PHFetchResult *fetchResults = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:options];
            [fetchResults enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [_assets addObject:obj];
            }];
            if (fetchResults.count > 0) {
                [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
            }
        });
        
    } else {
        
        // Assets Library iOS < 8
        _ALAssetsLibrary = [[ALAssetsLibrary alloc] init];
        
        // Run in the background as it takes a while to get all assets from the library
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSMutableArray *assetGroups = [[NSMutableArray alloc] init];
            NSMutableArray *assetURLDictionaries = [[NSMutableArray alloc] init];
            
            // Process assets
            void (^assetEnumerator)(ALAsset *, NSUInteger, BOOL *) = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if (result != nil) {
                    if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
                        [assetURLDictionaries addObject:[result valueForProperty:ALAssetPropertyURLs]];
                        NSURL *url = result.defaultRepresentation.url;
                        [_ALAssetsLibrary assetForURL:url
                                          resultBlock:^(ALAsset *asset) {
                                              if (asset) {
                                                  @synchronized(_assets) {
                                                      [_assets addObject:asset];
                                                      if (_assets.count == 1) {
                                                          // Added first asset so reload data
                                                          [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
                                                      }
                                                  }
                                              }
                                          }
                                         failureBlock:^(NSError *error){
                                             NSLog(@"operation was not successfull!");
                                         }];
                        
                    }
                }
            };
            
            // Process groups
            void (^ assetGroupEnumerator) (ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop) {
                if (group != nil) {
                    [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:assetEnumerator];
                    [assetGroups addObject:group];
                }
            };
            
            // Process!
            [_ALAssetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll
                                            usingBlock:assetGroupEnumerator
                                          failureBlock:^(NSError *error) {
                                              NSLog(@"There is an error");
                                          }];
            
        });
        
    }
    
}

@end

