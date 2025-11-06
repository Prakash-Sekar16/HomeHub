import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

class TextFieldInput extends StatelessWidget {
  final TextEditingController textEditingController;
  final bool isPass;
  final String hintText;
  final IconData icon;
  final TextInputType textInputType;
 

  const TextFieldInput(
    {super.key, 
    required this.textEditingController, 
    this.isPass =false, 
    required this.hintText, 
    required this.icon, 
    required this.textInputType,
    }
  );

  @override
  Widget build(BuildContext context) {
    // double screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Center(
        child: SizedBox(
          // width: screenWidth < 600 ? screenWidth * 0.9 : 600, // 90% width on mobile, max 600px on web
          child: TextField(
            obscureText: isPass,
            controller: textEditingController,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(
                color: Colors.black45,
                fontSize: 18,
              ),
              prefixIcon: Icon(
                icon, 
                color: Colors.black45,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              border: InputBorder.none,
              filled: true,
              fillColor: const Color(0xFFedf0f8),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(30),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  width: 2, 
                  color: Colors.blue,
                ),
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
