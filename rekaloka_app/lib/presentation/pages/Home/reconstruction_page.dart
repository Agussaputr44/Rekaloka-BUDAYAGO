import 'package:flutter/material.dart';
import '../../../common/constants.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final bool isGenerating3D;
  final String? model3DUrl;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.isGenerating3D = false,
    this.model3DUrl,
    required this.timestamp,
  });
}

class ReconstructionPage extends StatefulWidget {
  static const ROUTE_NAME = '/reconstruction';
  const ReconstructionPage({super.key});

  @override
  State<ReconstructionPage> createState() => _ReconstructionPageState();
}

class _ReconstructionPageState extends State<ReconstructionPage> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  bool _showWelcome = true;

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_textController.text.trim().isEmpty) return;

    setState(() {
      // Add user message
      _messages.add(ChatMessage(
        text: _textController.text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _showWelcome = false;
    });

    final userText = _textController.text;
    _textController.clear();
    _isTyping = false;

    // Scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollToBottom();
    });

    // Simulate AI response
    Future.delayed(const Duration(milliseconds: 800), () {
      setState(() {
        _messages.add(ChatMessage(
          text: 'Baik! Saya akan membuat model 3D berdasarkan deskripsi Anda: "$userText". Mohon tunggu sebentar...',
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
      _scrollToBottom();

      // Simulate 3D generation
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _messages.add(ChatMessage(
            text: 'Model 3D sedang dibuat...',
            isUser: false,
            isGenerating3D: true,
            timestamp: DateTime.now(),
          ));
        });
        _scrollToBottom();

        // Show 3D result
        Future.delayed(const Duration(seconds: 3), () {
          setState(() {
            _messages.add(ChatMessage(
              text: 'Model 3D berhasil dibuat! Anda bisa melihat, memutar, dan mengunduhnya.',
              isUser: false,
              model3DUrl: 'https://example.com/model.glb', // URL model 3D
              timestamp: DateTime.now(),
            ));
          });
          _scrollToBottom();
        });
      });
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header
          _buildHeader(context),
          
          // Chat Messages Area
          Expanded(
            child: _showWelcome
                ? _buildWelcomeScreen()
                : _buildChatList(),
          ),
          
          // Input Field
          _buildInputField(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + 12,
        16,
        20,
      ),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        image: const DecorationImage(
          image: AssetImage('assets/images/bg_awan.png'),
          fit: BoxFit.cover,
          opacity: 0.25,
        ),
        color: kPrimaryBrown.withOpacity(0.7),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      Icons.arrow_back_ios,
                      color: kTextWhite,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Rekaloka',
                  style: kHeadingRekaloka.copyWith(
                    color: kTextWhite,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: kAccentOrange.withOpacity(0.3),
              shape: BoxShape.circle,
              border: Border.all(
                color: kTextWhite.withOpacity(0.4),
                width: 2,
              ),
              image: const DecorationImage(
                image: AssetImage('assets/images/bg_awan.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          _buildInstructionCard(),
          const SizedBox(height: 24),
          _buildExamplePrompts(),
        ],
      ),
    );
  }

  Widget _buildInstructionCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: kPrimaryBrown.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: kPrimaryBrown.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Halo! Tuliskan deskripsi objek budaya yang ingin kamu rekonstruksi.',
            textAlign: TextAlign.center,
            style: kSubtitle.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: kPrimaryBrown,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Rekaloka akan mengubah promptmu menjadi model 3D secara otomatis. Semakin detail, semakin akurat hasilnya!',
            textAlign: TextAlign.center,
            style: kBodyText.copyWith(
              fontSize: 13,
              color: kPrimaryBrown.withOpacity(0.7),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExamplePrompts() {
    final examples = [
      'Candi Borobudur dengan detail relief',
      'Rumah Gadang Minangkabau',
      'Wayang Kulit Arjuna dengan detail kostum',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            'Contoh prompt:',
            style: kBodyText.copyWith(
              fontSize: 12,
              color: kPrimaryBrown.withOpacity(0.6),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 12),
        ...examples.map((example) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: GestureDetector(
            onTap: () {
              _textController.text = example;
              setState(() {
                _isTyping = true;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: kInputFillColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: kPrimaryBrown.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 16,
                    color: kAccentOrange,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      example,
                      style: kBodyText.copyWith(
                        fontSize: 13,
                        color: kPrimaryBrown,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildChatList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return _buildChatBubble(message);
      },
    );
  }

  Widget _buildChatBubble(ChatMessage message) {
    if (message.model3DUrl != null) {
      return _build3DPreviewCard(message);
    }

    if (message.isGenerating3D) {
      return _buildGeneratingCard();
    }

    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: message.isUser
              ? kPrimaryBrown
              : kInputFillColor.withOpacity(0.3),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: message.isUser ? const Radius.circular(20) : const Radius.circular(4),
            bottomRight: message.isUser ? const Radius.circular(4) : const Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: kPrimaryBrown.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          message.text,
          style: kBodyText.copyWith(
            fontSize: 14,
            color: message.isUser ? kTextWhite : kPrimaryBrown,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildGeneratingCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kInputFillColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: kAccentOrange.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          const SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(kAccentOrange),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Sedang membuat model 3D...',
            style: kSubtitle.copyWith(
              fontSize: 14,
              color: kPrimaryBrown,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Ini mungkin memakan waktu beberapa detik',
            style: kBodyText.copyWith(
              fontSize: 12,
              color: kPrimaryBrown.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _build3DPreviewCard(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: kPrimaryBrown.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: kPrimaryBrown.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI Message
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: kAccentOrange.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: kAccentOrange,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message.text,
                    style: kBodyText.copyWith(
                      fontSize: 14,
                      color: kPrimaryBrown,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // 3D Preview Area
          Container(
            height: 250,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: kInputFillColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: kPrimaryBrown.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.view_in_ar,
                        size: 60,
                        color: kPrimaryBrown.withOpacity(0.3),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Model 3D Preview',
                        style: kSubtitle.copyWith(
                          fontSize: 14,
                          color: kPrimaryBrown.withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Gesek untuk memutar',
                        style: kBodyText.copyWith(
                          fontSize: 12,
                          color: kPrimaryBrown.withOpacity(0.4),
                        ),
                      ),
                    ],
                  ),
                ),
                // Floating controls
                Positioned(
                  top: 12,
                  right: 12,
                  child: Row(
                    children: [
                      _buildControlButton(Icons.refresh, 'Reset'),
                      const SizedBox(width: 8),
                      _buildControlButton(Icons.zoom_in, 'Zoom'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Action Buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      print('View in AR');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryBrown,
                      foregroundColor: kTextWhite,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.view_in_ar, size: 18),
                    label: Text(
                      'Lihat AR',
                      style: kButtonText.copyWith(fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      print('Download');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kAccentOrange,
                      foregroundColor: kTextWhite,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.download, size: 18),
                    label: Text(
                      'Unduh',
                      style: kButtonText.copyWith(fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton(IconData icon, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: kPrimaryBrown.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 18,
          color: kPrimaryBrown,
        ),
      ),
    );
  }

  Widget _buildInputField() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Image picker button
          GestureDetector(
            onTap: () {
              print('Pick image');
              // TODO: Implement image picker
              // final ImagePicker picker = ImagePicker();
              // final XFile? image = await picker.pickImage(source: ImageSource.gallery);
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.image_outlined,
                color: kPrimaryBrown.withOpacity(0.6),
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Input field
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: _isTyping 
                      ? kAccentOrange.withOpacity(0.4) 
                      : Colors.grey.withOpacity(0.25),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 8),
                    child: Icon(
                      Icons.edit_outlined,
                      color: _isTyping 
                          ? kAccentOrange 
                          : Colors.grey.withOpacity(0.4),
                      size: 18,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      onChanged: (value) {
                        setState(() {
                          _isTyping = value.isNotEmpty;
                        });
                      },
                      maxLines: null,
                      maxLength: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      style: kBodyText.copyWith(
                        fontSize: 14,
                        color: Colors.black87,
                        fontWeight: FontWeight.w400,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Tuliskan sesuatu...',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.withOpacity(0.45),
                          fontWeight: FontWeight.w400,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 0,
                          vertical: 12,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Send button
                  Container(
                    margin: const EdgeInsets.only(right: 4),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _isTyping ? _sendMessage : null,
                        borderRadius: BorderRadius.circular(25),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _isTyping 
                                ? kAccentOrange 
                                : Colors.grey.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.arrow_forward,
                            color: _isTyping 
                                ? Colors.white 
                                : Colors.grey.withOpacity(0.4),
                            size: 18,
                          ),
                        ),
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
}