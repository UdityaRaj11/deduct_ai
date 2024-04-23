import 'package:deduct_ai/app_constants/app_colors.dart';
import 'package:deduct_ai/model/case.dart';
import 'package:deduct_ai/screens/protocol_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ObjectScreen extends StatefulWidget {
  final String? id;
  final Case? requiredCase;
  final List<String>? proofs;
  const ObjectScreen({this.id, this.requiredCase, this.proofs, super.key});

  @override
  State<ObjectScreen> createState() => _ObjectScreenState();
}

class _ObjectScreenState extends State<ObjectScreen> {
  String? caseName = '';
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> _proofs = [
    {'icon': Icons.bloodtype, 'name': "Blood"},
    {'icon': Icons.person, 'name': "Dead Body"},
    {'icon': Icons.local_hospital, 'name': "Drugs"},
    {'icon': Icons.gavel, 'name': "Gun"},
  ];
  final List<Map<String, dynamic>> _selectedProofs = [];

  @override
  void initState() {
    super.initState();
    if (widget.proofs != null) {
      setState(() {
        _proofs = widget.proofs!
            .map((e) => {'icon': Icons.category, 'name': e})
            .toList();
      });
    }
    _selectedProofs.addAll(_proofs);
  }

  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;
    final deviceWidth = MediaQuery.of(context).size.width;
    void _showPopup(BuildContext context) {
      Map<String, Object> newProofName = {};
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: AppColors.appTheme[200],
            title: TextField(
              style: GoogleFonts.firaSans(
                color: AppColors.appTheme[50],
                fontWeight: FontWeight.w500,
              ),
              onChanged: (value) {
                newProofName = {'icon': Icons.category, 'name': value};
              },
              decoration: InputDecoration(
                hintText: 'Enter proof name...',
                hintStyle: GoogleFonts.firaSans(
                  color: AppColors.appTheme[400],
                  fontWeight: FontWeight.w500,
                ),
                filled: true,
                fillColor: AppColors.appTheme[600],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: const Text("Close"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.appTheme[100]),
                onPressed: () {
                  setState(() {
                    if (newProofName.isNotEmpty) {
                      _proofs.add(newProofName);
                      _selectedProofs.add(newProofName);
                    }
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

    return Scaffold(
      resizeToAvoidBottomInset: false,
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: deviceHeight * 0.01,
              horizontal: deviceWidth * 0.05,
            ),
            child: Text(
              "Name of the case",
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
                  caseName = value;
                });
                print(caseName);
              },
              decoration: InputDecoration(
                hintText: 'Give Case a name...',
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
              "Proofs of the case",
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
              "Select most relevant proofs to proceed",
              style: GoogleFonts.firaSans(
                fontSize: deviceWidth * 0.035,
                color: AppColors.appTheme[100],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(
            height: deviceHeight * 0.02,
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(
                horizontal: deviceWidth * 0.05,
              ),
              decoration: BoxDecoration(
                color: AppColors.appTheme[800],
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Scrollbar(
                thumbVisibility: true,
                thickness: 5,
                controller: _scrollController,
                radius: const Radius.circular(5),
                child: ListView.builder(
                  itemCount: _proofs.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () => setState(() {
                        final selectedProof = _proofs[index];
                        if (_selectedProofs.contains(selectedProof)) {
                        } else {
                          _selectedProofs.add(selectedProof);
                        }
                        print(_selectedProofs);
                      }),
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(
                              _proofs[index]['icon'] as IconData,
                              size: deviceWidth * 0.09,
                              color: AppColors.appTheme[50],
                            ),
                            Text(
                              _proofs[index]['name'] as String,
                              style: GoogleFonts.firaSans(
                                fontSize: deviceWidth * 0.045,
                                color: AppColors.appTheme[50],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            InkWell(
                              onTap: () => setState(() {
                                final selectedProof = _proofs[index];
                                if (_selectedProofs.contains(selectedProof)) {
                                  _selectedProofs.remove(selectedProof);
                                } else {
                                  _selectedProofs.add(selectedProof);
                                }
                                print(_selectedProofs);
                              }),
                              child: Icon(
                                _selectedProofs.contains(_proofs[index])
                                    ? Icons.check_circle
                                    : Icons.circle_outlined,
                                size: deviceWidth * 0.09,
                                color: _selectedProofs.contains(_proofs[index])
                                    ? Colors.green
                                    : AppColors.appTheme[500],
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
          ),
          Padding(
            padding: EdgeInsets.only(
              left: deviceWidth * 0.05,
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(
                  vertical: deviceHeight * 0.01,
                  horizontal: deviceWidth * 0.05,
                ),
              ),
              onPressed: () {
                _showPopup(context);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.add,
                    size: deviceWidth * 0.05,
                    color: AppColors.appTheme[50],
                  ),
                  Text(
                    'Add more',
                    style: GoogleFonts.firaSans(
                      fontSize: deviceWidth * 0.04,
                      color: AppColors.appTheme[50],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: deviceHeight * 0.02,
          ),
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedProofs.isEmpty || caseName!.isEmpty
                    ? AppColors.appTheme[600]
                    : Colors.green,
                padding: EdgeInsets.symmetric(
                  vertical: deviceHeight * 0.01,
                  horizontal: deviceWidth * 0.35,
                ),
              ),
              onPressed: () {
                if (_selectedProofs.isEmpty || caseName!.isEmpty) {
                  return;
                }
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ProtocolScreen(
                      id: widget.id,
                      caseName: caseName!,
                      proofs: _selectedProofs,
                    ),
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
          ),
        ],
      ),
    );
  }
}
