import 'dart:convert';
import 'dart:io';
import 'package:deduct_ai/model/section.dart';
import 'package:http/http.dart' as http;

import 'package:deduct_ai/app_constants/app_colors.dart';
import 'package:deduct_ai/model/case.dart';
import 'package:deduct_ai/model/charge.dart';
import 'package:deduct_ai/provider/case_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ChargeScreen extends StatefulWidget {
  String? id;
  String? caseName;
  List<Map<String, dynamic>>? proofs;
  String? caseNote;
  ChargeScreen({this.id, this.caseName, this.proofs, this.caseNote, super.key});

  @override
  State<ChargeScreen> createState() => _ChargeScreenState();
}

class _ChargeScreenState extends State<ChargeScreen> {
  final ScrollController _scrollController1 = ScrollController();
  final ScrollController _scrollController2 = ScrollController();
  List<String> _charges = [
    "IPC Section 302",
    "IPC Section 304",
    "NDPS Act, 1985",
    "Arms Act, 1959",
    "IPC Section 411",
    "IPC Section 506",
  ];
  final List<String> _selectedCharges = [];
  final List<Charge> _chargesList = [];
  final List<Section> _sections = [];
  bool _isloading = false;
  String? _suspect = '';
  final List<File> _proofs = []; // Store selected proofs
  Future<void> getSections() async {
    print(widget.id);
    String apiUrl = 'http://13.49.30.1:3000/api/sections/${widget.id}/';

    try {
      setState(() {
        _isloading = false;
      });
      var requestBody = jsonEncode({
        'notes': widget.caseNote,
      });
      var response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: requestBody,
      );
      final List<Section> sections = [];

      if (response.statusCode == 200 || response.statusCode == 201) {
        RegExp regExp =
            RegExp(r'(\d+)\.\s*(Section\s+\d+\s+of\s+.+?)\s*-\s*(.*)');

        final Map<String, dynamic> responseMap = json.decode(response.body);

        final String text = responseMap['section_list'];
        Iterable<RegExpMatch> matches = regExp.allMatches(text);
        print(matches);
        for (RegExpMatch match in matches) {
          String tag = match.group(2)!;
          String description = match.group(3)!;
          sections.add(Section(tag: tag, description: description));
        }
        setState(() {
          _sections.addAll(sections);
          _charges = sections.map((section) => section.tag).toList();
          _isloading = false;
        });
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending request: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    getSections().then((value) => _selectedCharges.addAll(_charges));
  }

  @override
  Widget build(BuildContext context) {
    void _showPopup(BuildContext context, String charge) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: AppColors.appTheme[200],
            title: Text(charge),
            content: Text(_sections
                .firstWhere((section) => section.tag == charge)
                .description),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Close"),
              ),
            ],
          );
        },
      );
    }

    Future<void> pickFile() async {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null) {
        setState(() {
          _proofs.add(File(result.files.single.path!));
        });
      }
    }

    void removeProof(int index) {
      setState(() {
        _proofs.removeAt(index);
      });
    }

    final provideCase = Provider.of<CaseProvider>(context, listen: false);
    void _saveCase() {
      Case newCase = Case(
        caseName: widget.caseName.toString(),
        proofsDetected:
            widget.proofs!.map((proof) => proof['name'] as String).toList(),
        caseNote: widget.caseNote.toString(),
        charges: _chargesList,
        suspects: List<String>.from(
          _suspect!.split(','),
        ),
        paths: _proofs.map((proof) => proof.path).toList(),
      );

      provideCase.addCase(newCase);
      print(_chargesList);
      print(provideCase.cases);
      Navigator.popUntil(context, (route) => route.isFirst);
    }

    final deviceHeight = MediaQuery.of(context).size.height;
    final deviceWidth = MediaQuery.of(context).size.width;
    print("${widget.caseName}");
    print(provideCase.cases);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: AppColors.appTheme[50]),
        ),
        backgroundColor: AppColors.appTheme[800],
      ),
      backgroundColor: AppColors.appTheme[800],
      body: _isloading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Thinking...',
                    style: GoogleFonts.firaSans(
                      color: AppColors.appTheme[200],
                      fontSize: deviceWidth * 0.06,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  CircularProgressIndicator(
                    color: AppColors.appTheme[600],
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: SizedBox(
                height: deviceHeight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: deviceHeight * 0.01,
                        horizontal: deviceWidth * 0.05,
                      ),
                      child: Text(
                        "Name of the suspect(s)",
                        style: GoogleFonts.firaSans(
                          fontSize: deviceWidth * 0.065,
                          color: AppColors.appTheme[50],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: deviceWidth * 0.05,
                      ),
                      child: TextField(
                        style: GoogleFonts.firaSans(
                          color: AppColors.appTheme[50],
                          fontWeight: FontWeight.w500,
                        ),
                        onSubmitted: (value) {
                          setState(() {
                            _suspect = value;
                          });
                          print(_suspect);
                        },
                        decoration: InputDecoration(
                          hintText: 'Enter name(s) here...',
                          hintStyle: GoogleFonts.firaSans(
                            color: AppColors.appTheme[400],
                            fontWeight: FontWeight.w500,
                          ),
                          prefixIcon: Icon(
                            Icons.edit,
                            color: AppColors.appTheme[400],
                          ),
                          filled: true,
                          fillColor: AppColors.appTheme[600],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        top: deviceHeight * 0.02,
                        left: deviceWidth * 0.05,
                        right: deviceWidth * 0.05,
                      ),
                      child: Text(
                        "Charges Applicable",
                        style: GoogleFonts.firaSans(
                          fontSize: deviceWidth * 0.055,
                          color: AppColors.appTheme[50],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: deviceWidth * 0.05,
                      ),
                      child: Text(
                        "Select most relevant Charges to proceed",
                        style: GoogleFonts.firaSans(
                          fontSize: deviceWidth * 0.04,
                          color: AppColors.appTheme[100],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: deviceHeight * 0.02,
                    ),
                    Container(
                      height: deviceHeight * 0.32,
                      margin: EdgeInsets.only(
                        right: deviceWidth * 0.05,
                        left: deviceWidth * 0.05,
                        bottom: deviceHeight * 0.02,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.appTheme[800],
                        border: Border.all(color: Colors.grey),
                      ),
                      child: Scrollbar(
                        thumbVisibility: true,
                        thickness: 5,
                        radius: const Radius.circular(5),
                        controller: _scrollController1,
                        child: ListView.builder(
                          itemCount: _charges.length,
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () => _showPopup(context, _charges[index]),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: deviceWidth * 0.05,
                                  vertical: deviceHeight * 0.02,
                                ),
                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Color.fromARGB(255, 80, 80, 80),
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              _charges[index],
                                              style: GoogleFonts.firaSans(
                                                fontSize: deviceWidth * 0.04,
                                                color: AppColors.appTheme[50],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            SizedBox(
                                              width: deviceWidth * 0.02,
                                            ),
                                            Icon(
                                              Icons.info,
                                              color: Colors.blue,
                                              size: deviceWidth * 0.06,
                                            ),
                                          ],
                                        ),
                                        InkWell(
                                          onTap: () => setState(() {
                                            final selectedCharge =
                                                _charges[index];
                                            if (_selectedCharges
                                                .contains(selectedCharge)) {
                                              _selectedCharges
                                                  .remove(selectedCharge);
                                            } else {
                                              _selectedCharges.add(
                                                  selectedCharge.toString());
                                            }
                                            print(_selectedCharges);
                                          }),
                                          child: Icon(
                                            _selectedCharges
                                                    .contains(_charges[index])
                                                ? Icons.check_circle
                                                : Icons.circle_outlined,
                                            size: deviceWidth * 0.09,
                                            color: _selectedCharges
                                                    .contains(_charges[index])
                                                ? Colors.green
                                                : AppColors.appTheme[500],
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (_selectedCharges
                                        .contains(_charges[index]))
                                      SizedBox(
                                        height: deviceHeight * 0.01,
                                      ),
                                    if (_selectedCharges
                                        .contains(_charges[index]))
                                      TextField(
                                        style: GoogleFonts.firaSans(
                                          color: AppColors.appTheme[50],
                                          fontWeight: FontWeight.w500,
                                        ),
                                        onSubmitted: (value) {
                                          setState(() {
                                            final newCharge = Charge(
                                              chargeName: _charges[index],
                                              chargeReason: value,
                                            );
                                            final existingChargeIndex =
                                                _chargesList
                                                    .indexWhere((element) =>
                                                        element.chargeName ==
                                                        newCharge.chargeName);
                                            if (existingChargeIndex != -1) {
                                              _chargesList[existingChargeIndex]
                                                      .chargeReason =
                                                  newCharge.chargeReason;
                                            } else {
                                              _chargesList.add(newCharge);
                                            }
                                            print(_chargesList);
                                          });
                                        },
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(
                                            vertical: deviceHeight * 0.01,
                                            horizontal: deviceWidth * 0.02,
                                          ),
                                          hintText: 'Give reasons...',
                                          hintStyle: GoogleFonts.firaSans(
                                            color: AppColors.appTheme[400],
                                            fontWeight: FontWeight.w500,
                                          ),
                                          filled: true,
                                          fillColor: AppColors.appTheme[600],
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            borderSide: BorderSide.none,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: deviceWidth * 0.05,
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Attach Proof(s)',
                            style: GoogleFonts.firaSans(
                              fontSize: deviceWidth * 0.05,
                              color: AppColors.appTheme[50],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: deviceWidth * 0.01),
                          IconButton(
                            onPressed: pickFile,
                            icon: const Icon(Icons.attach_file,
                                color: Colors.yellow),
                            tooltip: 'Attach Proof(s)',
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: deviceHeight * 0.1,
                      margin: EdgeInsets.only(
                        right: deviceWidth * 0.05,
                        left: deviceWidth * 0.05,
                        bottom: deviceHeight * 0.02,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.appTheme[800],
                        border: Border.all(color: Colors.grey),
                      ),
                      child: Scrollbar(
                        thumbVisibility: true,
                        radius: const Radius.circular(5),
                        thickness: 5,
                        controller: _scrollController2,
                        child: ListView.builder(
                          itemCount: _proofs.length,
                          itemBuilder: (context, index) {
                            final fileName = basename(_proofs[index].path);
                            return ListTile(
                              title: Text(
                                fileName,
                                style: TextStyle(
                                  color: AppColors.appTheme[50],
                                ),
                              ),
                              trailing: IconButton(
                                onPressed: () => removeProof(index),
                                icon: const Icon(Icons.remove_circle,
                                    color: Colors.red),
                                tooltip: 'Remove Proof',
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            color: AppColors.appTheme[500],
                            onPressed: () {
                              Navigator.popUntil(
                                  context, (route) => route.isFirst);
                            },
                            icon: Icon(
                              Icons.home_rounded,
                              size: deviceWidth * 0.1,
                            ),
                          ),
                          SizedBox(
                            width: deviceWidth * 0.05,
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _selectedCharges.isEmpty
                                  ? AppColors.appTheme[600]
                                  : Colors.blue,
                              padding: EdgeInsets.symmetric(
                                vertical: deviceHeight * 0.01,
                                horizontal: deviceWidth * 0.05,
                              ),
                            ),
                            onPressed: () {
                              if (_selectedCharges.isEmpty) {
                                return;
                              }
                            },
                            child: Text(
                              'Genrate Report',
                              style: GoogleFonts.firaSans(
                                fontSize: deviceWidth * 0.04,
                                color: AppColors.appTheme[50],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: deviceWidth * 0.05,
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _selectedCharges.isEmpty
                                  ? AppColors.appTheme[600]
                                  : Colors.green,
                              padding: EdgeInsets.symmetric(
                                vertical: deviceHeight * 0.01,
                                horizontal: deviceWidth * 0.05,
                              ),
                            ),
                            onPressed: () {
                              if (_selectedCharges.isEmpty) {
                                return;
                              } else {
                                _saveCase();
                              }
                            },
                            child: Text(
                              'Save Case',
                              style: GoogleFonts.firaSans(
                                fontSize: deviceWidth * 0.04,
                                color: AppColors.appTheme[50],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
