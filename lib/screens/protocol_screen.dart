import 'dart:convert';
import 'dart:io';

import 'package:deduct_ai/model/details.dart';
import 'package:http/http.dart' as http;
import 'package:deduct_ai/app_constants/app_colors.dart';
import 'package:deduct_ai/screens/charge_screen.dart';
import 'package:deduct_ai/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProtocolScreen extends StatefulWidget {
  String? id;
  String? caseName;
  List<Map<String, dynamic>>? proofs;
  ProtocolScreen({this.id, this.proofs, this.caseName, super.key});

  @override
  State<ProtocolScreen> createState() => _ProtocolScreenState();
}

class _ProtocolScreenState extends State<ProtocolScreen> {
  String caseNote = '';
  List<Details> details = [];
  bool _isloading = false;
  Future<void> getDetails() async {
    print(widget.id);
    String apiUrl = 'http://192.168.134.120:8000/api/evidences/${widget.id}/';

    try {
      setState(() {
        _isloading = true;
      });
      var requestBody = jsonEncode({
        'name': widget.caseName,
        'objects':
            widget.proofs!.map((data) => data['name'].toString()).toList(),
      });
      var response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: requestBody,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<Details> evidenceDetails = [];

        final Map<String, dynamic> responseMap = json.decode(response.body);

        final List<dynamic> evidenceList = responseMap['evidence_detail_list'];

        for (final evidenceMap in evidenceList) {
          final evidenceDetail = Details.fromJson(evidenceMap);
          evidenceDetails.add(evidenceDetail);
        }
        setState(() {
          details = evidenceDetails;
          _isloading = false;
        });
      } else {
        print('Request failed with status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error sending request: $e');
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    getDetails();
  }

  String getPrecaution(String proof) {
    final detail = details.firstWhere((element) => element.name == proof);
    return detail.precaution;
  }

  String getProcedure(String proof) {
    final detail = details.firstWhere((element) => element.name == proof);
    return detail.procedure;
  }

  TextEditingController _textFieldController = TextEditingController();
  void _showPopup(BuildContext context, String? proof) {
    _textFieldController.text = caseNote;
    showDialog(
      useSafeArea: false,
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.appTheme[200],
          title: proof != null
              ? Text("Guidelines for $proof")
              : Text(
                  "Add a Note",
                  style: GoogleFonts.firaSans(
                    color: AppColors.appTheme[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
          content: _isloading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : proof == null
                  ? TextField(
                      controller: _textFieldController,
                      maxLines: 15,
                      decoration: InputDecoration(
                        hintText: "Type here...",
                        hintStyle: GoogleFonts.firaSans(
                          color: AppColors.appTheme[400],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  : Scrollbar(
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(getProcedure(proof),
                                  style: GoogleFonts.firaSans(
                                    color: AppColors.appTheme[500],
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  )),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.02,
                              ),
                              Text(getPrecaution(proof),
                                  style: GoogleFonts.firaSans(
                                    color: AppColors.appTheme[500],
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                "Close",
              ),
            ),
            proof != null
                ? const SizedBox()
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.appTheme[100]),
                    onPressed: () {
                      setState(() {
                        final note = _textFieldController.text;
                        caseNote = note;
                      });
                      Navigator.of(context).pop();
                    },
                    child: const Text("Save"),
                  ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;
    final deviceWidth = MediaQuery.of(context).size.width;
    print(caseNote);
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
                      'Fetching...',
                      style: GoogleFonts.firaSans(
                        fontSize: deviceWidth * 0.06,
                        fontWeight: FontWeight.w500,
                        color: AppColors.appTheme[100],
                      ),
                    ),
                    SizedBox(height: deviceHeight * 0.02),
                    CircularProgressIndicator(
                      color: AppColors.appTheme[50],
                    ),
                  ]),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: deviceHeight * 0.02,
                        horizontal: deviceWidth * 0.05,
                      ),
                      child: Text(
                        "Protocol Guidelines",
                        style: GoogleFonts.firaSans(
                          fontSize: deviceWidth * 0.06,
                          color: AppColors.appTheme[50],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: EdgeInsets.symmetric(
                          vertical: deviceHeight * 0.01,
                          horizontal: deviceWidth * 0.05,
                        ),
                      ),
                      onPressed: () {
                        _showPopup(context, null);
                      },
                      child: Text(
                        '+ Note',
                        style: GoogleFonts.firaSans(
                          fontSize: deviceWidth * 0.04,
                          color: AppColors.appTheme[50],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: deviceWidth * 0.05,
                  ),
                  child: Text(
                    "Tap on the proofs to check the guidelines",
                    style: GoogleFonts.firaSans(
                      fontSize: deviceWidth * 0.04,
                      color: AppColors.appTheme[100],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(
                  height: deviceHeight * 0.05,
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: deviceWidth * 0.05,
                    ),
                    color: AppColors.appTheme[800],
                    child: GridView.builder(
                        itemCount: widget.proofs!.length,
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: deviceWidth * 0.5,
                            childAspectRatio: 3 / 2,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20),
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              _showPopup(
                                  context, widget.proofs![index]['name']);
                            },
                            child: Container(
                              width: double.infinity,
                              height: double.infinity,
                              decoration: BoxDecoration(
                                color: AppColors.appTheme[600],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: deviceWidth * 0.02,
                                vertical: deviceHeight * 0.01,
                              ),
                              child: Center(
                                child: Column(
                                  children: [
                                    Icon(
                                      widget.proofs![index]['icon'],
                                      size: deviceWidth * 0.15,
                                      color: AppColors.appTheme[50],
                                    ),
                                    Text(
                                      widget.proofs![index]['name'],
                                      style: GoogleFonts.firaSans(
                                        fontSize: deviceWidth * 0.05,
                                        color: AppColors.appTheme[50],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                  ),
                ),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        color: AppColors.appTheme[500],
                        onPressed: () {
                          Navigator.popUntil(context, (route) => route.isFirst);
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
                          backgroundColor: Colors.green,
                          padding: EdgeInsets.symmetric(
                            vertical: deviceHeight * 0.01,
                            horizontal: deviceWidth * 0.25,
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ChargeScreen(
                                  id: widget.id!,
                                  caseName: widget.caseName!,
                                  proofs: widget.proofs!,
                                  caseNote: caseNote),
                            ),
                          );
                        },
                        child: Text(
                          'Proceed',
                          style: GoogleFonts.firaSans(
                            fontSize: deviceWidth * 0.05,
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
    );
  }
}
