import 'package:flutter/material.dart';

class ScientificBasisScreen extends StatelessWidget {
  const ScientificBasisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        title: const Text(
          'Scientific Basis',
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF1B5E20),
                    Color(0xFF43A047),
                  ],
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [

                  Icon(
                    Icons.menu_book,
                    color: Colors.white,
                    size: 42,
                  ),

                  SizedBox(height: 12),

                  Text(
                    'Scientific Basis of EV-LAB',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 8),

                  Text(
                    'The simulations are based on established principles of enzyme kinetics and enzyme activity.',
                    style: TextStyle(
                      color: Colors.white70,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            _section(
              icon: Icons.thermostat,
              title: 'Temperature',
              text:
              'Temperature affects enzyme activity by influencing molecular motion and the stability of the enzyme structure. Enzyme activity generally increases with temperature up to an optimum range, after which structural changes can reduce activity.',
            ),

            _section(
              icon: Icons.water_drop,
              title: 'pH',
              text:
              'Changes in pH can affect the ionization of amino acid side chains involved in enzyme structure and catalysis. Each enzyme therefore has a characteristic pH range in which activity is favored.',
            ),

            _section(
              icon: Icons.grain,
              title: 'Substrate Concentration',
              text:
              'As substrate concentration increases, enzyme reaction rate can increase until the available active sites become increasingly occupied. The Michaelis-Menten model describes this relationship for many enzyme-catalyzed reactions.',
            ),

            _section(
              icon: Icons.block,
              title: 'Enzyme Inhibition',
              text:
              'Inhibitors can decrease enzyme activity by interfering with enzyme-substrate interactions or by binding to the enzyme. The effect depends on the type of inhibitor and the experimental conditions.',
            ),

            const SizedBox(height: 10),

            const Text(
              'References',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            _reference(
              'Nelson & Cox (2017)',
              'Lehninger Principles of Biochemistry.',
            ),

            _reference(
              'Berg, Tymoczko, Gatto & Stryer (2019)',
              'Biochemistry, 9th Edition.',
            ),

            _reference(
              'Voet, Voet & Pratt (2019)',
              'Fundamentals of Biochemistry: Life at the Molecular Level.',
            ),

            _reference(
              'Michaelis & Menten (1913)',
              'Kinetics of enzyme-catalyzed reactions.',
            ),

            const SizedBox(height: 25),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius:
                BorderRadius.circular(18),
              ),
              child: const Row(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [

                  Icon(
                    Icons.info_outline,
                    color: Color(0xFF2E7D32),
                  ),

                  SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      'EV-LAB is a virtual simulation. Its results represent simulated enzyme activity based on programmed scientific parameters and should not be interpreted as direct laboratory measurements.',
                      style: TextStyle(
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }

  Widget _section({
    required IconData icon,
    required String title,
    required String text,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 15),
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
                  const Color(0xFFE8F5E9),
                  borderRadius:
                  BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color:
                  const Color(0xFF2E7D32),
                ),
              ),

              const SizedBox(width: 12),

              Text(
                title,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            text,
            style: const TextStyle(
              height: 1.5,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _reference(
      String title,
      String description,
      ) {
    return Container(
      width: double.infinity,
      margin:
      const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [

          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            description,
            style: TextStyle(
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}