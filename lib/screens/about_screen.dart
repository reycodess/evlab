import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        title: const Text(
          'About EV-LAB',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            // EV-LAB Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF2E7D32),
                    Color(0xFF43A047),
                  ],
                ),
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Column(
                children: [

                  Icon(
                    Icons.biotech,
                    color: Colors.white,
                    size: 75,
                  ),

                  SizedBox(height: 15),

                  Text(
                    'EV-LAB',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 5),

                  Text(
                    'Virtual Enzyme Laboratory',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            _aboutCard(
              icon: Icons.info_outline,
              title: 'About the Application',
              text:
              'EV-LAB is a mobile virtual laboratory designed to provide an interactive environment for exploring enzyme activity and enzyme-related concepts.',
            ),

            _aboutCard(
              icon: Icons.science,
              title: 'Purpose of EV-LAB',
              text:
              'The application provides virtual simulations that allow users to explore how factors such as temperature, pH, substrate concentration, and inhibitors can affect enzyme activity.',
            ),

            _aboutCard(
              icon: Icons.school,
              title: 'Educational Purpose',
              text:
              'EV-LAB is designed as an educational tool for Senior High School STEM students. It aims to make enzyme concepts easier to understand through interactive simulations and visual representations.',
            ),

            _aboutCard(
              icon: Icons.menu_book,
              title: 'What You Can Explore',
              text:
              'Users can learn about enzyme structures, browse enzyme information, examine enzyme activity, and perform virtual enzyme experiments.',
            ),

            const SizedBox(height: 10),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                children: [

                  Icon(
                    Icons.biotech,
                    color: Color(0xFF2E7D32),
                    size: 35,
                  ),

                  SizedBox(height: 10),

                  Text(
                    'EV-LAB',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),

                  SizedBox(height: 5),

                  Text(
                    'Virtual Enzyme Laboratory',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),

                  SizedBox(height: 15),

                  Text(
                    'An interactive environment for learning and exploring enzyme activity.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _aboutCard({
    required IconData icon,
    required String title,
    required String text,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF2E7D32),
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  text,
                  style: TextStyle(
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}