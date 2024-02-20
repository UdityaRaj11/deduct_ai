import 'package:deduct_ai/app_constants/app_colors.dart';
import 'package:deduct_ai/model/case.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CaseDetailScreen extends StatelessWidget {
  final Case selectedCase;

  const CaseDetailScreen({Key? key, required this.selectedCase})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;
    final deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appTheme[800],
        title: Text(
          'Case Details',
          style: GoogleFonts.firaSans(
            fontSize: deviceWidth * 0.065,
            color: AppColors.appTheme[50],
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.appTheme[50],
          ),
        ),
      ),
      backgroundColor: AppColors.appTheme[800],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Case Name:',
              style: GoogleFonts.firaSans(
                fontSize: deviceWidth * 0.07,
                color: AppColors.appTheme[400],
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              selectedCase.caseName,
              style: GoogleFonts.firaSans(
                fontSize: deviceWidth * 0.07,
                fontWeight: FontWeight.w500,
                color: AppColors.appTheme[50],
              ),
            ),
            SizedBox(height: deviceHeight * 0.02),
            Text(
              'Suspects:',
              style: GoogleFonts.firaSans(
                fontSize: deviceWidth * 0.06,
                color: AppColors.appTheme[400],
                fontWeight: FontWeight.w600,
              ),
            ),
            // Display list of suspects
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: selectedCase.suspects.map((suspect) {
                return Text(
                  " * $suspect",
                  style: GoogleFonts.firaSans(
                    fontSize: deviceWidth * 0.05,
                    fontWeight: FontWeight.w500,
                    color: AppColors.appTheme[50],
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: deviceHeight * 0.02),
            Text(
              'Proofs Detected:',
              style: GoogleFonts.firaSans(
                fontSize: deviceWidth * 0.06,
                fontWeight: FontWeight.w600,
                color: AppColors.appTheme[400],
              ),
            ),
            // Display list of proofs detected
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: selectedCase.proofsDetected.map((proof) {
                return Text(
                  "> $proof",
                  style: GoogleFonts.firaSans(
                    fontSize: deviceWidth * 0.05,
                    fontWeight: FontWeight.w500,
                    color: AppColors.appTheme[50],
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: deviceHeight * 0.02),
            Text(
              'Case Note:',
              style: GoogleFonts.firaSans(
                fontSize: deviceWidth * 0.06,
                fontWeight: FontWeight.w600,
                color: AppColors.appTheme[400],
              ),
            ),
            Text(
              selectedCase.caseNote,
              style: GoogleFonts.firaSans(
                fontSize: deviceWidth * 0.05,
                fontWeight: FontWeight.w500,
                color: AppColors.appTheme[50],
              ),
            ),
            SizedBox(height: deviceHeight * 0.02),
            Text(
              'Charges:',
              style: GoogleFonts.firaSans(
                fontSize: deviceWidth * 0.06,
                fontWeight: FontWeight.w500,
                color: AppColors.appTheme[400],
              ),
            ),
            // Display list of charges
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: selectedCase.charges.map((charge) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Charge: ${charge.chargeName}',
                      style: GoogleFonts.firaSans(
                        fontSize: deviceWidth * 0.055,
                        fontWeight: FontWeight.w500,
                        color: AppColors.appTheme[50],
                      ),
                    ),
                    Text(
                      'Reason: ${charge.chargeReason}',
                      style: GoogleFonts.firaSans(
                        fontSize: deviceWidth * 0.05,
                        fontWeight: FontWeight.w500,
                        color: AppColors.appTheme[100],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
