//
//  CellStyleModel.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 7/9/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "CellStyleModel.h"

@interface CellStyleModel ()

@property (nonatomic, strong) NSArray *cellStyleImages;

@end

@implementation CellStyleModel

- (id)initWithCellStyleSize:(CellStyleSize)cellStyleSize andCellStyleType:(CellStyleType)cellStyleType
{
    self = [super init];
    if(self)
    {
        _cellStyleType = cellStyleType;
        _cellStyleSize = cellStyleSize;
        self.cellStyleImages = @[@"cell_right_1",
                                 @"cell_right_2",
                                 @"cell_right_3",
                                 @"cell_right_4",
                                 @"cell_right_5"];
    }
    return self;
}

- (NSString*)cellImageName
{
    return [self.cellStyleImages objectAtIndex:(self.cellStyleType - 1)];
}

- (CGSize)leftImageSize
{
    switch (_cellStyleSize) {
        case CellStyleSizeSmall:
            return CGSizeMake(64, 64);
        case CellStyleSizeBig:
            return CGSizeMake(96, 96);
    }
    return CGSizeZero;
}

- (CGSize)rightImageSize
{
    switch (_cellStyleSize) {
        case CellStyleSizeSmall:
            return CGSizeMake(240, 64);
        case CellStyleSizeBig:
            return CGSizeMake(208, 96);
    }
    return CGSizeZero;
    
}

- (UIColor*)baseColorWithAlpha:(CGFloat)alpha
{
    if(self.cellStyleType == CellStyleTypeMoney || self.cellStyleType == CellStyleTypeText)
    {
        return [UIColor blackColor];
    }
    return [UIColor whiteColor];
}

@end
