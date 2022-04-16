import 'package:directory/config/dependencies.dart';
import 'package:directory/ui/pages/landing_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import '../../services/preference_service.dart';

class IntroductionPage extends StatefulWidget {
  const IntroductionPage({Key? key}) : super(key: key);

  @override
  _IntroductionPageState createState() => _IntroductionPageState();
}

class _IntroductionPageState extends State<IntroductionPage> {
  final _introKey = GlobalKey<IntroductionScreenState>();
  var _skipIntroduction = false;

  void _onIntroEnd(context) {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LandingPage()),
        (route) => false);
  }

  Widget _buildImage(String assetName, [double width = 350]) {
    return Image.asset('assets/introduction/$assetName', width: width);
  }

  @override
  Widget build(BuildContext context) {
    const bodyStyle = TextStyle(fontSize: 19.0);

    const pageDecoration = PageDecoration(
      titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
      bodyTextStyle: bodyStyle,
      bodyPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Colors.white,
      imagePadding: EdgeInsets.fromLTRB(0.0, 65.0, 0.0, 0.0),
    );

    return IntroductionScreen(
      key: _introKey,
      globalBackgroundColor: Colors.white,
      globalHeader: Align(
        alignment: Alignment.topLeft,
        child: SafeArea(
          child: Image.asset(
            'assets/splash.png',
            height: 50,
          ),
        ),
      ),
      globalFooter: SizedBox(
        width: double.infinity,
        height: 60,
        child: CheckboxListTile(
          value: _skipIntroduction,
          controlAffinity: ListTileControlAffinity.leading,
          title: const Text(
            'Do not show again',
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          ),
          onChanged: (value) async {
            setState(() => _skipIntroduction = value ?? false);
            final preferenceService = locator.get<PreferenceService>();
            preferenceService.skipIntroduction = _skipIntroduction;
          },
        ),
      ),
      pages: [
        PageViewModel(
          title: 'Login',
          body: 'Login via email or via Google account.',
          image: _buildImage('login.png'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: 'View & Add Contacts',
          body: 'Search, edit and add contacts from main screen.',
          image: _buildImage('contacts.png'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: 'Details',
          body: 'Fill in details for contacts.',
          image: _buildImage('contact.png'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: 'Contact',
          body: 'Email, text or call contact directly via clicking buttons.',
          image: _buildImage('card.png'),
          decoration: pageDecoration,
        ),
      ],
      onDone: () => _onIntroEnd(context),
      onSkip: () => _onIntroEnd(context),
      // You can override onSkip callback
      showSkipButton: true,
      dotsFlex: 0,
      nextFlex: 0,
      //rtl: true, // Display as right-to-left
      skip: const Text('Skip'),
      next: const Icon(Icons.arrow_forward),
      done: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),
      curve: Curves.fastLinearToSlowEaseIn,
      controlsMargin: const EdgeInsets.all(16),
      controlsPadding: kIsWeb
          ? const EdgeInsets.all(12.0)
          : const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
      dotsDecorator: const DotsDecorator(
        size: Size(10.0, 10.0),
        color: Color(0xFFBDBDBD),
        activeSize: Size(22.0, 10.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
      dotsContainerDecorator: const ShapeDecoration(
        color: Colors.black87,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
      ),
    );
  }
}
