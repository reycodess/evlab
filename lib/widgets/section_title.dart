import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF2E7D32),
            Color(0xFF26A69A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.biotech,
              size: 45,
              color: Color(0xFFE91E63),
            ),
          ),
          SizedBox(height: 15),
          Text(
            "EV-LAB",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 30,
            ),
          ),
          SizedBox(height: 5),
          Text(
            "Virtual Enzyme Laboratory",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 17,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Explore • Experiment • Discover",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}