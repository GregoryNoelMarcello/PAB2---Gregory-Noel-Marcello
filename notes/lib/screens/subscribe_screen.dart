import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/fcm_service.dart';

class SubscribeScreen extends StatefulWidget {
  const SubscribeScreen({super.key});

  @override
  State<SubscribeScreen> createState() => _SubscribeScreenState();
}

class _SubscribeScreenState extends State<SubscribeScreen> {
  final FcmService _fcmService = FcmService();
  final TextEditingController _topicController = TextEditingController();
  final List<String> _suggestedTopics = [
    'news',
    'sports',
    'entertainment',
    'gaming',
    'technology',
    'science'
  ];
  final List<String> _otherTopics = [
    'business',
    'health',
    'education',
    'travel',
    'food',
    'music'
  ];

  final Set<String> _subscribedTopics = {};

  @override
  void initState() {
    super.initState();
    _loadSubscribedTopics();
  }

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  Future<void> _loadSubscribedTopics() async {
    // You can load subscribed topics from Firebase or local storage
    // For now, we'll keep it empty
  }

  Future<void> _subscribeTopic(String topic) async {
    if (_subscribedTopics.contains(topic)) {
      final l10n = AppLocalizations.of(context)!;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.alreadySubscribed(topic))),
        );
      }
      return;
    }

    try {
      await _fcmService.subscribeTopic(topic);
      setState(() => _subscribedTopics.add(topic));
      
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.subscribedToTopic(topic))),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _unsubscribeTopic(String topic) async {
    try {
      await _fcmService.unsubscribeTopic(topic);
      setState(() => _subscribedTopics.remove(topic));
      
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.unsubscribedFromTopic(topic))),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _subscribeCustomTopic() async {
    final topic = _topicController.text.trim().toLowerCase();
    
    if (topic.isEmpty) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.customTopicHint)),
      );
      return;
    }

    await _subscribeTopic(topic);
    _topicController.clear();
  }

  Widget _buildTopicButton(String topic, bool isSubscribed) {
    return GestureDetector(
      onTap: () {
        if (isSubscribed) {
          _unsubscribeTopic(topic);
        } else {
          _subscribeTopic(topic);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSubscribed ? Colors.deepPurple : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(24),
          border: isSubscribed
              ? null
              : Border.all(color: Colors.grey.shade400, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSubscribed ? Icons.check_circle : Icons.add_circle_outline,
              color: isSubscribed ? Colors.white : Colors.grey.shade600,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              topic,
              style: TextStyle(
                color: isSubscribed ? Colors.white : Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.subscribeScreenTitle),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Custom Topic Section
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.customTopicTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _topicController,
                            decoration: InputDecoration(
                              hintText: l10n.customTopicHint,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              prefixIcon: const Icon(Icons.topic),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: _subscribeCustomTopic,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                          icon: const Icon(Icons.add),
                          label: Text(l10n.subscribe),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Suggested Topics
            Text(
              l10n.suggestedTopics,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _suggestedTopics
                  .map((topic) => _buildTopicButton(
                        topic,
                        _subscribedTopics.contains(topic),
                      ))
                  .toList(),
            ),

            const SizedBox(height: 24),

            // Other Topics
            Text(
              l10n.otherTopics,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _otherTopics
                  .map((topic) => _buildTopicButton(
                        topic,
                        _subscribedTopics.contains(topic),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
