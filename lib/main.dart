import 'package:flutter/material.dart';

void main() => runApp(EVKalkulatorApp());

class EVKalkulatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Color(0xFF121212),
        cardTheme: CardThemeData( // Itt változtattuk meg!
          color: Color(0xFF1E1E1E),
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
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
  String _teljesitmeny = "- kW";

  void _szamoldKi() {
    double? jelenlegi = double.tryParse(_szazalekController.text.replaceFirst(',', '.'));
    double? kapacitas = double.tryParse(_kapacitasController.text.replaceFirst(',', '.'));

    if (jelenlegi == null || kapacitas == null) {
      setState(() => _eredmeny = "Hiba: Hibás számok!");
      return;
    }

    int fazisokSzama = _fazis == "1 fázis" ? 1 : 3;
    int amperErtek = int.parse(_amper.replaceAll('A', ''));
    
    double bruttoKW = (230 * amperErtek * fazisokSzama) / 1000.0;
    double nettoKW = bruttoKW * 0.9;

    if (jelenlegi >= _celSzazalek) {
      setState(() {
        _teljesitmeny = "${nettoKW.toStringAsFixed(2)} kW";
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
      _teljesitmeny = "${nettoKW.toStringAsFixed(2)} kW";
      _eredmeny = "$h óra $m perc";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Eredmény Kártya
            Card(
              child: Container(
                padding: EdgeInsets.all(25),
                width: double.infinity,
                child: Column(
                  children: [
                    Text("BECSÜLT TÖLTÉSI IDŐ", style: TextStyle(color: Colors.grey, fontSize: 12, letterSpacing: 1.5)),
                    SizedBox(height: 10),
                    Text(_eredmeny, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                    Divider(height: 30, color: Colors.grey[800]),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bolt, color: Colors.amber, size: 20),
                        SizedBox(width: 5),
                        Text("Teljesítmény: $_teljesitmeny", style: TextStyle(color: Colors.grey[400])),
                      ],
                    )
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            
            // Beviteli mezők kártyája
            Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildInputLabel("Akku kapacitás (kWh)"),
                    TextField(controller: _kapacitasController, textAlign: TextAlign.center, decoration: _inputDecoration(), keyboardType: TextInputType.number),
                    SizedBox(height: 20),
                    _buildInputLabel("Jelenlegi töltöttség (%)"),
                    TextField(controller: _szazalekController, textAlign: TextAlign.center, decoration: _inputDecoration(), keyboardType: TextInputType.number),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(child: Column(children: [
                          _buildInputLabel("Fázis"),
                          DropdownButton<String>(
                            value: _fazis, isExpanded: true,
                            onChanged: (val) => setState(() => _fazis = val!),
                            items: ["1 fázis", "3 fázis"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                          )
                        ])),
                        SizedBox(width: 20),
                        Expanded(child: Column(children: [
                          _buildInputLabel("Áramerősség"),
                          DropdownButton<String>(
                            value: _amper, isExpanded: true,
                            onChanged: (val) => setState(() => _amper = val!),
                            items: ["8A", "10A", "13A", "16A", "32A"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                          )
                        ])),
                      ],
                    ),
                    SizedBox(height: 20),
                    _buildInputLabel("Cél: $_celSzazalek%"),
                    Slider(
                      value: _celSzazalek, min: 50, max: 100, divisions: 10,
                      label: "${_celSzazalek.round()}%",
                      onChanged: (v) => setState(() => _celSzazalek = v),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _szamoldKi,
              child: Text("SZÁMÍTÁS", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.0),
      child: Text(label, style: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.w500)),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.black26,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      contentPadding: EdgeInsets.symmetric(vertical: 10),
    );
  }
}
