import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'package:soiltrack_mobile/core/utils/notifier_helpers.dart';

final String apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

Future<void> analyzePlantPhase(BuildContext context) async {
  final picker = ImagePicker();
  final XFile? image = await picker.pickImage(source: ImageSource.camera);

  if (image == null) {
    NotifierHelper.showErrorToast(context, 'No image selected');
    return;
  }

  final imageFile = File(image.path);
  final imageBytes = await imageFile.readAsBytes();

  final model = GenerativeModel(model: 'gemini-2.0-flash', apiKey: apiKey);

  final content = [
    Content.multi([
      TextPart(
          'This is a photo of a plant. Can you identify which phase it is in — vegetative, reproductive, or ripening? Explain briefly.'),
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
