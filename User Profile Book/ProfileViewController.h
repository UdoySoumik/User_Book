//
//  ProfileViewController.h
//  User Profile Book
//
//  Created by Khandker Mahmudur Rahman on 8/19/17.
//  Copyright © 2017 brotecs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreData/CoreData.h"

@interface ProfileViewController : UITableViewController <UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate, UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource>
@property NSString* selectGender;
@property NSManagedObject* seletedPerson;
@property BOOL isSelected;
@property NSDate* selectDate;

- (IBAction)selectPhoto:(UIButton *)sender;
- (IBAction)takePhoto:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIView *spaceView;


@property (weak, nonatomic) IBOutlet UITextField *fName;
@property (weak, nonatomic) IBOutlet UITextField *lName;
@property (weak, nonatomic) IBOutlet UITextField *mobile;
@property (weak, nonatomic) IBOutlet UITextView *address;
@property (weak, nonatomic) IBOutlet UITextView *mail;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *genderField;
@property (weak, nonatomic) IBOutlet UILabel *dateField;


@end
