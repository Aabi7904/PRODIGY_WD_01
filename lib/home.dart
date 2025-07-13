import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String result = "";
  List<String> steps = []; // Step-by-step BODMAS explanation

  List<String> tokenize(String input) {
    return input
        .replaceAllMapped(
            RegExp(r'(\d+\.?\d*|[+\-*/%])'), (match) => ' ${match[0]} ')
        .trim()
        .split(RegExp(r'\s+'));
  }

  int getHighestPrecedenceIndex(List<String> tokens) {
    List<String> ops = ['*', '/', '%', '+', '-'];
    for (String op in ops) {
      int index = tokens.indexOf(op);
      if (index != -1) return index;
    }
    return -1;
  }

  double operate(double a, double b, String op) {
    switch (op) {
      case '+':
        return a + b;
      case '-':
        return a - b;
      case '*':
        return a * b;
      case '/':
        return a / b;
      case '%':
        return a % b;
      default:
        throw Exception("Invalid operator");
    }
  }

  String evaluateWithSteps(String input) {
    steps.clear();
    input = input.replaceAll('X', '*');
    try {
      List<String> tokens = tokenize(input);

      while (tokens.length > 1) {
        int index = getHighestPrecedenceIndex(tokens);
        double left = double.parse(tokens[index - 1]);
        double right = double.parse(tokens[index + 1]);
        String op = tokens[index];

        double res = operate(left, right, op);
        tokens.replaceRange(index - 1, index + 2, [res.toString()]);

        steps.add(tokens.join(" "));
      }

      return tokens[0];
    } catch (e) {
      return 'Error';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    List<String> list = [
      "AC",
      "C",
      "%",
      "/",
      "7",
      "8",
      "9",
      "X",
      "4",
      "5",
      "6",
      "-",
      "1",
      "2",
      "3",
      "+",
      "00",
      "0",
      ".",
      "=",
    ];
    final operators = ["/", "+", "-", "X", "%", "=", "AC", "C"];

    void updateDisplay(String t) {
      setState(() {
        if (t == "AC") {
          result = "0";
          steps.clear();
        } else if (t == "C") {
          if (result.isNotEmpty) {
            result = result.substring(0, result.length - 1);
          }
        } else if (t == "=") {
          result = evaluateWithSteps(result);
        } else {
          if (result == "0") {
            result = t;
          } else {
            result += t;
          }
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.grey[200],
      ),
      body: SafeArea(
        child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05, vertical: screenHeight * 0.03),
            margin: EdgeInsets.only(bottom: 20),
            alignment: Alignment.bottomRight,
            width: double.infinity,
            height: screenHeight * 0.35,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30)),
              color: Colors.grey[200],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (steps.isNotEmpty)
                  ...steps.map((s) => Text(
                        "=> $s",
                        style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                      )),
                SizedBox(height: 10),
                FittedBox(
                  alignment: Alignment.bottomRight,
                  fit: BoxFit.scaleDown,
                  child: Text(
                    result,
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.count(
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              childAspectRatio: 1.2,
              mainAxisSpacing: screenWidth * 0.03,
              crossAxisSpacing: screenWidth * 0.03,
              padding: EdgeInsets.all(screenWidth * 0.03),
              children: list.map((t) {
                final isOperator = operators.contains(t);
                return SizedBox.expand(
                  child: ElevatedButton(
                    onPressed: () {
                      updateDisplay(t);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isOperator ? Colors.orange : Colors.grey[200],
                      foregroundColor:
                          isOperator ? Colors.white : Colors.black,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        t,
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ]),
      ),
    );
  }
}
