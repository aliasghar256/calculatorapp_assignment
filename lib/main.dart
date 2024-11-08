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
      appBar: AppBar(
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
          alignment: Alignment.bottomRight,
          padding: EdgeInsets.all(16),
          color: Colors.black,
          child: Text(
            calculator.display, // Display current input or result
            style: TextStyle(fontFamily: 'Roboto' ,fontSize: 60, fontWeight: FontWeight.w300, color: Colors.white),
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
        buildButton(context, 'AC','FFA5A5A5' ), buildButton(context, '+/-','FFA5A5A5' ), buildButton(context, '%','FFA5A5A5'), buildButton(context, '÷','FFFF9500'),
        buildButton(context, '7','FF333333'), buildButton(context, '8','FF333333'), buildButton(context, '9','FF333333'), buildButton(context, 'x','FFFF9500'),
        buildButton(context, '4','FF333333'), buildButton(context, '5','FF333333'), buildButton(context, '6','FF333333'), buildButton(context, '-','FFFF9500'),
        buildButton(context, '1','FF333333'), buildButton(context, '2','FF333333'), buildButton(context, '3','FF333333'), buildButton(context, '+','FFFF9500'),
        buildButton(context, '0','FF333333'), buildButton(context, '.','FF333333'), buildButton(context, '=','FFFF9500'),
      ],
    ),);
  }

  Widget buildButton(BuildContext context, String text, String colorCode) {

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: () {
          Provider.of<CalculatorProvider>(context, listen: false).input(text,context);
        },
        child: Text(text, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w300)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(int.parse(colorCode, radix: 16)) ,
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
    } else if ('+-x÷'.contains(buttonText)) {
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
    if (operator == "x") {
      operator = "*";
    }
    else if (operator == "÷") {
      operator = "/";
    }
    _firstOperand = double.tryParse(_display) ?? 0;
    _operator = operator;
    _shouldClearDisplay = true; // Clear display for new operand input
  }

  // Calculate result based on the current operator
  void calculateResult({required BuildContext context}) {
    if (_operator == null) return;

    double secondOperand = double.tryParse(_display) ?? 0;
    double? result;

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
    String calculation = '$_firstOperand $_operator $secondOperand = $result';
    Provider.of<CalculatoryHistoryProvider>(context, listen: false).addHistory(calculation);
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
        appBar: AppBar(title: Text('History'),
        actions: [
          IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              // Clear history
              historyProvider.clearHistory();
            },
          ),
        ],
        ),
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