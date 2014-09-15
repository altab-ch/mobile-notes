//
//  AggregateValueCell.h
//  NotesApp
//
//  Created by Mathieu Knecht on 12.09.14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import "BrowseCell.h"

@interface AggregateValueCell : BrowseCell

@property (nonatomic, strong) IBOutlet UILabel *valueLabel;
@property (nonatomic, strong) IBOutlet UILabel *formatDescriptionLabel;
@property (nonatomic, strong) IBOutlet UILabel *numberAggregation;

@end
