//
//  listViewController.m
//  User Profile Book
//
//  Created by Khandker Mahmudur Rahman on 8/19/17.
//  Copyright © 2017 brotecs. All rights reserved.
//

#import "listViewController.h"
#import "PersonViewCell.h"
#import "ProfileViewController.h"
#import "AppDelegate.h"
#import "CoreData/CoreData.h"

@interface listViewController  ()
//@property BOOL isSearchbar;
@end

@implementation listViewController


NSMutableArray *searchResults;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = false;
    self.searchController.searchBar.delegate = self;
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.definesPresentationContext = YES;
    [self.searchController.searchBar sizeToFit];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




- (NSPredicate *)wordBasedPredicateForString:(NSString *)searchString
{

   // searchString = [searchString stringForSearch];
    NSArray *searchStrings = [searchString componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

    NSMutableArray<NSPredicate *> *subPredicates = [NSMutableArray array];
    

    for (NSString *string in searchStrings){
        if (![string isEqualToString:@""]) {

            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"( ANY words BEGINSWITH[c] %@ ) OR ( mobile BEGINSWITH[c] %@ ) OR ( mobile contains[c] %@ ) OR ( gender BEGINSWITH[c] %@ )", string, string, [NSString stringWithFormat:@"+88%@",string], string];
            [subPredicates addObject:predicate];
            
            
            
        }
        
    }


    NSCompoundPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:subPredicates];
    return predicate;
}




//Generate Search Results using predicate
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    
    
    
    NSPredicate *resultPredicate = [self wordBasedPredicateForString:searchText];
    
    searchResults = [[_people filteredArrayUsingPredicate:resultPredicate] mutableCopy];
    
    
}

//Search bar Text change action
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController{
    
    [self filterContentForSearchText:searchController.searchBar.text scope:[[searchController.searchBar scopeButtonTitles] objectAtIndex:[searchController.searchBar selectedScopeButtonIndex]]];
    [self.tableView reloadData];
}



- (void) searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    //
    [self.searchController setActive:false];
    
    [self.tableView reloadData];
    
}




- (NSManagedObjectContext *)managedObjectContext{
    NSManagedObjectContext *context =nil;
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    //[[UIApplication sharedApplication] delegate];
    
    if([delegate respondsToSelector:@selector(persistentContainer)]){
        context = delegate.persistentContainer.viewContext;
    }
    return context;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    //[self.searchDisplayController setActive:false];
    [self reloadTableData];
    
    [self.searchController.searchBar setText:self.searchController.searchBar.text];
}

- (void)reloadTableData{
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Person"];
    _people = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    
    NSSortDescriptor *firstNameSort = [[NSSortDescriptor alloc] initWithKey:@"firstName" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
    NSSortDescriptor *lastNameSort = [[NSSortDescriptor alloc] initWithKey:@"lastName" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
    [_people sortUsingDescriptors:[NSArray arrayWithObjects:firstNameSort,lastNameSort, nil]];
    
    
    NSMutableCharacterSet *charset = [NSMutableCharacterSet whitespaceCharacterSet];
    [charset formUnionWithCharacterSet:[NSMutableCharacterSet symbolCharacterSet]];
    [charset formUnionWithCharacterSet:[NSMutableCharacterSet punctuationCharacterSet]];
    
    for (NSManagedObject* person in _people) {
        NSMutableArray* words = [[[person valueForKey:@"firstName"] componentsSeparatedByCharactersInSet:charset] mutableCopy];
        [words addObjectsFromArray:[[person valueForKey:@"lastName"] componentsSeparatedByCharactersInSet:charset]];
        NSMutableArray *temp = [[[person valueForKey:@"email"] componentsSeparatedByCharactersInSet:charset] mutableCopy];
        [temp removeLastObject];
        [words addObjectsFromArray:temp];
        
        [words addObjectsFromArray:[[person valueForKey:@"address"] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@", "] ]];
        [person setValue:words forKey:@"words"];
    }
    
    
    [self.tableView reloadData];
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.searchController.isActive) {
        return [searchResults count];
        
    }
    else
        return _people.count;
}

//Create attributed text to show colored search results
- (NSMutableAttributedString *) searchAttributedText:(NSString *)originText withSearch:(NSString *)key{
    
    
    //NSString *searchTerm = key;
    NSString *resultText = originText;
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:resultText];
    
    NSMutableArray *searchParams = [[key componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] mutableCopy];
    
    for (NSString *searchTerm in searchParams) {
        
    
    
    NSString *pattern = [NSString stringWithFormat:@"(%@)", searchTerm.lowercaseString];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:kNilOptions error:nil];
    NSRange range = NSMakeRange(0, resultText.length);
    
    [regex enumerateMatchesInString:resultText.lowercaseString options:kNilOptions range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        
        NSRange subStringRange = [result rangeAtIndex:1];
        
        [attributedString addAttribute:NSForegroundColorAttributeName
                                 value:[UIColor redColor]
                                 range:subStringRange];
    }];
        
    }
    
    return attributedString;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if (self.searchController.isActive) {
        PersonViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
//        if(cell == nil){
//            cell = [[PersonViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
//        }
        NSManagedObject *found = [searchResults objectAtIndex:indexPath.row];
        NSString *name = [found valueForKey:@"firstName"];
        name = [name stringByAppendingString:@" "];
        NSString *lname = [found valueForKey:@"lastName"];
        name = [name stringByAppendingString:lname];
        
        NSMutableAttributedString *nameSearch = [self searchAttributedText:name withSearch:self.searchController.searchBar.text];
        
        cell.nameCell.attributedText = nameSearch;
        
        NSMutableAttributedString *numSearch = [self searchAttributedText:[found valueForKey:@"mobile"] withSearch:self.searchController.searchBar.text];
        cell.phoneCell.attributedText = numSearch ;
        
        
        cell.imageCell.image = [UIImage imageWithData:[found valueForKey:@"proPic"]];
//        cell.clipsToBounds = false;
//        [tableView setRowHeight: cell.imageCell.frame.size.height+10];
        [cell.layer setBorderColor: [[UIColor cyanColor] CGColor] ];
        [cell.layer setBorderWidth:5];
        return cell;
        
    } else {
        
        
        PersonViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
        NSManagedObject *person = [_people objectAtIndex:indexPath.row];
        // Configure the cell...
        
        
        
        NSData *img = [person valueForKey:@"proPic"];
        if(img){
            UIImage *image = [UIImage imageWithData:img];
            
            //cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
            cell.imageCell.clipsToBounds = true;
            [cell.imageCell setImage:image];
        }else{
            cell.imageCell.image = nil;
        }
        NSString *name = [person valueForKey:@"firstName"];
        name = [name stringByAppendingString:@" "];
        NSString *lname = [person valueForKey:@"lastName"];
        name = [name stringByAppendingString:lname];
        cell.nameCell.text = name;
        [cell.phoneCell setText:[person valueForKey:@"mobile"]];
        
        
        [cell.layer setBorderColor: [[UIColor cyanColor] CGColor] ];
        [cell.layer setBorderWidth:5];
        
        
        return cell;
        
    }
    
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier  isEqual: @"editProfile"]) {
        NSIndexPath *index = [self.tableView indexPathForSelectedRow];
        
        
        
        NSManagedObject *person;
        
        if(self.searchController.isActive){
            index = [self.tableView indexPathForSelectedRow];
            person = [searchResults objectAtIndex:index.row];
        }
        else
            person = [_people objectAtIndex:index.row];
        
        
        UINavigationController *nav = (UINavigationController *) segue.destinationViewController;
        
        ProfileViewController *des = (ProfileViewController *)nav.topViewController;
        
        des.seletedPerson = person;
        des.isSelected = true;
    }
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        
        
        NSManagedObjectContext *context = [self managedObjectContext];
        
        if(self.searchController.isActive){
            
            NSManagedObject *removingObject = [searchResults objectAtIndex:indexPath.row];
            [_people removeObject:removingObject];
            [searchResults removeObject:removingObject];
            
            
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView reloadData];
            
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                [context deleteObject:removingObject];
                NSError *error = nil;
                if (![context save:&error]) {
                    NSLog(@"Can't Delete! %@ %@", error, [error localizedDescription]);
                    return;
                }
                
                
            });
            
        }
        else{
            [context deleteObject:[_people objectAtIndex:indexPath.row]];
            NSError *error = nil;
            if (![context save:&error]) {
                NSLog(@"Can't Delete! %@ %@", error, [error localizedDescription]);
                return;
            }
            
            [_people removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}



/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
