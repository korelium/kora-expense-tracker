import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'home_screen.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IntroductionScreen(
        pages: [
          PageViewModel(
            title: "Welcome to Kora",
            body: "Your personal finance companion for tracking expenses and managing money smartly.",
            image: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Icon(
                Icons.account_balance_wallet,
                size: 100,
                color: Theme.of(context).primaryColor,
              ),
            ),
            decoration: const PageDecoration(
              titleTextStyle: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              bodyTextStyle: TextStyle(fontSize: 16),
              imagePadding: EdgeInsets.all(40),
            ),
          ),
          PageViewModel(
            title: "Track Your Expenses",
            body: "Easily add and categorize your transactions to understand where your money goes.",
            image: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Icon(
                Icons.trending_up,
                size: 100,
                color: Theme.of(context).primaryColor,
              ),
            ),
            decoration: const PageDecoration(
              titleTextStyle: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              bodyTextStyle: TextStyle(fontSize: 16),
              imagePadding: EdgeInsets.all(40),
            ),
          ),
          PageViewModel(
            title: "Choose Your Currency",
            body: "Select your preferred currency (INR, USD, EUR) for accurate financial tracking.",
            image: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Icon(
                Icons.attach_money,
                size: 100,
                color: Theme.of(context).primaryColor,
              ),
            ),
            decoration: const PageDecoration(
              titleTextStyle: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              bodyTextStyle: TextStyle(fontSize: 16),
              imagePadding: EdgeInsets.all(40),
            ),
          ),
        ],
        onDone: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        },
        onSkip: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        },
        showSkipButton: true,
        skip: const Text('Skip'),
        next: const Icon(Icons.arrow_forward),
        done: const Text('Get Started'),
        dotsDecorator: DotsDecorator(
          size: const Size(10.0, 10.0),
          color: Colors.grey,
          activeSize: const Size(22.0, 10.0),
          activeColor: Theme.of(context).primaryColor,
          activeShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
        ),
      ),
    );
  }
}
