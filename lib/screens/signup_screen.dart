import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'public/image.png',
            fit: BoxFit.cover,
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xB30E4A4A), // ~70% dark teal
                  Color(0xE60A2E2E), // ~90% darker teal
                ],
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // SVG Logo
                  SvgPicture.asset(
                    'public/logo.svg',
                    width: 64,
                    height: 64,
                  ),
                  const SizedBox(height: 28),
                  // Headline
                  Text(
                    'Feel the Beat.\nFlow Sangeet.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 52),
                  // Sign up free button
                  _buildPrimaryButton(
                    label: 'Sign up free',
                    onPressed: () {},
                  ),
                  const SizedBox(height: 14),
                  // Continue with Google
                  _buildOutlineButton(
                    icon: const Icon(
                      MaterialCommunityIcons.google,
                      size: 20,
                      color: Colors.white,
                    ),
                    label: 'Continue with Google',
                    onPressed: () {},
                  ),
                  const SizedBox(height: 14),
                  // Continue with Spotify
                  _buildOutlineButton(
                    icon: const Icon(
                      MaterialCommunityIcons.spotify,
                      size: 20,
                      color: Color(0xFF1DB954),
                    ),
                    label: 'Continue with Spotify',
                    onPressed: () {},
                  ),
                  const SizedBox(height: 28),
                  // Log In
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'Log In',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1AE3B0),
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 0,
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildOutlineButton({
    required Widget icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: icon,
        label: Text(
          label,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15),
          side: const BorderSide(color: Colors.white54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }
}
