//
//  OCZImageViewer.m
//  Obrazky
//
//  Created by Peter Rusinak on 30/05/14.
//  Copyright (c) 2014 Peter Rusinak. All rights reserved.
//

#import "OCZImageViewer.h"
#import "OCZCollectionCell.h"
#import "UIImageView+AFNetworking.h"

#define kDefaultBackground [UIColor colorWithWhite:0.0 alpha:0.9];

@interface OCZImageViewer () <UIScrollViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, assign) NSInteger statusBarStyle;

@property (nonatomic, strong) UIButton *btnClose;
@property (nonatomic, strong) UIButton *btnShare;

// CollectionView
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSIndexPath *currentIndexPath;
@property (nonatomic, assign) NSInteger currentCellIndex;

@end

@implementation OCZImageViewer

#pragma mark - Properties

- (NSIndexPath *)currentIndexPath
{
    return [NSIndexPath indexPathForRow:self.currentCellIndex inSection:0];
}

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = [[UIScreen mainScreen] bounds];
        self.opaque = NO;
        self.backgroundColor = kDefaultBackground;

        [self loadView];
    }
    return self;
}

- (void)loadView
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    if (!window)
        window = [[UIApplication sharedApplication].windows objectAtIndex:0];

    self.statusBarStyle = [[UIApplication sharedApplication] statusBarStyle];

    /* Set flowLayout for CollectionView */
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.itemSize = CGSizeMake(self.bounds.size.width, self.bounds.size.height);
    [flowLayout setMinimumInteritemSpacing:0.0f];
    //    flowLayout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);
    flowLayout.minimumLineSpacing = 0.0f;

    /* Init and Set CollectionView */
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flowLayout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.pagingEnabled = YES;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.hidden = YES;
    [self.collectionView registerClass:[OCZCollectionCell class] forCellWithReuseIdentifier:@"OCZCollectionCell"];
    [self addSubview:self.collectionView];

    // Close button
    self.btnClose = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnClose.frame = CGRectMake(20, 26, 60, 30);
    [self.btnClose setTitle:NSLocalizedString(@"Hotovo", nil) forState:UIControlStateNormal];
    [self.btnClose setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btnClose addTarget:self action:@selector(closeImageViewer) forControlEvents:UIControlEventTouchUpInside];
    [self.btnClose setAlpha:0.0f];
    [self addSubview:self.btnClose];

    // Share button
    self.btnShare = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnShare.frame = CGRectMake(self.frame.size.width - 80, 26, 60, 30);
    [self.btnShare setTitle:NSLocalizedString(@"Share", nil) forState:UIControlStateNormal];
    [self.btnShare setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btnShare addTarget:self action:@selector(share) forControlEvents:UIControlEventTouchUpInside];
    [self.btnShare setAlpha:0.0f];
    [self addSubview:self.btnShare];

    // Animation
    CATransition *viewIn = [CATransition animation];
    [viewIn setDuration:0.7];
    [viewIn setType:kCATransitionReveal];
    [viewIn setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [[self layer] addAnimation:viewIn forKey:kCATransitionReveal];

    [[[window subviews] objectAtIndex:0] addSubview:self];
}

#pragma mark - Open View

- (void)showImage:(UIImage *)image fromRect:(CGRect)rect animated:(BOOL)animated
{
    self.currentCellIndex = self.initialIndex;

    [self.collectionView scrollToItemAtIndexPath:self.currentIndexPath
                                atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];


    UIImageView *imageView = [[UIImageView alloc] initWithFrame:rect];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.clipsToBounds = YES;
    imageView.image = image;
    [self addSubview:imageView];

    [UIView animateWithDuration:(animated ? 0.5 : 0.0)
                          delay:0.0
                        options:UIViewAnimationOptionTransitionNone
                     animations:^{

                         imageView.frame = [self centerFrameFromImage:image];
                         imageView.center = self.center;
                     }
                     completion:^(BOOL finished) {
                         [imageView removeFromSuperview];
                         [self.collectionView setHidden:NO];
                         [self showControlElementsAnimated:YES];
                     }];
}

#pragma mark -

- (void)imageViewerReloadData
{
    [self.collectionView reloadData];
}

#pragma mark - Action methods

- (void)closeImageViewer
{
    CATransition *viewOut = [CATransition animation];
    [viewOut setDuration:0.1];
    [viewOut setType:kCATransitionFade];
    [viewOut setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [[self.superview layer] addAnimation:viewOut forKey:kCATransitionFade];

    CGRect newFrame = CGRectZero;

    if (self.datasource && [self.datasource respondsToSelector:@selector(imageViewer:rectForImageAtIndex:)]) {
        newFrame = [self.datasource imageViewer:self rectForImageAtIndex:self.currentCellIndex];
    }

    OCZCollectionCell *collectionCell = (OCZCollectionCell *)[self.collectionView cellForItemAtIndexPath:self.currentIndexPath];
    [collectionCell setZoom:1.0];

    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         collectionCell.imageView.frame = newFrame;
                     }
                     completion:^(BOOL finished) {

                         [[UIApplication sharedApplication] setStatusBarStyle:self.statusBarStyle];
                         [self removeFromSuperview];

                         if (self.delegate && [self.delegate respondsToSelector:@selector(didClosedImageViewer:)]) {
                             [self.delegate didClosedImageViewer:self];
                         }
                     }];
}

- (void)share
{
    OCZCollectionCell *collectionCell = (OCZCollectionCell *)[self.collectionView cellForItemAtIndexPath:self.currentIndexPath];

    if (self.delegate && [self.delegate respondsToSelector:@selector(imageViewer:shareImage:atIndex:)]) {
        [self.delegate imageViewer:self shareImage:collectionCell.imageView.image atIndex:self.currentCellIndex];
    }
}

- (void)showControlElementsAnimated:(BOOL)animated
{
    [UIView animateWithDuration:(animated ? 0.3 : 0.0)
                          delay:0.5
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         [self.btnClose setAlpha:1.0];
                         [self.btnShare setAlpha:1.0];

                         [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
                     }
                     completion:^(BOOL finished) {
                     }];
}

#pragma mark - Compute the new size of image relative to width(window)

- (CGRect)centerFrameFromImage:(UIImage*)image
{
    if(!image) return CGRectZero;

    CGRect windowBounds = self.bounds;
    CGSize newImageSize = [self imageResizeBaseOnWidth:windowBounds
                           .size.width oldWidth:image
                           .size.width oldHeight:image.size.height];
    // Just fit it on the size of the screen
    newImageSize.height = MIN(windowBounds.size.height,newImageSize.height);
    return CGRectMake(0.0f, windowBounds.size.height/2 - newImageSize.height/2, newImageSize.width, newImageSize.height);
}

- (CGSize)imageResizeBaseOnWidth:(CGFloat) newWidth oldWidth:(CGFloat) oldWidth oldHeight:(CGFloat)oldHeight
{
    CGFloat scaleFactor = newWidth / oldWidth;
    CGFloat newHeight = oldHeight * scaleFactor;
    return CGSizeMake(newWidth, newHeight);
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.datasource numberOfImagesInImageViewer:self];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    OCZCollectionCell *cell = (OCZCollectionCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"OCZCollectionCell" forIndexPath:indexPath];

    __block UIImageView *blockImageView = cell.imageView;

    NSURL *imageURL = [self.datasource imageViewer:self urlForImageAtIndex:indexPath.row];

    [cell.imageView setImageWithURLRequest:[NSURLRequest requestWithURL:imageURL] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
    {
        if (image) {
            [blockImageView setImage:image];
        }
     } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {

     }];

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    ((OCZCollectionCell*)cell).zoom = 1.0;
}

#pragma mark - UIScrollView Delegage

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.currentCellIndex = self.collectionView.contentOffset.x / self.collectionView.frame.size.width;

    if (self.delegate && [self.delegate respondsToSelector:@selector(imageViewer:didScrollToIndex:)]) {
        [self.delegate imageViewer:self didScrollToIndex:self.currentCellIndex];
    }

    // Load new images if needed
    if (self.currentCellIndex == ([self.datasource numberOfImagesInImageViewer:self] - 3)) {

        if (self.delegate && [self.delegate respondsToSelector:@selector(imageViewWillDisplayLastItem)]) {
            [self.delegate imageViewWillDisplayLastItem];
        }
    }
}

@end
