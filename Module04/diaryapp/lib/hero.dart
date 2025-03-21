import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants.dart';

class HeroWidget extends StatelessWidget {
  const HeroWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/home.jpg'), // Remplace par le chemin de ton image
              fit: BoxFit.cover,
            ),
          ),
        ),
        Column(
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(margin),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'My',
                      style: GoogleFonts.spaceGrotesk(
                        color: const Color.fromARGB(255, 40, 5, 100), // Couleur du texte en blanc pour contraster
                        fontSize: 60,
                        height: 0.8,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'DiaryApp',
                      style: GoogleFonts.spaceGrotesk(
                        color: const Color.fromARGB(255, 31, 5, 58),
                        fontSize: 50,
                        height: 0.8,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
