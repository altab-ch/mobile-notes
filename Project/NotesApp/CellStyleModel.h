//
//  CellStyleModel.h
//  NotesApp
//
//  Created by Mladen Djordjevic on 7/9/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    CellStyleTypeText = 1,
    CellStyleTypeMeasure,
    CellStyleTypeMoney,
    CellStyleTypePhoto,
    CellStyleTypeAudio,
    CellStyleTypeUnkown
} CellStyleType;

typedef enum {
    CellStyleSizeSmall = 1,
    CellStyleSizeBig
} CellStyleSize;

@interface CellStyleModel : NSObject

@property (nonatomic, readonly) CGSize leftImageSize;
@property (nonatomic, readonly) CGSize rightImageSize;
@property (nonatomic, readonly) CellStyleType cellStyleType;
@property (nonatomic, readonly) NSString *cellImageName;
@property (nonatomic) CellStyleSize cellStyleSize;

- (id)initWithCellStyleSize:(CellStyleSize)cellStyleSize andCellStyleType:(CellStyleType)cellStyleType;
- (UIColor*)baseColorWithAlpha:(CGFloat)alpha;

@end
