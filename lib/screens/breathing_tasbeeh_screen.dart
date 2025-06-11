import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/dhikr_session.dart';
import '../models/mood.dart';
import '../services/audio_service.dart';
import '../services/storage_service.dart';
import '../widgets/completion_dialog.dart';
import '../screens/reflection_screen.dart';
import 'package:uuid/uuid.dart';

class BreathingTasbeehScreen extends StatefulWidget {
  final DhikrTemplate dhikrTemplate;
  final Mood? mood;

  const BreathingTasbeehScreen({
    Key? key,
    required this.dhikrTemplate,
    this.mood,
  }) : super(key: key);

  @override
  _BreathingTasbeehScreenState createState() => _BreathingTasbeehScreenState();
}

class _BreathingTasbeehScreenState extends State<BreathingTasbeehScreen>
    with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late AnimationController _glowController;
  late AnimationController _rippleController;
  late Animation<double> _breathingAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _rippleAnimation;

  int currentCount = 0;
  bool isActive = false;
  bool showTranslation = true;
  String selectedAmbientSound = 'masjid';
  DateTime? sessionStartTime;

  final List<String> ambientSounds = ['masjid', 'wind', 'night', 'rain', 'silence'];

  @override
  void initState() {
    super.initState();

    _breathingController = AnimationController(
      duration: Duration(seconds: 4),
      vsync: this,
    );

    _glowController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );

    _rippleController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    _breathingAnimation = Tween<double>(begin: 0.8, end: 1.3).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );
  }

  void _startBreathing() {
    setState(() {
      isActive = true;
      sessionStartTime = DateTime.now();
    });
    _breathingController.repeat(reverse: true);
    _glowController.repeat(reverse: true);
    AudioService.playAmbientSound(selectedAmbientSound);
  }

  void _stopBreathing() {
    setState(() {
      isActive = false;
    });
    _breathingController.stop();
    _glowController.stop();
    AudioService.stopAmbientSound();
  }

  void _incrementCount() {
    HapticFeedback.lightImpact();
    AudioService.playTapSound();

    setState(() {
      currentCount++;
    });

    _rippleController.forward().then((_) {
      _rippleController.reset();
    });

    if (currentCount >= widget.dhikrTemplate.recommendedCount) {
      _onTargetReached();
    }
  }

  void _onTargetReached() async {
    HapticFeedback.mediumImpact();
    AudioService.playCompletionSound();
    _stopBreathing();

    // Save session
    final session = DhikrSession(
      id: Uuid().v4(),
      dhikrText: widget.dhikrTemplate.arabicText,
      targetCount: widget.dhikrTemplate.recommendedCount,
      actualCount: currentCount,
      durationMinutes: sessionStartTime != null
          ? DateTime.now().difference(sessionStartTime!).inMinutes
          : 0,
      completedAt: DateTime.now(),
      moodBefore: widget.mood?.id,
    );

    await StorageService.saveDhikrSession(session);

    // Show completion dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CompletionDialog(
        dhikrTemplate: widget.dhikrTemplate,
        session: session,
        onReflect: () {
          Navigator.of(context).pop();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ReflectionScreen(session: session),
            ),
          );
        },
        onFinish: () {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [
              widget.mood?.color.withOpacity(0.2) ?? Colors.teal.withOpacity(0.2),
              Colors.black,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: Center(
                  child: GestureDetector(
                    onTap: _incrementCount,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Ripple effect
                        AnimatedBuilder(
                          animation: _rippleAnimation,
                          builder: (context, child) {
                            return Container(
                              width: 300 * _rippleAnimation.value,
                              height: 300 * _rippleAnimation.value,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(
                                    0.5 * (1 - _rippleAnimation.value),
                                  ),
                                  width: 2,
                                ),
                              ),
                            );
                          },
                        ),
                        // Main circle
                        AnimatedBuilder(
                          animation: Listenable.merge([_breathingAnimation, _glowAnimation]),
                          builder: (context, child) {
                            return Container(
                              width: 280,
                              height: 280,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    Colors.white.withOpacity(0.1),
                                    (widget.mood?.color ?? Colors.teal).withOpacity(
                                      0.2 + (_glowAnimation.value * 0.3),
                                    ),
                                    Colors.transparent,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: (widget.mood?.color ?? Colors.teal).withOpacity(
                                      _glowAnimation.value * 0.6,
                                    ),
                                    blurRadius: 60,
                                    spreadRadius: 20,
                                  ),
                                ],
                              ),
                              transform: Matrix4.identity()
                                ..scale(_breathingAnimation.value),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      widget.dhikrTemplate.arabicText,
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.w300,
                                        color: Colors.white,
                                        height: 1.5,
                                        fontFamily: 'Amiri',
                                      ),
                                      textAlign: TextAlign.center,
                                      textDirection: TextDirection.rtl,
                                    ),
                                    if (showTranslation) ...[
                                      SizedBox(height: 12),
                                      Text(
                                        widget.dhikrTemplate.translation,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white.withOpacity(0.8),
                                          fontStyle: FontStyle.italic,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                    SizedBox(height: 20),
                                    Text(
                                      '$currentCount',
                                      style: TextStyle(
                                        fontSize: 56,
                                        fontWeight: FontWeight.w200,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              _buildControls(),
              _buildBottomInfo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back, color: Colors.white, size: 28),
          ),
          Column(
            children: [
              Text(
                '${currentCount} / ${widget.dhikrTemplate.recommendedCount}',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                widget.dhikrTemplate.transliteration,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              switch (value) {
                case 'reset':
                  setState(() {
                    currentCount = 0;
                  });
                  break;
                case 'translation':
                  setState(() {
                    showTranslation = !showTranslation;
                  });
                  break;
                case 'sound':
                  _showSoundSelector();
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'reset',
                child: Row(
                  children: [
                    Icon(Icons.refresh, size: 20),
                    SizedBox(width: 8),
                    Text('Reset Count'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'translation',
                child: Row(
                  children: [
                    Icon(showTranslation ? Icons.visibility_off : Icons.visibility, size: 20),
                    SizedBox(width: 8),
                    Text(showTranslation ? 'Hide Translation' : 'Show Translation'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'sound',
                child: Row(
                  children: [
                    Icon(Icons.music_note, size: 20),
                    SizedBox(width: 8),
                    Text('Change Sound'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton(
            onPressed: isActive ? _stopBreathing : _startBreathing,
            backgroundColor: widget.mood?.color ?? Colors.teal,
            child: Icon(
              isActive ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
              size: 32,
            ),
            heroTag: "breathing_control",
          ),
        ],
      ),
    );
  }

  Widget _buildBottomInfo() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          if (isActive)
            Text(
              'Breathe slowly and remember Allah',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.7),
                fontStyle: FontStyle.italic,
              ),
            ),
          SizedBox(height: 8),
          Text(
            'Tap the circle to count • ${widget.dhikrTemplate.source}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showSoundSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ambient Sounds',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 16),
            ...ambientSounds.map((sound) => ListTile(
              leading: Icon(_getSoundIcon(sound)),
              title: Text(_getSoundName(sound)),
              trailing: selectedAmbientSound == sound
                  ? Icon(Icons.check, color: widget.mood?.color ?? Colors.teal)
                  : null,
              onTap: () {
                setState(() {
                  selectedAmbientSound = sound;
                });
                if (isActive) {
                  AudioService.playAmbientSound(sound);
                }
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }

  IconData _getSoundIcon(String sound) {
    switch (sound) {
      case 'masjid': return Icons.mosque;
      case 'wind': return Icons.air;
      case 'night': return Icons.nightlight;
      case 'rain': return Icons.grain;
      case 'silence': return Icons.volume_off;
      default: return Icons.music_note;
    }
  }

  String _getSoundName(String sound) {
    switch (sound) {
      case 'masjid': return 'Masjid Ambience';
      case 'wind': return 'Gentle Wind';
      case 'night': return 'Night Sounds';
      case 'rain': return 'Light Rain';
      case 'silence': return 'Silence';
      default: return sound;
    }
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _glowController.dispose();
    _rippleController.dispose();
    AudioService.stopAmbientSound();
    super.dispose();
  }
}// TODO Implement this library.