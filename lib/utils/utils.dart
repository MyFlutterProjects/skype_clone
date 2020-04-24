import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as Im;
import 'package:path_provider/path_provider.dart';
import 'package:skype_clone/enum/user_state.dart';

class Utils { 
  static String getUsername(String email) {
    return "live:${email.split('@')[0]}";
  }

  static String getInitials(String name) {
    List<String> nameSplit = name.split(" ");
    String firstNameInitial = nameSplit[0][0];
    String lastNameInitial = nameSplit[1][0];
    return firstNameInitial + lastNameInitial;
  }

  static Future<File> pickImage({@required ImageSource source}) async {
     File selectedImage = await ImagePicker.pickImage(source: source);
     return compressImage(selectedImage);
     }

  static Future<File> compressImage(File imageToCompress) async {
    
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    int random = Random().nextInt(1000);

    Im.Image image = Im.decodeImage(imageToCompress.readAsBytesSync());
    Im.copyResize(image,width: 500, height: 500 );
    return new File('$path/img_$random.jpg')..writeAsBytesSync(Im.encodeJpg(image, quality:85));


  }

  static int stateToNum(UserState userState) { 
    switch(userState) {
      case UserState.offline:
       return 0;
      case UserState.online:
       return 1;
      default:
       return 2;
    }
  }

  static UserState numToState(int number) {
    switch(number) {
      case 0:
       return  UserState.offline;
      case 1:
       return UserState.online;
      default:
      return UserState.waiting;
      
    }
  }
}

