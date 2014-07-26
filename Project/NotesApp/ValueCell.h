//
//  ValueCell.h
//  NotesApp
//
//  Created by Mladen Djordjevic on 10/28/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "BrowseCell.h"

@interface ValueCell : BrowseCell

@property (nonatomic, strong) IBOutlet UILabel *valueLabel;
@property (nonatomic, strong) IBOutlet UILabel *formatDescriptionLabel;

@end
