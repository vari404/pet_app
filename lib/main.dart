import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: VirtualPetGame(),
  ));
}

class VirtualPetGame extends StatefulWidget {
  @override
  _VirtualPetGameState createState() => _VirtualPetGameState();
}

class _VirtualPetGameState extends State<VirtualPetGame> {
  String _petAlias = "Buddy";
  int _moodScore = 50;
  int _appetite = 50;
  int _energy = 50;
  Color _petAppearance = Colors.orange;
  String _emotionStatus = "Content 😌";
  TextEditingController _aliasController = TextEditingController();
  bool _aliasSet = false;
  Timer? _appetiteTimer;
  Timer? _moodTimer;
  Timer? _randomEventTimer;
  bool _victoryAchieved = false;
  bool _defeatOccurred = false;
  int _moodDuration = 0;
  Random _randomGenerator = Random();

  @override
  void initState() {
    super.initState();
    _initializeAppetiteTimer();
    _initializeMoodTimer();
    _initializeRandomEventTimer();
  }

  @override
  void dispose() {
    _appetiteTimer?.cancel();
    _moodTimer?.cancel();
    _randomEventTimer?.cancel();
    super.dispose();
  }

  void _engageWithPet() {
    setState(() {
      _moodScore = (_moodScore + 15).clamp(0, 100);
      _modifyAppetite();
      _decreaseEnergy();
      _refreshPetAppearance();
      _refreshEmotionStatus();
      _verifyDefeatCondition();
    });
  }

  void _nourishPet() {
    setState(() {
      _appetite = (_appetite - 15).clamp(0, 100);
      _enhanceMood();
      _refreshPetAppearance();
      _refreshEmotionStatus();
      _verifyDefeatCondition();
    });
  }

  void _restPet() {
    setState(() {
      _energy = 100;
      _refreshEmotionStatus();
    });
  }

  void _enhanceMood() {
    if (_appetite < 40) {
      _moodScore = (_moodScore - 25).clamp(0, 100);
    } else {
      _moodScore = (_moodScore + 5).clamp(0, 100);
    }
    _refreshPetAppearance();
    _refreshEmotionStatus();
  }

  void _modifyAppetite() {
    _appetite = (_appetite + 7).clamp(0, 100);
    if (_appetite >= 100) {
      _appetite = 100;
      _moodScore = (_moodScore - 25).clamp(0, 100);
    }
    _refreshPetAppearance();
    _refreshEmotionStatus();
  }

  void _decreaseEnergy() {
    _energy = (_energy - 20).clamp(0, 100);
    if (_energy <= 0) {
      _energy = 0;
      _moodScore = (_moodScore - 30).clamp(0, 100);
    }
  }

  void _refreshPetAppearance() {
    if (_moodScore > 75) {
      _petAppearance = Colors.blue;
    } else if (_moodScore >= 35) {
      _petAppearance = Colors.orange;
    } else {
      _petAppearance = Colors.grey;
    }
  }

  void _refreshEmotionStatus() {
    if (_moodScore > 75) {
      _emotionStatus = "Joyful 😄";
    } else if (_moodScore >= 35) {
      _emotionStatus = "Content 😌";
    } else {
      _emotionStatus = "Sad 😢";
    }
  }

  void _assignPetAlias() {
    setState(() {
      _petAlias = _aliasController.text.isNotEmpty ? _aliasController.text : "Buddy";
      _aliasSet = true;
    });
  }

  void _verifyDefeatCondition() {
    if (_appetite >= 100 && _moodScore <= 10) {
      setState(() {
        _defeatOccurred = true;
      });
      _appetiteTimer?.cancel();
      _moodTimer?.cancel();
      _randomEventTimer?.cancel();
    }
  }

  void _initializeAppetiteTimer() {
    _appetiteTimer = Timer.periodic(Duration(seconds: 25), (timer) {
      setState(() {
        _appetite = (_appetite + 5).clamp(0, 100);
        _enhanceMood();
        _verifyDefeatCondition();
      });
    });
  }

  void _initializeMoodTimer() {
    _moodTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_moodScore > 85) {
        _moodDuration++;
        if (_moodDuration >= 180) {
          setState(() {
            _victoryAchieved = true;
          });
          _moodTimer?.cancel();
          _appetiteTimer?.cancel();
          _randomEventTimer?.cancel();
        }
      } else {
        _moodDuration = 0;
      }
    });
  }

  void _initializeRandomEventTimer() {
    _randomEventTimer = Timer.periodic(Duration(seconds: 45), (timer) {
      int event = _randomGenerator.nextInt(3);
      setState(() {
        if (event == 0) {
          _moodScore = (_moodScore - 10).clamp(0, 100);
          _emotionStatus = "Bored 😐";
        } else if (event == 1) {
          _appetite = (_appetite + 10).clamp(0, 100);
          _emotionStatus = "Hungry 🍔";
        } else {
          _energy = (_energy - 15).clamp(0, 100);
          _emotionStatus = "Tired 😴";
        }
        _refreshPetAppearance();
        _verifyDefeatCondition();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_aliasSet) {
      return Scaffold(
        appBar: AppBar(title: Text('Choose Your Pet\'s Name')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _aliasController,
                  decoration: InputDecoration(
                    labelText: 'Pet Name',
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _assignPetAlias,
                  child: Text('Start Adventure'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_victoryAchieved) {
      return Scaffold(
        appBar: AppBar(title: Text('Victory!')),
        body: Center(
          child: Text(
            'Amazing! You kept $_petAlias ecstatic for 3 minutes!',
            style: TextStyle(fontSize: 24),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_defeatOccurred) {
      return Scaffold(
        appBar: AppBar(title: Text('Defeat')),
        body: Center(
          child: Text(
            'Oh no! $_petAlias is too hungry and unhappy.',
            style: TextStyle(fontSize: 24),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Virtual Pet')),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              AnimatedContainer(
                duration: Duration(milliseconds: 500),
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: _petAppearance,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '🐱',
                    style: TextStyle(fontSize: 60),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                'Name: $_petAlias',
                style: TextStyle(fontSize: 22.0),
              ),
              SizedBox(height: 16.0),
              Text(
                'Emotion: $_emotionStatus',
                style: TextStyle(fontSize: 22.0),
              ),
              SizedBox(height: 16.0),
              _buildStatusBar('Mood', _moodScore, Colors.purple),
              SizedBox(height: 8.0),
              _buildStatusBar('Appetite', _appetite, Colors.red),
              SizedBox(height: 8.0),
              _buildStatusBar('Energy', _energy, Colors.green),
              SizedBox(height: 32.0),
              Wrap(
                spacing: 16.0,
                runSpacing: 16.0,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _energy > 0 ? _engageWithPet : null,
                    child: Text('Play'),
                  ),
                  ElevatedButton(
                    onPressed: _nourishPet,
                    child: Text('Feed'),
                  ),
                  ElevatedButton(
                    onPressed: _restPet,
                    child: Text('Rest'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBar(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          '$label: $value',
          style: TextStyle(fontSize: 18.0),
        ),
        LinearProgressIndicator(
          value: value / 100,
          backgroundColor: Colors.grey[300],
          color: color,
          minHeight: 10,
        ),
      ],
    );
  }
}

