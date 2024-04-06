import 'dart:io';
import 'dart:typed_data';

import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class PdfMaker extends StatefulWidget {
  const PdfMaker({super.key});

  @override
  State<PdfMaker> createState() => _PdfMakerState();
}

class _PdfMakerState extends State<PdfMaker> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Pdf Maker',
        home: AnimatedSplashScreen(
            duration: 5000,
            splash: Center(
              child: Container(
                width: 300, // Example: Setting width
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  border: Border.all(
                    color: Colors.black, // Set the border color here
                    width: 2.0,
                    // Set the border width here
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  // Example: Clipping with border radius
                  child: Image.asset(
                    'assets/pdf.png',
                    // width: 800, // Example: Setting width
                    // height: 800, // Example: Setting height
                    fit: BoxFit.fill, // Example: Adjusting image fit
                  ),
                ),
              ),
            ),
            nextScreen: MyApp(),
            splashTransition: SplashTransition.rotationTransition,
            backgroundColor: Color(0xff23be9e)),
        // debugShowCheckedModeBanner: false,
        // title: "Image PdfMaker",
        theme: ThemeData(
          primaryColor: Color(0xff23be9e),
        ));
    // home: MyApp(),
    //  );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final picker = ImagePicker();
  final pdf = pw.Document();
  List<File> image = [];
  var pageformat = "A4";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          image.length == 0
              ? Center(
                  child: Container(
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            "Select image from Camera or Gallery",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Color(0xff1C2837), fontSize: 30),
                          )
                        ],
                      ),
                    ),
                  ),
                )
              : PdfPreview(
                  maxPageWidth: 1000,
                  canChangeOrientation: true,
                  canDebug: false,
                  build: (format) => _generatePdf(format, image.length, image),
                ),
          Align(
            alignment: Alignment(-0.5, 0.8),
            child: FloatingActionButton(
              elevation: 0.0,
              child: new Icon(Icons.image),
              backgroundColor: Color(0xff23be9e),
              onPressed: getImage,
            ),
          ),
          Align(
            alignment: Alignment(0.5, 0.8),
            child: FloatingActionButton(
              elevation: 0.0,
              child: new Icon(Icons.camera_alt),
              backgroundColor: Color(0xff23be9e),
              onPressed: getImagecam,
            ),
          )
        ],
      ),
    );
  }

  getImage() async {
    final img = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (img != null) {
        image.add(File(img.path));
      } else {
        print("No image selected");
      }
    });
  }

  getImagecam() async {
    final img = await picker.pickImage(source: ImageSource.camera);

    setState(() {
      if (img != null) {
        image.add(File(img.path));
      } else {
        print("No image selected");
      }
    });
  }

  Future<Uint8List> _generatePdf(
      PdfPageFormat format, imgFileLength, file) async {
    final pdf = pw.Document(pageMode: PdfPageMode.outlines);

    final font1 = await PdfGoogleFonts.openSansRegular();
    final font2 = await PdfGoogleFonts.openSansBold();

    for (var im in file) {
      final showimage = pw.MemoryImage(im.readAsBytesSync());
      pdf.addPage(
        pw.Page(
          pageTheme: pw.PageTheme(
            pageFormat: format.copyWith(
              marginBottom: 0,
              marginLeft: 0,
              marginRight: 0,
              marginTop: 0,
            ),
            orientation: pw.PageOrientation.portrait,
            theme: pw.ThemeData.withFont(base: font1, bold: font2),
          ),
          build: (context) {
            return pw.Center(
              child: pw.Image(showimage, fit: pw.BoxFit.contain),
            );
          },
        ),
      );
    }
    return await pdf.save();
  }
}
