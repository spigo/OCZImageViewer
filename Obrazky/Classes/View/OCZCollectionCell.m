//
//  OCZCollectionCell.m
//  Obrazky
//
//  Created by Peter Rusinak on 02/06/14.
//  Copyright (c) 2014 Peter Rusinak. All rights reserved.
//

#import "OCZCollectionCell.h"

static const CGFloat kMaxImageScale = 4.0f;
static const CGFloat kMinImageScale = 1.0f;

@interface OCZCollectionCell () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation OCZCollectionCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        [self loadView];
    }
    return self;
}

- (void)loadView
{
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
    self.scrollView.delegate = self;
    self.scrollView.minimumZoomScale = kMinImageScale;
    self.scrollView.maximumZoomScale = kMaxImageScale;
    self.scrollView.zoomScale = 1;
    [self addSubview:self.scrollView];

    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.clipsToBounds = YES;

    [self.scrollView addSubview:self.imageView];
}

#pragma mark - UIScrollView Delegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

#pragma mark -

- (void)setZoom:(CGFloat)zoom
{
    if (_zoom != zoom) {
        _zoom = zoom;

        [self.scrollView setZoomScale:zoom];
    }
}

@end
