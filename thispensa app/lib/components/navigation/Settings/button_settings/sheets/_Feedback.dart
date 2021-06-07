import 'dart:io';
import 'dart:typed_data';
import 'package:thispensa/components/navigation/Settings/button_settings/stgButton.dart';
import 'package:feedback/feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:path_provider/path_provider.dart';

class FeedbackWidget extends State<Help> {
  @override
  Widget build(BuildContext context) {
    return MyHomePage();
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Feedback'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              const SizedBox(height: 10),
              const MarkdownBody(
                data: '# Come funziona?\n'
                    '1. Basta premere il pulsante "Fornisci feedback".\n'
                    '2. Si apre la visualizzazione del feedback. '
                    'Puoi scegliere tra la modalità disegno e navigazione. '
                    'Quando sei in modalità di navigazione, puoi navigare liberamente nella '
                    'app. Provalo aprendo il cassetto di navigazione o da '
                    'toccando il pulsante "Apri impalcatura". Per passare alla '
                    'modalità disegno basta premere il pulsante \'Disegna\' a destra '
                    'lato. Ora puoi disegnare sullo schermo.\n'
                    '3. Per completare il tuo feedback, scrivi un messaggio '
                    'sotto e invialo premendo il pulsante \'Invia\'.',
              ),
              ElevatedButton(
                child: const Text('Genera feedback'),
                onPressed: () {
                  BetterFeedback.of(context).show((feedback) async {
                    // draft an email and send to developer
                    final screenshotFilePath =
                        await writeImageToStorage(feedback.screenshot);

                    final Email email = Email(
                      body: feedback.text,
                      subject: 'App Feedback',
                      recipients: ['a.abellonio.0734@vallauri.edu'],
                      attachmentPaths: [screenshotFilePath],
                      isHTML: false,
                    );
                    await FlutterEmailSender.send(email);
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<String> writeImageToStorage(Uint8List feedbackScreenshot) async {
  final Directory output = await getTemporaryDirectory();
  final String screenshotFilePath = '${output.path}/feedback.png';
  final File screenshotFile = File(screenshotFilePath);
  await screenshotFile.writeAsBytes(feedbackScreenshot);
  return screenshotFilePath;
}
