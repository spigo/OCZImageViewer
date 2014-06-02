//
//  OCZImageViewer.h
//  Obrazky
//
//  Created by Peter Rusinak on 30/05/14.
//  Copyright (c) 2014 Peter Rusinak. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OCZImageViewerDataSource;
@protocol OCZImageViewerDelegate;

@interface OCZImageViewer : UIView

@property (nonatomic, assign) id<OCZImageViewerDelegate> delegate;
@property (nonatomic, assign) id<OCZImageViewerDataSource> datasource;
@property (nonatomic, assign) NSInteger initialIndex;

- (void)showImage:(UIImage *)image fromRect:(CGRect)rect animated:(BOOL)animated;
- (void)closeImageViewer;
- (void)imageViewerReloadData;

@end

@protocol OCZImageViewerDelegate <NSObject>

@required
- (void)didClosedImageViewer:(OCZImageViewer *)imageViewer;
- (void)imageViewer:(OCZImageViewer *)imageViewer shareImage:(UIImage *)image atIndex:(NSInteger)index;
- (void)imageViewer:(OCZImageViewer *)imageViewer didScrollToIndex:(NSInteger)index;
@optional
- (void)imageViewer:(OCZImageViewer *)imageViewer didSelectImage:(UIImage *)image atIndex:(NSInteger)index;
- (void)imageViewWillDisplayLastItem;

@end

@protocol OCZImageViewerDataSource <NSObject>

@required
- (NSInteger)numberOfImagesInImageViewer:(OCZImageViewer *)imageViewer;
- (NSURL *)imageViewer:(OCZImageViewer*)imageViewer urlForImageAtIndex:(NSInteger)index;
- (CGRect)imageViewer:(OCZImageViewer *)imageViewer rectForImageAtIndex:(NSInteger)index;

@end
