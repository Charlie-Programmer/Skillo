import 'package:flutter/material.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            // 
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Text(
                "Messages",
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 24, 105, 172),
                ),
              ),
            ),

            // EMPTY STATE
            Expanded(
              child: Center(
                child: Transform.translate(
                  offset: const Offset(0, -20), 
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 80,
                        color: Color.fromARGB(255, 24, 105, 172),
                      ),
                      SizedBox(height: 16),
                      Text(
                        "No messages yet",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color.fromARGB(255, 94, 92, 92),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Your chats will appear here",
                        style: TextStyle(
                          color: Color.fromARGB(255, 94, 92, 92),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}