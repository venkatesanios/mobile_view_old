import 'package:flutter/cupertino.dart';

class OverAllUse extends ChangeNotifier{
  TextEditingController hourController = TextEditingController();
  TextEditingController minController = TextEditingController();
  TextEditingController secController = TextEditingController();
  int hrs = 0;
  int min = 0;
  int sec = 0;
  int other = 1;
  String am_pm = '';
  int userId = 21;
  int sharedUserId = 21;
  bool takeSharedUserId = false;
  int createUser = 21;
  int controllerId = 10;
  int controllerType = 10;
  int customerId = 10;
  String imeiNo = '';

  int getUserId(){
    if(takeSharedUserId){
      return sharedUserId;
    }else{
      return userId;
    }
  }
  void editUserId(int value){
    userId = value;
    notifyListeners();
  }
  void editSharedUserId(int value){
    sharedUserId = value;
    notifyListeners();
  }
  void editTakeSharedUserId(bool value){
    takeSharedUserId = value;
    notifyListeners();
  }
  void editCustomerId(int value){
    customerId = value;
    notifyListeners();
  }

  void editCreateUser(int value){
    createUser = value;
    notifyListeners();
  }

  void editImeiNo(String value){
    imeiNo = value;
    notifyListeners();
  }

  void editControllerId(int value){
    controllerId = value;
    notifyListeners();
  }

  void editControllerType(int value){
    controllerType = value;
    notifyListeners();
  }


  bool keyBoardAppears = false;

  void editKeyBoardAppears(bool val){
    keyBoardAppears = val;
    notifyListeners();
  }

  void editTimeAll(){
    hrs = 0;
    min = 0;
    sec = 0;
    other = 1;
    am_pm = '';
    notifyListeners();
  }
  void edit_am_pm(String value){
    am_pm = value;
    notifyListeners();
  }
  void editTime(String title, int value){
    switch (title){
      case ('hrs') :{
        hrs = value;
        hourController.text = value.toString();
        break;
      }
      case ('min') :{
        min = value;
        minController.text = value.toString();
        break;
      }
      case ('sec') :{
        sec = value;
        secController.text = value.toString();
        break;
      }
      case ('other') :{
        print(other);
        other = value;
        break;
      }
    }
    notifyListeners();
  }

}