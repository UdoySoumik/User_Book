//
//  ProfileViewController.m
//  User Profile Book
//
//  Created by Khandker Mahmudur Rahman on 8/19/17.
//  Copyright © 2017 brotecs. All rights reserved.
//

#import "ProfileViewController.h"
#import "listViewController.h"
#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>
#import <Photos/PHPhotoLibrary.h>
@interface ProfileViewController ()


@end

@implementation ProfileViewController

UIDatePicker* pickerDate;
UIPickerView* pickerGender;
NSArray* pickerData;
BOOL isFrame;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    pickerDate = [UIDatePicker new];
    [pickerDate addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
    pickerGender = [UIPickerView new];

    [pickerGender setShowsSelectionIndicator:true];
    pickerGender.delegate = self;
    pickerGender.dataSource = self;
    pickerData = @[@"Male",@"Female"];
    
    
    [pickerGender setOpaque:false];
    [pickerGender setBackgroundColor:[UIColor lightGrayColor]];
    
    [pickerGender selectRow:0 inComponent:0 animated:YES];
    
     pickerDate.frame = CGRectMake(0,3*[[UIScreen mainScreen] bounds].size.height/4, [[UIScreen mainScreen] bounds].size.width,[[UIScreen mainScreen] bounds].size.height/4);
    
    pickerGender.frame = CGRectMake(0,3*[[UIScreen mainScreen] bounds].size.height/4, [[UIScreen mainScreen] bounds].size.width,[[UIScreen mainScreen] bounds].size.height/4);
    
    CGRect newFrame = self.spaceView.frame;
    
    newFrame.size.width = pickerGender.frame.size.width;
    newFrame.size.height = pickerGender.frame.size.height;
    
    [_spaceView setFrame:newFrame];
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:true];
    
    
    
    if(_isSelected){
        if ([_seletedPerson valueForKey:@"proPic"]) {
            
            [_imageView setImage:[UIImage imageWithData:[_seletedPerson valueForKey:@"proPic"]]];
        }
        [_fName setText:[_seletedPerson valueForKey:@"firstName"]];
        [_lName setText:[_seletedPerson valueForKey:@"lastName"]];
        [_mobile setText:[_seletedPerson valueForKey:@"mobile"]];
        [_mail setText:[_seletedPerson valueForKey:@"email"]];
        [_address setText:[_seletedPerson valueForKey:@"address"]];
        [_genderField setText:[_seletedPerson valueForKey:@"gender"]];
        _selectDate = [_seletedPerson valueForKey:@"dob"];
        NSDateFormatter *fdate = [NSDateFormatter new];
        fdate.dateFormat = @"dd MMM, YYYY";
        [_dateField setText:[fdate stringFromDate:_selectDate]];
        _selectGender = [_seletedPerson valueForKey:@"gender"];
        
        _isSelected = false;
        
    }
    
    
    
}


- (NSManagedObjectContext *)managedObjectContext{
    NSManagedObjectContext *context =nil;
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if([delegate respondsToSelector:@selector(persistentContainer)]){
        context = delegate.persistentContainer.viewContext;
    }
    return context;
}

// Validate the input string with the given pattern and
// return the result as a boolean
- (BOOL)validateString:(NSString *)string withPattern:(NSString *)pattern
{
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSAssert(regex, @"Unable to create regular expression");
    
    NSRange textRange = NSMakeRange(0, string.length);
    NSRange matchRange = [regex rangeOfFirstMatchInString:string options:NSMatchingReportProgress range:textRange];
    
    BOOL didValidate = NO;
    
    // Did we find a matching range
    if (matchRange.location != NSNotFound)
        didValidate = YES;
    
    return didValidate;
}

- (void)nullCheck{
    UIAlertController *alert = [UIAlertController new];
    BOOL check = YES;
    static NSString* mailPattern = @"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}$";
    
    if([_fName.text isEqual:@""])
        [alert setMessage:@"First Name is Empty"];
   // else if([_lName.text isEqual:@""])
   //     [alert setMessage:@"Last Name is Empty"];
    else if([_mail.text isEqual:@""])
        [alert setMessage:@"Email Address is Empty"];
    else if([_mobile.text isEqual:@""])
        [alert setMessage:@"Phone Number is Empty"];
   // else if([_address.text isEqual:@""])
   //     [alert setMessage:@"Address is Empty"];
    else if(!_selectGender)
        [alert setMessage:@"Choose Gender"];
    else if(![self validateString:_mobile.text withPattern:@"^(\\+[0-9]{2})?[0-9]+$"]){
        [alert setMessage:@"Invalid Phone Number"];
        [alert setTitle:@"Invalid Input"];
    }
    else if(![self validateString:_mail.text withPattern:mailPattern]){
        [alert setMessage:@"Invalid Email Address"];
        [alert setTitle:@"Invalid Input"];
    }
    else
        check = NO;
    
    if(check){
        if(![alert.title  isEqual: @"Invalid Input"])
            [alert setTitle:@"Empty Field"];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:defaultAction];
        
        [self presentViewController:alert animated:true completion:nil];
    }
    else{
        [self savePerson];
        
        [self.view endEditing:true];
        [self dismissViewControllerAnimated:true completion:nil];
    }
    
}



- (IBAction)createProfileAction:(UIBarButtonItem *)sender {
    [self nullCheck];
}

- (void)savePerson{
    
    NSManagedObjectContext *context;
    
    context = [self managedObjectContext];
    
    @try{
        
        if(!_seletedPerson){
            NSManagedObject *addPerson = [NSEntityDescription insertNewObjectForEntityForName:@"Person" inManagedObjectContext:context];
            //
            [addPerson setValue:_fName.text forKey:@"firstName"];
            [addPerson setValue:_lName.text forKey:@"lastName"];
            [addPerson setValue: _mobile.text  forKey:@"mobile"];
            [addPerson setValue:_selectDate forKey:@"dob"];
            [addPerson setValue:_address.text forKey:@"address"];
            [addPerson setValue:_selectGender forKey:@"gender"];
            [addPerson setValue:_mail.text forKey:@"email"];
            if(_imageView.image){
                NSData *image = UIImageJPEGRepresentation(_imageView.image, 0.0);
                [addPerson setValue:image forKey:@"proPic"];
            }
            
        }
        else{
            [_seletedPerson setValue:_fName.text forKey:@"firstName"];
            [_seletedPerson setValue:_lName.text forKey:@"lastName"];
            [_seletedPerson setValue: _mobile.text  forKey:@"mobile"];
            [_seletedPerson setValue:_selectDate forKey:@"dob"];
            [_seletedPerson setValue:_address.text forKey:@"address"];
            [_seletedPerson setValue:_selectGender forKey:@"gender"];
            [_seletedPerson setValue:_mail.text forKey:@"email"];
            if(_imageView.image){
                NSData *image = UIImageJPEGRepresentation(_imageView.image, 0.0);
                [_seletedPerson setValue:image forKey:@"proPic"];
            }
        }
    }
    @catch(NSException *ex){
        NSLog(@"%@",ex.reason);
    }
    NSError *error = nil;
    if(![context save:&error]){
        NSLog(@"Could not save");
    }
    _seletedPerson = nil;
    _isSelected = false;
    
}


- (IBAction)cancelAction:(UIBarButtonItem *)sender {
    _seletedPerson = nil;
    _isSelected = false;
    [self.view endEditing:true];
    [self dismissViewControllerAnimated:true completion:nil];
}


- (IBAction)selectPhoto:(UIButton *)sender{
    
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    
    if(status != PHAuthorizationStatusDenied){
    
    [pickerGender removeFromSuperview];
    [pickerDate removeFromSuperview];
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate =self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
    [self presentViewController:picker animated:YES completion:NULL];
    }
    else{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Photos Restricted" message:@"Go to privacy settings and allow Photos for this app" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        }]];
        [self presentViewController:alert animated:true completion:nil];

    }
}

- (IBAction)takePhoto:(UIButton *)sender{
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(status != AVAuthorizationStatusDenied){
        [pickerGender removeFromSuperview];
        [pickerDate removeFromSuperview];
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate =self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        [self presentViewController:picker animated:YES completion:NULL];
    }
    else{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Camera Restricted" message:@"Go to privacy settings and allow camera usage for this app" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        }]];
        [self presentViewController:alert animated:true completion:nil];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.imageView.image = chosenImage;
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:true completion:nil];
}


#pragma mark - Table view data source





- (void)dateChanged:(id)sender{
    UIDatePicker *pick = sender;
    _selectDate = pick.date;
    NSDateFormatter *fdate = [NSDateFormatter new];
    fdate.dateFormat = @"dd MMM, YYYY";
    [_dateField setText:[fdate stringFromDate:_selectDate]];
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section==4){
        [self.view endEditing:true];
        
        
        
        [pickerDate removeFromSuperview];
        if(_selectGender){
            if ([_selectGender isEqualToString:@"Male"]) {
                [pickerGender selectRow:0 inComponent:0 animated:true];
            }
            else if ([_selectGender isEqualToString:@"Female"]){
                [pickerGender selectRow:1 inComponent:0 animated:true];
            }
        }
        else{
            _selectGender = @"Male";
            [_genderField setText:@"Male"];
        }
        
        
        [tableView reloadData];
        
        
            
            [self.navigationController.view addSubview:pickerGender];
            
        
        
        
        
    }
    else if (indexPath.section == 3){
        //
        [self.view endEditing:true];
        [pickerGender removeFromSuperview];
        
        
        [pickerDate setDatePickerMode:UIDatePickerModeDate];
        if(_selectDate)
            pickerDate.date = _selectDate;
       
        [pickerDate setOpaque:false];
        
        
        [pickerDate setBackgroundColor:[UIColor lightGrayColor]];
        
        [tableView reloadData];
        
        
        
        [self.navigationController.view addSubview:pickerDate];
        
        
        
        
    }
    else if (indexPath.section == 0){
        
        UIAlertController *pickImage = [UIAlertController alertControllerWithTitle:@"Choose Image" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
        
        [pickImage addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
            
        }]];
        
        [pickImage addAction:[UIAlertAction actionWithTitle:@"Choose from Gallery" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            [self selectPhoto:nil];
        }]];
        
        [pickImage addAction:[UIAlertAction actionWithTitle:@"Capture New Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            [self takePhoto:nil];
            
        }]];
        [self.view endEditing:true];
        [self presentViewController:pickImage animated:true completion:nil];
        [pickerDate removeFromSuperview];
        [pickerGender removeFromSuperview];
        [tableView reloadData];
    }
    else{
        
        [pickerDate removeFromSuperview];
        [pickerGender removeFromSuperview];
        
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0 || indexPath.section==3 || indexPath.section == 4) {
        return true;
    }
    else
        return false;
}




/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

//UIPickerview Pragma mark
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return pickerData.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return  pickerData[row];
}

- (void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    _selectGender = pickerData[row];
    [_genderField setText:_selectGender];
}


- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField{
    [pickerDate removeFromSuperview];
    [pickerGender removeFromSuperview];
    
    return true;
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return true;
}
- (BOOL) textViewShouldBeginEditing:(UITextView *)textView{
    [pickerDate removeFromSuperview];
    [pickerGender removeFromSuperview];
    
    return true;
}



@end
