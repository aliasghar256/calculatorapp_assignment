import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(providers: [
      ChangeNotifierProvider(create: (context) => CalculatorProvider()),
      ChangeNotifierProvider(create: (context) => CalculatoryHistoryProvider()),
    ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: CalculatorPage(),
    );
  }
}

class CalculatorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Calculator'),
      actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              // Navigate to the history page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CalculatorHistoryPage()),
              );
            },
          ),
        ],),
      
      body: Column(
        children: [
          Expanded(
            flex: 1, // Display takes 2/3 of the screen
            child: CalculatorScreen(),
          ),
          Expanded(
            flex: 3, // Buttons take 3/3 of the screen
            child: CalculatorButtons(),
          ),
        ],
      ),
    );
  }
}

class CalculatorScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<CalculatorProvider>(
      builder: (context, calculator, child) {
        return Container(
          alignment: Alignment.centerRight,
          padding: EdgeInsets.all(16),
          color: Colors.black,
          child: Text(
            calculator.display, // Display current input or result
            style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        );
      },
    );
  }
}

class CalculatorButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(color:Colors.black, child: GridView.count(
      crossAxisCount: 4,
      children: [
        buildButton(context, 'AC' ), buildButton(context, '+/-'), buildButton(context, '%'), buildButton(context, '÷'),
        buildButton(context, '7'), buildButton(context, '8'), buildButton(context, '9'), buildButton(context, 'x'),
        buildButton(context, '4'), buildButton(context, '5'), buildButton(context, '6'), buildButton(context, '-'),
        buildButton(context, '1'), buildButton(context, '2'), buildButton(context, '3'), buildButton(context, '+'),
        buildButton(context, '0'), buildButton(context, '.'), buildButton(context, '='),
      ],
    ),);
  }

  Widget buildButton(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: () {
          Provider.of<CalculatorProvider>(context, listen: false).input(text,context);
        },
        child: Text(text, style: TextStyle(fontSize: 28)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[700],
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}

class CalculatorProvider extends ChangeNotifier {
  String _display = '0'; // Display current input or result
  double _firstOperand = 0;
  String? _operator; // Stores current operation
  bool _shouldClearDisplay = false;

  String get display => _display;

  // Handle input based on button text
  void input(String buttonText,BuildContext context) {
    if (buttonText == 'AC') {
      clear();
    } else if (buttonText == '=') {
      calculateResult(context: context);
    } else if ('+-*/'.contains(buttonText)) {
      setOperator(buttonText);
    } else {
      appendDigit(buttonText);
    }
    notifyListeners();
  }

  // Append digit to display
  void appendDigit(String digit) {
    if (_shouldClearDisplay || _display == '0') {
      _display = digit;
      _shouldClearDisplay = false;
    } else {
      _display += digit;
    }
  }

  // Set operator for calculation
  void setOperator(String operator) {
    _firstOperand = double.tryParse(_display) ?? 0;
    _operator = operator;
    _shouldClearDisplay = true; // Clear display for new operand input
  }

  // Calculate result based on the current operator
  void calculateResult({required BuildContext context}) {
    if (_operator == null) return;

    double secondOperand = double.tryParse(_display) ?? 0;
    double? result;

    String calculation = '$_firstOperand $_operator $secondOperand = $result';
    Provider.of<CalculatoryHistoryProvider>(context, listen: false).addHistory(calculation);

    switch (_operator) {
      case '+':
        result = _firstOperand + secondOperand;
        break;
      case '-':
        result = _firstOperand - secondOperand;
        break;
      case '*':
        result = _firstOperand * secondOperand;
        break;
      case '/':
        result = secondOperand != 0 ? _firstOperand / secondOperand : 0;
        break;
      default:
        result = secondOperand;
    }

    _display = result.toString();
    _operator = null;
    _shouldClearDisplay = true;
  }

  // Clear display and reset calculator
  void clear() {
    _display = '0';
    _firstOperand = 0;
    _operator = null;
    _shouldClearDisplay = false;
  }
}

class CalculatorHistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<CalculatoryHistoryProvider>(builder: (context, historyProvider, child) {
      return Scaffold(
        appBar: AppBar(title: Text('History')),
        body: ListView.builder(
          itemCount: historyProvider.history.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(historyProvider.history[index]),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            historyProvider.clearHistory();
          },
          child: Icon(Icons.delete),
        ),
      );
    });
  }
}

class CalculatoryHistoryProvider extends ChangeNotifier {
  List<String> _history = [];

  List<String> get history => _history;

  void addHistory(String expression) {
    _history.add(expression);
    notifyListeners();
  }

  void clearHistory() {
    _history.clear();
    notifyListeners();
  }
}