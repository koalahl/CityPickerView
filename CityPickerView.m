//
//  CityPickerView.m
//  WMALL
//
//  Created by HanLiu on 15/11/12.
//  Copyright © 2015年 wjhg. All rights reserved.
//

#import "CityPickerView.h"

#define kWidth [UIScreen mainScreen].bounds.size.width
#define kHeight [UIScreen mainScreen].bounds.size.height

#define kPickerViewHeight 217
#define kButtonHeight 30
#define kButtonWidth  100
#define kButtonBackgroudColor ([UIColor colorWithRed:0.98 green:0.32 blue:0.32 alpha:1])

@interface CityPickerView()<UIPickerViewDelegate,UIPickerViewDataSource>

@property (nonatomic,strong)UIPickerView * picker;
@property (nonatomic,strong)UIButton * close;
@property (nonatomic,strong)UIButton * confirm;

//数据源--全部数据
@property (nonatomic,strong)NSMutableArray *provinceArray;
@property (nonatomic,strong)NSMutableArray *cityArray;
@property (nonatomic,strong)NSMutableArray *areaArray;
//城市和区级信息需要跟随省的变化而变化
@property (nonatomic,strong)NSMutableArray *tempCityArray;
@property (nonatomic,strong)NSMutableArray *tempAreaArray;

//用于记录当前选择的地名
@property (nonatomic,copy)NSString * provinceStr;
@property (nonatomic,copy)NSString * cityStr;
@property (nonatomic,copy)NSString * areaStr;
@end
@implementation CityPickerView

- (instancetype)init{
    self = [super init];
    if (self) {
        [self setup];
    }
    
    return self;
}
- (void)setup{
    self.provinceStr = @"北京市";
    self.cityStr     = @"北京市";
    self.areaStr     = @"东城区";
    
    self.provinceArray = [NSMutableArray array];
    self.cityArray     = [NSMutableArray array];
    self.areaArray     = [NSMutableArray array];
    self.tempCityArray = [NSMutableArray array];
    self.tempAreaArray = [NSMutableArray array];
    
    self.frame = CGRectMake(0, kHeight, kWidth, kPickerViewHeight+kButtonHeight);
    self.backgroundColor = [UIColor whiteColor];
    
    self.close = [UIButton buttonWithType:UIButtonTypeCustom];
    self.close.frame = CGRectMake(2, 2, kButtonWidth, kButtonHeight);
    [self.close setTitle:@"关闭" forState:UIControlStateNormal];
    [self.close setTitleColor:kButtonBackgroudColor forState:UIControlStateNormal];
    [self.close addTarget:self action:@selector(closePickerView) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.close];
    
    self.confirm = [UIButton buttonWithType:UIButtonTypeCustom];
    self.confirm.frame = CGRectMake(kWidth-kButtonWidth-2, 2, kButtonWidth, kButtonHeight);
    [self.confirm setTitle:@"确定" forState:UIControlStateNormal];
    [self.confirm setTitleColor:kButtonBackgroudColor forState:UIControlStateNormal];
    [self.confirm addTarget:self action:@selector(confirmYourChoose) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.confirm];
    
    
    
    self.picker = [[UIPickerView alloc]initWithFrame:CGRectMake(0, kButtonHeight, kWidth, kPickerViewHeight)];
    self.picker.delegate = self;
    self.picker.dataSource = self;
    [self addSubview:self.picker];
    
    [self loadAddressData];
    [self.picker reloadAllComponents];
}

- (void)loadAddressData{
    
    [self loadJSONFile:@"province" toArray:self.provinceArray];
    [self loadJSONFile:@"city" toArray:self.cityArray];
    [self loadJSONFile:@"area" toArray:self.areaArray];
    //初始化时加载第一个省级的城市和区县
    [self reloadCityDataWithProvinceId:@1];
    [self reloadAreaDataWithCityId:@1];
}

- (void)loadJSONFile:(NSString*)jsonFile toArray:(NSMutableArray *)marray{
    
    NSString *bundlePath = [[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:@"Resource.bundle"];
    NSBundle *myBundle = [NSBundle bundleWithPath:bundlePath];
    NSString *path = [myBundle pathForResource:jsonFile ofType:@"json"];
    NSData *data   = [[NSData alloc]initWithContentsOfFile:path];
    NSArray *array = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    for (NSDictionary *dic in array) {
        
        [marray addObject:dic];
    }
}
//选择省份时
- (void)reloadCityDataWithProvinceId:(NSNumber *)proId{
    [self.tempCityArray removeAllObjects];
    self.cityStr = @"";
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"ProID = %@",proId];
    
    self.tempCityArray =[NSMutableArray arrayWithArray:[self.cityArray filteredArrayUsingPredicate:predicate]];
    
    [self.picker reloadComponent:1];
    //重选省份时，自动滚动到第一个城市
    [self.picker selectRow:0 inComponent:1 animated:YES];
    //当只选择了省份时，也要改变第一个城市包含的区县；并且重设cityStr和areaStr
    [self reloadAreaDataWithCityId:self.tempCityArray[0][@"CityID"]];
    self.cityStr = self.tempCityArray[0][@"name"];
    if (self.tempAreaArray.count) {
        self.areaStr = self.tempAreaArray[0][@"DisName"];
    }
}
//选择城市时
- (void)reloadAreaDataWithCityId:(NSNumber *)cityId{
    [self.tempAreaArray removeAllObjects];
    self.areaStr = @"";
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"CityID = %@",cityId];
    self.tempAreaArray = [NSMutableArray arrayWithArray:[self.areaArray filteredArrayUsingPredicate:predicate]];

    [self.picker reloadComponent:2];
    //重选城市时，自动滚动到第一个区县
    [self.picker selectRow:0 inComponent:2 animated:YES];
    if (self.tempAreaArray.count) {
        self.areaStr = self.tempAreaArray[0][@"DisName"];
    }
}
#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    switch (component) {
        case 0:
            return self.provinceArray.count;
            break;
        case 1:
            return self.tempCityArray.count;
            break;
        case 2:
            return self.tempAreaArray.count;
            break;
        default:
            break;
    }
    return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    switch (component) {
        case 0:
            return self.provinceArray[row][@"name"];
            break;
        case 1:
            return self.tempCityArray[row][@"name"];
            break;
        case 2:
            return self.tempAreaArray[row][@"DisName"];
            break;
        default:
            return nil;
            break;
    }
    
    return @"There is no value!";
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    switch (component) {
        case 0:{
            NSLog(@"当前选择省级：%@",self.provinceArray[row][@"name"]);
            _provinceStr = _provinceArray[row][@"name"];
            [self reloadCityDataWithProvinceId:_provinceArray[row][@"ProID"]];
            break;}
        case 1:{
            _cityStr = self.tempCityArray[row][@"name"];
            NSLog(@"当前选择City:%@",self.tempCityArray[row][@"name"]);
            [self reloadAreaDataWithCityId:self.tempCityArray[row][@"CityID"]];
            break;}
        case 2:
            _areaStr = [self pickerView:pickerView titleForRow:row forComponent:component];
            NSLog(@"当前选择区县:%@",_areaStr);

            break;
        default:
            break;
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    [self setup];
}
*/
#pragma mark - Private Method
- (void)popupPickerView{
    CGRect frame = self.frame;
    frame.origin.y = kHeight-kPickerViewHeight-kButtonHeight;
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = frame;
    }];
}

- (void)closePickerView{
    
    CGRect frame = self.frame;
    frame.origin.y = kHeight;
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = frame;
    }];
}

- (void)confirmYourChoose{
    [self closePickerView];
    _confirmBlock(_provinceStr,_cityStr,_areaStr);
    
}
@end
