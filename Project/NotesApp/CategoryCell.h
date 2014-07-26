//
//  CategoryCell.h
//  NotesApp
//
//  Created by Mladen Djordjevic on 6/1/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, CategoryCellAccessoryType)
{
    CategoryCellAccessoryTypeNone,
    CategoryCellAccessoryTypeAdd,
    CategoryCellAccessoryTypeArrow
};

@interface CategoryCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic) CategoryCellAccessoryType cellAccessoryType;

@end
