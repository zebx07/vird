import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/mood.dart';
import '../services/mood_service.dart';
import '../screens/healing_recommendations_screen.dart';

class MoodCheckIn extends StatefulWidget {
  @override
  _MoodCheckInState createState() => _MoodCheckInState();
}

class _MoodCheckInState extends State<MoodCheckIn> with SingleTickerProviderStateMixin {
  Mood? selectedMood;
  String? moodNote;
  bool showNoteInput = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  final TextEditingController _noteController = TextEditingController();

  // Sophisticated mood options with mature icons
  final List<MoodOption> moodOptions = [
    // Positive/Elevated Moods
    MoodOption(
      mood: Mood(id: 'grateful', name: 'Grateful', emoji: '🙏', color: Colors.green),
      icon: Icons.volunteer_activism,
    ),
    MoodOption(
      mood: Mood(id: 'peaceful', name: 'Peaceful', emoji: '☮', color: Colors.blue),
      icon: Icons.spa,
    ),
    MoodOption(
      mood: Mood(id: 'hopeful', name: 'Hopeful', emoji: '✨', color: Colors.orange),
      icon: Icons.wb_sunny,
    ),
    MoodOption(
      mood: Mood(id: 'joyful', name: 'Joyful', emoji: '◉', color: Colors.yellow.shade700),
      icon: Icons.celebration,
    ),
    MoodOption(
      mood: Mood(id: 'blessed', name: 'Blessed', emoji: '⚡', color: Colors.amber),
      icon: Icons.auto_awesome,
    ),
    MoodOption(
      mood: Mood(id: 'inspired', name: 'Inspired', emoji: '◆', color: Colors.lightBlue),
      icon: Icons.lightbulb_outline,
    ),

    // Neutral/Reflective Moods
    MoodOption(
      mood: Mood(id: 'content', name: 'Content', emoji: '◐', color: Colors.purple),
      icon: Icons.balance,
    ),
    MoodOption(
      mood: Mood(id: 'reflective', name: 'Reflective', emoji: '◎', color: Colors.indigo),
      icon: Icons.psychology,
    ),
    MoodOption(
      mood: Mood(id: 'calm', name: 'Calm', emoji: '○', color: Colors.teal),
      icon: Icons.self_improvement,
    ),
    MoodOption(
      mood: Mood(id: 'patient', name: 'Patient', emoji: '⧖', color: Colors.blueGrey),
      icon: Icons.hourglass_empty,
    ),
    MoodOption(
      mood: Mood(id: 'focused', name: 'Focused', emoji: '◯', color: Colors.deepPurple),
      icon: Icons.center_focus_strong,
    ),
    MoodOption(
      mood: Mood(id: 'curious', name: 'Curious', emoji: '◈', color: Colors.cyan),
      icon: Icons.explore,
    ),

    // Challenging/Growth Moods
    MoodOption(
      mood: Mood(id: 'struggling', name: 'Struggling', emoji: '⚔', color: Colors.red),
      icon: Icons.fitness_center,
    ),
    MoodOption(
      mood: Mood(id: 'anxious', name: 'Anxious', emoji: '⚡', color: Colors.orange.shade700),
      icon: Icons.warning_amber,
    ),
    MoodOption(
      mood: Mood(id: 'sad', name: 'Sad', emoji: '◢', color: Colors.blue.shade700),
      icon: Icons.sentiment_dissatisfied,
    ),
    MoodOption(
      mood: Mood(id: 'confused', name: 'Confused', emoji: '◐', color: Colors.brown),
      icon: Icons.help_outline,
    ),
    MoodOption(
      mood: Mood(id: 'tired', name: 'Tired', emoji: '◑', color: Colors.grey),
      icon: Icons.battery_2_bar,
    ),
    MoodOption(
      mood: Mood(id: 'overwhelmed', name: 'Overwhelmed', emoji: '◈', color: Colors.deepOrange),
      icon: Icons.waves,
    ),

    // Spiritual/Seeking Moods
    MoodOption(
      mood: Mood(id: 'seeking', name: 'Seeking', emoji: '◊', color: Colors.purple.shade700),
      icon: Icons.search,
    ),
    MoodOption(
      mood: Mood(id: 'repentant', name: 'Repentant', emoji: '◇', color: Colors.pink),
      icon: Icons.favorite_border,
    ),
    MoodOption(
      mood: Mood(id: 'humble', name: 'Humble', emoji: '◦', color: Colors.green.shade700),
      icon: Icons.eco,
    ),
    MoodOption(
      mood: Mood(id: 'yearning', name: 'Yearning', emoji: '◈', color: Colors.indigo.shade700),
      icon: Icons.north_east,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(theme),
          SizedBox(height: 20),
          _buildMoodGrid(theme),
          if (selectedMood != null) ...[
            SizedBox(height: 20),
            _buildSelectedMoodInfo(theme),
          ],
          if (showNoteInput) ...[
            SizedBox(height: 16),
            _buildNoteInput(theme),
          ],
          if (selectedMood != null) ...[
            SizedBox(height: 20),
            _buildActionButtons(theme),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.primaryColor.withOpacity(0.1),
              ),
              child: Icon(
                Icons.psychology,
                color: theme.primaryColor,
                size: 24,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'How do you feel today?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Text(
          'Take a moment to reflect on your emotional state',
          style: TextStyle(
            fontSize: 14,
            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildMoodGrid(ThemeData theme) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.9,
      ),
      itemCount: moodOptions.length,
      itemBuilder: (context, index) {
        return _buildMoodCard(moodOptions[index], theme);
      },
    );
  }

  Widget _buildMoodCard(MoodOption moodOption, ThemeData theme) {
    final isSelected = selectedMood?.id == moodOption.mood.id;
    final mood = moodOption.mood;

    return GestureDetector(
      onTap: () => _selectMood(mood),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? mood.color.withOpacity(0.15)
              : theme.scaffoldBackgroundColor,
          border: Border.all(
            color: isSelected ? mood.color : theme.dividerColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Use Material Icon instead of emoji
            Icon(
              moodOption.icon,
              size: 28,
              color: isSelected ? mood.color : theme.iconTheme.color?.withOpacity(0.7),
            ),
            SizedBox(height: 6),
            Text(
              mood.name,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? mood.color : theme.textTheme.bodyMedium?.color,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedMoodInfo(ThemeData theme) {
    if (selectedMood == null) return SizedBox.shrink();

    final moodOption = moodOptions.firstWhere((m) => m.mood.id == selectedMood!.id);

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selectedMood!.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selectedMood!.color.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              moodOption.icon,
              size: 32,
              color: selectedMood!.color,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                selectedMood!.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: selectedMood!.color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteInput(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add a note (optional)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        SizedBox(height: 8),
        TextField(
          controller: _noteController,
          maxLines: 2,
          decoration: InputDecoration(
            hintText: 'What\'s on your mind?',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: EdgeInsets.all(12),
          ),
          onChanged: (value) {
            moodNote = value.isEmpty ? null : value;
          },
        ),
      ],
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              HapticFeedback.lightImpact();
              setState(() {
                showNoteInput = !showNoteInput;
              });
            },
            icon: Icon(Icons.edit_note, size: 16),
            label: Text(showNoteInput ? 'Hide Note' : 'Add Note'),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: _navigateToHealing,
            icon: Icon(Icons.healing, size: 16),
            label: Text('Find Healing'),
            style: ElevatedButton.styleFrom(
              backgroundColor: selectedMood!.color,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _selectMood(Mood mood) {
    HapticFeedback.lightImpact();
    setState(() {
      selectedMood = mood;
    });
    _animationController.forward();

    // Record the mood
    MoodService.recordMood(mood);
  }

  void _navigateToHealing() {
    if (selectedMood != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HealingRecommendationsScreen(mood: selectedMood!),
        ),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _noteController.dispose();
    super.dispose();
  }
}

// Helper class to pair moods with icons
class MoodOption {
  final Mood mood;
  final IconData icon;

  MoodOption({required this.mood, required this.icon});
}
