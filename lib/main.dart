import 'package:flutter/material.dart';

void main() => runApp(EVKalkulatorApp());

class EVKalkulatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EV Töltés Kalkulátor',
      theme: ThemeData(primarySwatch: Colors.green),
      home: AkkuKalkulator(),
    );
  }
}

class AkkuKalkulator extends StatefulWidget {
  @override
  _AkkuKalkulatorState createState() => _AkkuKalkulatorState();
}

class _AkkuKalkulatorState extends State<AkkuKalkulator> {
  final TextEditingController _kapacitasController = TextEditingController(text: "51");
  final TextEditingController _szazalekController = TextEditingController();
  
  String _fazis = "1 fázis";
  String _amper = "16A";
  double _celSzazalek = 80.0;
  String _eredmeny = "Várom az adatokat...";
  String _teljesitmeny = "Töltési teljesítmény: - kW";

  void _szamoldKi() {
    double? jelenlegi = double.tryParse(_szazalekController.text.replaceFirst(',', '.'));
    double? kapacitas = double.tryParse(_kapacitasController.text.replaceFirst(',', '.'));

    if (jelenlegi == null || kapacitas == null) {
      setState(() => _eredmeny = "Hiba: Csak számokat adj meg!");
      return;
    }

    int fazisokSzama = _fazis == "1 fázis" ? 1 : 3;
    int amperErtek = int.parse(_amper.replaceAll('A', ''));
    
    double bruttoKW = (230 * amperErtek * fazisokSzama) / 1000.0;
    double nettoKW = bruttoKW * 0.9; // 90%-os hatásfok

    if (jelenlegi >= _celSzazalek) {
      setState(() {
        _teljesitmeny = "Bruttó: ${bruttoKW.toStringAsFixed(2)} kW | Nettó: ${nettoKW.toStringAsFixed(2)} kW";
        _eredmeny = "A cél már teljesült!";
      });
      return;
    }

    double hianyzoKwh = ((_celSzazalek - jelenlegi) / 100.0) * kapacitas;
    double idoOra = hianyzoKwh / nettoKW;

    int h = idoOra.toInt();
    int m = ((idoOra - h) * 60).round();
    if (m == 60) { h++; m = 0; }

    setState(() {
      _teljesitmeny = "Bruttó: ${bruttoKW.toStringAsFixed(2)} kW | Nettó: ${nettoKW.toStringAsFixed(2)} kW";
      _eredmeny = "Idő: $h óra $m perc";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("EV Töltés Kalkulátor Pro")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: _kapacitasController, decoration: InputDecoration(labelText: "Akku kapacitás (kWh)")),
              TextField(controller: _szazalekController, decoration: InputDecoration(labelText: "Jelenlegi töltöttség (%)"), keyboardType: TextInputType.number),
              DropdownButton<String>(
                value: _fazis,
                isExpanded: true,
                onChanged: (val) => setState(() => _fazis = val!),
                items: ["1 fázis", "3 fázis"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              ),
              DropdownButton<String>(
                value: _amper,
                isExpanded: true,
                onChanged: (val) => setState(() => _amper = val!),
                items: ["8A", "10A", "13A", "16A", "32A"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [80, 90, 100].map((e) => Row(children: [
                  Radio(value: e.toDouble(), groupValue: _celSzazalek, onChanged: (double? v) => setState(() => _celSzazalek = v!)),
                  Text("$e%"),
                ])).toList(),
              ),
              SizedBox(height: 20),
              ElevatedButton(onPressed: _szamoldKi, child: Text("IDŐTARTAM SZÁMÍTÁSA"), style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50))),
              SizedBox(height: 20),
              Text(_teljesitmeny, textAlign: TextAlign.center),
              SizedBox(height: 10),
              Text(_eredmeny, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue)),
            ],
          ),
        ),
      ),
    );
  }
}
