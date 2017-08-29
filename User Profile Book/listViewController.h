//
//  listViewController.h
//  User Profile Book
//
//  Created by Khandker Mahmudur Rahman on 8/19/17.
//  Copyright © 2017 brotecs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreData/CoreData.h"

@interface listViewController : UITableViewController <UISearchResultsUpdating, UISearchBarDelegate>
@property NSMutableArray *people;
@property NSManagedObject *selectedPerson;
@property (strong, nonatomic) UISearchController *searchController;
@end
