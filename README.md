# CItyPickerView
城市选择器，支持省市区县三级。

Usage:
在你将要使用选择器的ViewController中，
```Objective-C
# import “CityPickerView.h”
```

```Objective-C
self.picker = [\[CityPickerView alloc]()init];
  self.picker.confirmBlock = ^(NSString *province,NSString *city,NSString *area){
  NSLog(@"%@,%@,%@",province,city,area);
[wself.yourBnt setTitle:\[NSString stringWithFormat:@"%@	%@	%@  ",province,city,area]() forState:UIControlStateNormal];
};
[self.view addSubview:self.picker]();
```

