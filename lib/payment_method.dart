import 'package:flutter/material.dart';

class PaymentMethodPage extends StatefulWidget {
  final String initialMethod;

  const PaymentMethodPage({
    super.key,
    required this.initialMethod,
  });

  @override
  State<PaymentMethodPage> createState() => _PaymentMethodPageState();
}

class _PaymentMethodPageState extends State<PaymentMethodPage> {
  late String selectedMethod;

    @override
    void initState() {
      super.initState();
      selectedMethod = widget.initialMethod;
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // Back Button
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back,
                  color: Color.fromARGB(255, 24, 105, 172),
                ),
              ),

              const SizedBox(height: 20),

              // Title
              const Center(
                child: Text(
                  "Select Payment Method",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Color.fromARGB(255, 24, 105, 172),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Credit Card Option
              Row(
                children: [
                  Radio(
                    value: "card",
                    groupValue: selectedMethod,
                    activeColor: const Color.fromARGB(255, 24, 105, 172),
                    onChanged: (value) {
                      setState(() {
                        selectedMethod = value!;
                      });
                    },
                  ),
                  const Text(
                    "Credit / Debit Card",
                    style: TextStyle(
                      color: Color.fromARGB(255, 94, 92, 92),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Card Logos (aligned with text)
              Padding(
                padding: const EdgeInsets.only(left: 48),
                child: Row(
                  children: [
                    _buildCardLogo("assets/visa.png"),
                    const SizedBox(width: 10),
                    _buildCardLogo("assets/mastercard.png"),
                    const SizedBox(width: 10),
                    _buildCardLogo("assets/paypal.png"),
                    const SizedBox(width: 10),
                    _buildCardLogo("assets/maestro.png"),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Gcash Option
              Row(
                children: [
                  Radio(
                    value: "gcash",
                    groupValue: selectedMethod,
                    activeColor: const Color.fromARGB(255, 24, 105, 172),
                    onChanged: (value) {
                      setState(() {
                        selectedMethod = value!;
                      });
                    },
                  ),
                  const Text(
                    "Gcash",                   
                      style: TextStyle(
                      color: Color.fromARGB(255, 94, 92, 92),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Continue Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                   
                    Navigator.pop(context, selectedMethod);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 24, 105, 172),
                    shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text(
                    "CONTINUE",
                    style: TextStyle(
                      color: Colors.white,
                      letterSpacing: 1,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardLogo(String path) {
    return Container(
      height: 30,
      width: 50,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Image.asset(path, fit: BoxFit.contain),
    );
  }
}