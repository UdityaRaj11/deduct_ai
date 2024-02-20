import 'package:deduct_ai/model/case.dart';
import 'package:deduct_ai/provider/case_provider.dart';
import 'package:deduct_ai/screens/camera_screen.dart';
import 'package:deduct_ai/screens/case_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:deduct_ai/app_constants/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  final String title;
  const HomeScreen({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    final cases = Provider.of<CaseProvider>(context).cases;
    final deviceHeight = MediaQuery.of(context).size.height;
    final deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: AppColors.appTheme[800],
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(deviceHeight * 0.1),
        child: buildAppBar(deviceHeight),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildSearchTextField(deviceHeight, deviceWidth),
              buildCasesGridView(deviceHeight, deviceWidth, cases, context),
            ],
          ),
        ),
      ),
      floatingActionButton: buildFloatingActionButton(context),
    );
  }

  Widget buildAppBar(double deviceHeight) {
    return AppBar(
      backgroundColor: AppColors.appTheme[800],
      title: Text(
        "History",
        style: GoogleFonts.firaSans(
          fontSize: deviceHeight * 0.04,
          color: AppColors.appTheme[50],
          fontWeight: FontWeight.w500,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: Icon(
            Icons.settings,
            color: AppColors.appTheme[50],
          ),
        ),
      ],
    );
  }

  Widget buildSearchTextField(double deviceHeight, double deviceWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: deviceHeight * 0.02,
        horizontal: deviceWidth * 0.05,
      ),
      child: TextField(
        style: GoogleFonts.firaSans(
          color: AppColors.appTheme[50],
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: 'Search for a case...',
          hintStyle: GoogleFonts.firaSans(
            color: AppColors.appTheme[400],
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(
            Icons.search,
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
    );
  }

  Widget buildCasesGridView(double deviceHeight, double deviceWidth,
      List<Case> cases, BuildContext context) {
    return Center(
      child: SizedBox(
        width: deviceWidth * 0.9,
        height: deviceHeight * 0.75,
        child: cases.isNotEmpty
            ? GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: deviceWidth * 0.05,
                  mainAxisSpacing: deviceHeight * 0.02,
                ),
                itemCount: cases.length,
                itemBuilder: (context, index) {
                  return buildCaseContainer(
                      deviceWidth, deviceHeight, cases[index], context);
                },
              )
            : buildEmptyCasesContainer(deviceHeight),
      ),
    );
  }

  Widget buildCaseContainer(double deviceWidth, double deviceHeight,
      Case caseData, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CaseDetailScreen(
              selectedCase: caseData,
            ),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: deviceHeight * 0.02,
          horizontal: deviceWidth * 0.05,
        ),
        decoration: BoxDecoration(
          color: AppColors.appTheme[600],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              caseData.caseName,
              style: GoogleFonts.firaSans(
                fontSize: deviceHeight * 0.025,
                color: AppColors.appTheme[50],
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: deviceHeight * 0.01),
            Text(
              'Suspects: ${caseData.suspects.length}',
              style: GoogleFonts.firaSans(
                fontSize: deviceHeight * 0.02,
                color: AppColors.appTheme[400],
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: deviceHeight * 0.01),
            Text(
              'Proofs: ${caseData.proofsDetected.length}',
              style: GoogleFonts.firaSans(
                fontSize: deviceHeight * 0.02,
                color: AppColors.appTheme[400],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildEmptyCasesContainer(double deviceHeight) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: deviceHeight * 0.2),
            Icon(
              Icons.history,
              size: deviceHeight * 0.1,
              color: AppColors.appTheme[400],
            ),
            SizedBox(height: deviceHeight * 0.02),
            Text(
              'No cases found!',
              style: TextStyle(
                fontSize: deviceHeight * 0.02,
                color: AppColors.appTheme[50],
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: deviceHeight * 0.02),
            Text(
              'Create a new case to get started.',
              style: TextStyle(
                fontSize: deviceHeight * 0.015,
                color: AppColors.appTheme[400],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const CameraScreen(),
          ),
        );
      },
      backgroundColor: Colors.green,
      label: Text(
        'Create New',
        style: GoogleFonts.firaSans(
          color: AppColors.appTheme[50],
          fontWeight: FontWeight.w500,
        ),
      ),
      icon: Icon(
        Icons.video_camera_back,
        color: AppColors.appTheme[50],
      ),
    );
  }
}
