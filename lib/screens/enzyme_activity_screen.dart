import 'package:flutter/material.dart';

class EnzymeActivityScreen extends StatelessWidget {
  const EnzymeActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        title: const Text(
          'Enzyme Activity',
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
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [

            _header(),

            const SizedBox(height: 25),

            const Text(
              'What is Enzyme Activity?',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            _informationCard(
              icon: Icons.speed,
              title: 'Enzyme Activity',
              color: Colors.green,
              text:
              'Enzyme activity describes how effectively an enzyme catalyzes a chemical reaction. It is influenced by environmental and chemical conditions such as temperature, pH, substrate concentration, and inhibitors.',
            ),

            const SizedBox(height: 25),

            const Text(
              'Factors Affecting Enzyme Activity',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            _factorCard(
              icon: Icons.thermostat,
              title: 'Temperature',
              color: Colors.red,
              text:
              'Increasing temperature generally increases molecular movement and reaction rate up to an optimum temperature. Above the optimum, excessive heat may disrupt the enzyme structure and decrease activity.',
            ),

            _factorCard(
              icon: Icons.water_drop,
              title: 'pH',
              color: Colors.blue,
              text:
              'Enzymes have an optimum pH where their activity is highest. Moving too far from this optimum can alter the enzyme structure and reduce its ability to bind with its substrate.',
            ),

            _factorCard(
              icon: Icons.grain,
              title: 'Substrate Concentration',
              color: Colors.orange,
              text:
              'Increasing substrate concentration generally increases reaction rate because more substrate molecules are available. Eventually, the enzyme becomes saturated and the reaction approaches its maximum rate.',
            ),

            _factorCard(
              icon: Icons.block,
              title: 'Inhibitors',
              color: Colors.purple,
              text:
              'Inhibitors reduce enzyme activity by interfering with enzyme-substrate interactions or affecting the enzyme itself. The effect depends on the type and concentration of the inhibitor.',
            ),

            const SizedBox(height: 25),

            _simulationConnection(),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.arrow_back,
                ),
                label: const Text(
                  'BACK TO HOME',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1B5E20),
            Color(0xFF43A047),
          ],
        ),
        borderRadius:
        BorderRadius.circular(22),
      ),
      child: const Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.biotech,
            color: Colors.white,
            size: 50,
          ),

          SizedBox(height: 15),

          Text(
            'Understanding Enzyme Activity',
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 8),

          Text(
            'Learn how different conditions influence the rate of enzyme-catalyzed reactions.',
            style: TextStyle(
              color: Colors.white70,
              height: 1.4,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _informationCard({
    required IconData icon,
    required String title,
    required Color color,
    required String text,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [

          Row(
            children: [
              Container(
                padding:
                const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color:
                  color.withValues(
                    alpha: 0.10,
                  ),
                  borderRadius:
                  BorderRadius.circular(
                    12,
                  ),
                ),
                child: Icon(
                  icon,
                  color: color,
                ),
              ),

              const SizedBox(width: 12),

              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          Text(
            text,
            style: TextStyle(
              color: Colors.grey[700],
              height: 1.5,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _factorCard({
    required IconData icon,
    required String title,
    required Color color,
    required String text,
  }) {
    return Container(
      width: double.infinity,
      margin:
      const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [

          Container(
            padding:
            const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color:
              color.withValues(
                alpha: 0.10,
              ),
              borderRadius:
              BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [

                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 7),

                Text(
                  text,
                  style: TextStyle(
                    color: Colors.grey[700],
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _simulationConnection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius:
        BorderRadius.circular(20),
      ),
      child: const Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [

          Row(
            children: [
              Icon(
                Icons.science,
                color: Color(0xFF2E7D32),
              ),

              SizedBox(width: 10),

              Text(
                'How EV-LAB Uses These Factors',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),
            ],
          ),

          SizedBox(height: 12),

          Text(
            'The EV-LAB virtual laboratory allows you to adjust temperature, pH, substrate concentration, and inhibitor presence. The simulation then calculates a relative enzyme activity value based on the selected conditions.',
            style: TextStyle(
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}