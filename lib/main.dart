import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() => runApp(EVKalkulatorApp());

class EVKalkulatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Color(0xFF0F172A),
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
  String _eredmeny = "0 óra 0 perc";
  String _befejezesIdo = "--:--";
  String _energiaMennyiseg = "0.00 kWh";
  String _co2Megtakaritas = "0.00 kg"; // Új változó
  Color _accentColor = Colors.greenAccent;

  void _szamoldKi() {
    double? jelenlegi = double.tryParse(_szazalekController.text.replaceFirst(',', '.'));
    double? kapacitas = double.tryParse(_kapacitasController.text.replaceFirst(',', '.'));

    if (jelenlegi == null || kapacitas == null) return;

    int fazisokSzama = _fazis == "1 fázis" ? 1 : 3;
    int amperErtek = int.parse(_amper.replaceAll('A', ''));
    
    double bruttoKW = (230 * amperErtek * fazisokSzama) / 1000.0;
    double nettoKW = bruttoKW * 0.9;

    setState(() {
      if (_celSzazalek <= 80) _accentColor = Colors.greenAccent;
      else if (_celSzazalek <= 95) _accentColor = Colors.blueAccent;
      else _accentColor = Colors.amberAccent;
    });

    if (jelenlegi >= _celSzazalek) {
      setState(() {
        _eredmeny = "KÉSZ";
        _befejezesIdo = "Most";
        _energiaMennyiseg = "0.00 kWh";
        _co2Megtakaritas = "0.00 kg";
      });
      return;
    }

    double hianyzoKwh = ((_celSzazalek - jelenlegi) / 100.0) * kapacitas;
    double idoOra = hianyzoKwh / nettoKW;
    
    // CO2 számítás: ~0.18 kg megtakarítás / betöltött kWh
    double co2kg = hianyzoKwh * 0.18;

    DateTime befejezes = DateTime.now().add(Duration(minutes: (idoOra * 60).round()));

    setState(() {
      int h = idoOra.toInt();
      int m = ((idoOra - h) * 60).round();
      _eredmeny = "$h óra $m perc";
      _befejezesIdo = DateFormat('HH:mm').format(befejezes);
      _energiaMennyiseg = "${hianyzoKwh.toStringAsFixed(2)} kWh";
      _co2Megtakaritas = "${co2kg.toStringAsFixed(2)} kg";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 50),
          child: Column(
            children: [
              // Fő Eredmény Kártya
              _buildGlassCard(
                child: Column(
                  children: [
                    Text("TÖLTÉSI IDŐTARTAM", style: TextStyle(color: Colors.white60, fontSize: 12, letterSpacing: 2)),
                    SizedBox(height: 15),
                    Text(_eredmeny, style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: _accentColor, shadows: [Shadow(color: _accentColor.withOpacity(0.5), blurRadius: 20)])),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.access_time, size: 18, color: Colors.white60),
                        SizedBox(width: 8),
                        Text("Vége: ", style: TextStyle(color: Colors.white60)),
                        Text(_befejezesIdo, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                      ],
                    ),
                    Divider(height: 40, color: Colors.white10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _infoTile("Energia", _energiaMennyiseg, Icons.ev_station),
                        _infoTile("Cél", "${_celSzazalek.round()}%", Icons.flag),
                      ],
                    )
                  ],
                ),
              ),
              
              SizedBox(height: 15),

              // ÚJ: Környezetvédelmi kártya
              _buildGlassCard(
                color: Colors.green.withOpacity(0.1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.eco, color: Colors.greenAccent, size: 24),
                    SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("CO₂ MEGTAKARÍTÁS", style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                        Text(_co2Megtakaritas, style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 25),
              _buildSectionTitle("AKKU ADATOK"),
              _buildInputCard([
                _buildTextField("Kapacitás (kWh)", _kapacitasController),
                SizedBox(height: 15),
                _buildTextField("Jelenlegi szint (%)", _szazalekController),
              ]),
              
              SizedBox(height: 25),
              _buildSectionTitle("TÖLTŐ BEÁLLÍTÁSA"),
              _buildInputCard([
                Row(
                  children: [
                    Expanded(child: _buildDropdown("Fázis", _fazis, ["1 fázis", "3 fázis"], (v) => setState(() => _fazis = v!))),
                    SizedBox(width: 15),
                    Expanded(child: _buildDropdown("Amper", _amper, ["8A", "10A", "13A", "16A", "32A"], (v) => setState(() => _amper = v!))),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Cél töltöttség", style: TextStyle(color: Colors.white60, fontSize: 13)),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      decoration: BoxDecoration(color: _accentColor.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                      child: Text("${_celSzazalek.round()}%", style: TextStyle(color: _accentColor, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                Slider(
                  value: _celSzazalek, min: 50, max: 100, divisions: 10,
                  activeColor: _accentColor,
                  onChanged: (v) => setState(() => _celSzazalek = v),
                ),
              ]),
              
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: _szamoldKi,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accentColor,
                  foregroundColor: Colors.black87,
                  minimumSize: Size(double.infinity, 65),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 10,
                ),
                child: Text("SZÁMÍTÁS INDÍTÁSA", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Segédmetódus az üveghatású kártyákhoz
  Widget _buildGlassCard({required Widget child, Color? color}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color ?? Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: child,
    );
  }

  Widget _infoTile(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white38, size: 20),
        SizedBox(height: 5),
        Text(label, style: TextStyle(color: Colors.white38, fontSize: 11)),
        Text(value, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(left: 10, bottom: 10),
        child: Text(title, style: TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildInputCard(List<Widget> children) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white38),
        filled: true,
        fillColor: Colors.black26,
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white10)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _accentColor)),
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white38, fontSize: 12)),
        DropdownButton<String>(
          value: value, isExpanded: true, underline: SizedBox(),
          onChanged: onChanged,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        ),
      ],
    );
  }
}
