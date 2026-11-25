import 'package:flutter/material.dart';
import '../../data/models/challenge_model.dart';
import 'create_edit_challenge_screen.dart';

class EditChallengeScreen extends StatelessWidget {
  final ChallengeModel challenge;

  const EditChallengeScreen({super.key, required this.challenge});

  @override
  Widget build(BuildContext context) {
    return CreateEditChallengeScreen(challenge: challenge);
  }
}
