//
//  PersonViewCell.h
//  User Profile Book
//
//  Created by Khandker Mahmudur Rahman on 8/19/17.
//  Copyright © 2017 brotecs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PersonViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageCell;
@property (weak, nonatomic) IBOutlet UILabel *nameCell;
@property (weak, nonatomic) IBOutlet UILabel *phoneCell;
@end
