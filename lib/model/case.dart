import 'dart:convert';

import 'package:deduct_ai/model/charge.dart';
import 'package:flutter/material.dart';

class Case {
  //String? videoPath; // Path to the video
  String caseName;
  List<String> proofsDetected;
  List<String> paths;
  String caseNote;
  List<Charge> charges;
  List<String> suspects;

  Case({
    //this.videoPath,
    required this.caseName,
    required this.proofsDetected,
    required this.caseNote,
    required this.paths,
    required this.charges,
    required this.suspects,
  });

  factory Case.fromJson(Map<String, dynamic> json) {
    return Case(
      //videoPath: json['videoPath'],
      caseName: json['caseName'],
      proofsDetected: List<String>.from(json['proofsDetected']),
      caseNote: json['caseNote'],
      paths: List<String>.from(json['paths']),
      charges: List<Charge>.from(json['charges']),
      suspects: List<String>.from(json['suspects']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      //'videoPath': videoPath,
      'caseName': caseName,
      'proofsDetected': proofsDetected,
      'caseNote': caseNote,
      'charges': charges,
      'paths': paths,
      'suspects': suspects,
    };
  }
}
