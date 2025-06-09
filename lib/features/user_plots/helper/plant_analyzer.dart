import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'package:soiltrack_mobile/core/utils/notifier_helpers.dart';

final String apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

Future<void> analyzeSoil(BuildContext context) async {
  final picker = ImagePicker();
  final XFile? image = await picker.pickImage(source: ImageSource.camera);

  if (image == null) {
    NotifierHelper.showErrorToast(context, 'No image selected');
    return;
  }

  final imageFile = File(image.path);
  final imageBytes = await imageFile.readAsBytes();

  final model = GenerativeModel(model: 'gemini-2.0-flash', apiKey: apiKey);

  // final content = [
  //   Content.multi([
  //     TextPart(
  //         'This is a photo of a soil. Can you identify what type of soil it is? Explain briefly.'),
  //     // TextPart(
  //     //     'This is a photo of a plant. Can you identify which phase it is in — vegetative, reproductive, or ripening? Explain briefly.'),
  //     DataPart('image/jpeg', imageBytes),
  //   ])
  // ];

  final content = [
    Content.multi([
      TextPart('''
      This is a photo of a soil. Can you identify what type of soil it is?
      Respond in JSON format like this:

      {
        "soil_type": "<soil type>",
        "explanation": "<brief explanation>"
      }
      '''),
      DataPart('image/jpeg', imageBytes),
    ])
  ];

  try {
    final response = await model.generateContent(content);
    final result = response.text ?? 'No response from Gemini.';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Plant Growth Phase"),
        content: Text(result),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("OK"),
          ),
        ],
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $e")),
    );
  }
}

// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:google_generative_ai/google_generative_ai.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:soiltrack_mobile/core/utils/notifier_helpers.dart';
// import 'package:tflite_flutter/tflite_flutter.dart';
// import 'package:image/image.dart' as img;

// final String apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

// Future<void> loadModel() async {
//   NotifierHelper.logMessage('Loading model...');
//   String? result = await Tflite.loadModel(
//     model: 'assets/soil_model.tflite',
//     numThreads: 1,
//   );
//   print('Model loaded: $result');
// }

// Future<void> analyzeSoil(BuildContext context, File imageFile) async {
//   Load the TFLite model
//   final interpreter =
//       await Interpreter.fromAsset('assets/model/soil_model.tflite');

//   Load the image and decode it
//   final rawImage = await imageFile.readAsBytes();
//   final image = img.decodeImage(rawImage);

//   if (image == null) {
//     print('Failed to decode image');
//     return;
//   }

//   Resize the image to 224x224 (Model input size)
//   img.Image resizedImage = img.copyResize(image, width: 224, height: 224);

//   Normalize pixel values (from 0-255 to 0.0-1.0)
//   Create a List for the input tensor (1, 224, 224, 3)
//   var input = List.generate(
//     1,
//     (i) => List.generate(
//       224,
//       (j) => List.generate(
//         224,
//         (k) => List.generate(
//           3,
//           (l) {
//             Extract RGB values
//             int pixel = resizedImage.getPixel(j, k);
//             double r = img.getRed(pixel).toDouble();
//             double g = img.getGreen(pixel).toDouble();
//             double b = img.getBlue(pixel).toDouble();

//             Normalize to 0.0 - 1.0
//             return [r, g, b].map((val) => val / 255.0).toList()[l];
//           },
//         ),
//       ),
//     ),
//   );

//   var output = List.filled(1 * 1, 0.0).reshape([1, 1]);

//   interpreter.run(input, output);

//   double prediction = output[0][0];
//   String result = prediction > 0.7 ? 'Loam' : 'Clay';

//   NotifierHelper.showSuccessToast(context, 'Soil type: $result');
// }

// Future<void> analyzePlantPhase(BuildContext context) async {
//   final picker = ImagePicker();
//   final XFile? image = await picker.pickImage(source: ImageSource.camera);

//   if (image != null) {
//     File file = File(image.path);
//     await analyzeSoil(context, file);
//   }
// }
