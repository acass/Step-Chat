import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'models/procedure.dart';
import 'models/procedure_step.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const SeedApp());
}

class SeedApp extends StatelessWidget {
  const SeedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: FutureBuilder(
            future: seedData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return const Text('Seeding Complete! You can close this app.');
              }
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              return const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text('Seeding Firestore Data...'),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> seedData() async {
    final firestore = FirebaseFirestore.instance;
    final batch = firestore.batch();

    // 1. Setup Procedure
    final setupRef = firestore.collection('procedures').doc('setup');
    final setupProcedure = Procedure(
      id: 'setup',
      title: 'Setup',
      keywords: ['setup', 'initialization', 'start', 'power'],
      steps: [
        ProcedureStep(
          title: 'Machine Inspection - Step 1',
          description: 'Verify all safety guards are in place and secure.',
          image: 'https://www.sampleimage1.jpg',
          video: '',
          mediaType: 'image',
          completed: false,
        ),
        ProcedureStep(
          title: 'Power On - Step 2',
          description:
              'Turn on the main power disconnect switch located on the wall.',
          image: 'https://www.sampleimage2.jpg',
          video: '',
          mediaType: 'image',
          completed: false,
        ),
        ProcedureStep(
          title: 'Initialization - Step 3',
          description:
              'Press the blue Reset button on the control panel to clear alarms.',
          image: 'https://www.sampleimage3.jpg',
          video: '',
          mediaType: 'image',
          completed: false,
        ),
      ],
    );
    batch.set(setupRef, setupProcedure.toJson());

    // 2. Lubrication Procedure
    final lubeRef = firestore.collection('procedures').doc('lubrication');
    final lubeProcedure = Procedure(
      id: 'lubrication',
      title: 'Lubrication',
      keywords: ['lubrication', 'grease', 'oil', 'maintenance'],
      steps: [
        ProcedureStep(
          title: 'Grease Fittings - Step 1',
          description:
              'Locate the 4 grease fittings on the main bearing blocks.',
          image: 'https://www.sampleimage4.jpg',
          video: '',
          mediaType: 'image',
          completed: false,
        ),
        ProcedureStep(
          title: 'Apply Grease - Step 2',
          description:
              'Apply 2 pumps of lithium grease to each fitting using a grease gun.',
          image: 'https://www.sampleimage5.jpg',
          video: '',
          mediaType: 'image',
          completed: false,
        ),
        ProcedureStep(
          title: 'Check Oil Level - Step 3',
          description:
              'Check the oil level in the gearbox sight glass. It should be halfway up the glass.',
          image: 'https://www.sampleimage1.jpg',
          video: '',
          mediaType: 'image',
          completed: false,
        ),
      ],
    );
    batch.set(lubeRef, lubeProcedure.toJson());

    // 3. Main Drive Procedure
    final driveRef = firestore.collection('procedures').doc('main_drive');
    final driveProcedure = Procedure(
      id: 'main_drive',
      title: 'Main Drive',
      keywords: ['drive', 'motor', 'belt', 'tension'],
      steps: [
        ProcedureStep(
          title: 'Motor Replacement - Step 1',
          description: 'Lock out electrical supply (see page 79).',
          image: 'https://www.sampleimage1.jpg',
          video: '',
          mediaType: '',
          completed: false,
        ),
        ProcedureStep(
          title: 'Motor Replacement - Step 2',
          description:
              'Loosen motor mount nuts [14-2][14-10] and disengage RH belt [14-9].',
          image: 'https://www.sampleimage2.jpg',
          video: '',
          mediaType: 'image',
          completed: false,
        ),
        ProcedureStep(
          title: 'Motor Replacement - Step 3',
          description:
              'Remove motor mount screws [14-3]. Remove motor [14-4] and motor mount [14-11].',
          image: 'https://www.sampleimage3.jpg',
          video: '',
          mediaType: 'image',
          completed: false,
        ),
        ProcedureStep(
          title: 'Motor Replacement - Step 4',
          description:
              'Replace with identical motor, rated for your supply voltage. Tighten mounting hardware to attach motor to motor mount in center of available travel, with motor axis square with motor mount.',
          image: 'https://www.sampleimage4.jpg',
          video: '',
          mediaType: 'image',
          completed: false,
        ),
        ProcedureStep(
          title: 'Motor Replacement - Step 5',
          description:
              'Connect electrical cord to motor according to diagram on new motor.',
          image: 'https://www.sampleimage5.jpg',
          video: '',
          mediaType: 'image',
          completed: false,
        ),
      ],
    );
    batch.set(driveRef, driveProcedure.toJson());

    await batch.commit();
    print('Seeding completed successfully!');
  }
}
