import 'package:flutter/cupertino.dart';

class DiasAsistenciaCheckbox extends StatefulWidget {
  final List<bool> diasAsistencia;
  final ValueChanged<List<bool>> onChanged;
  
  const DiasAsistenciaCheckbox({
    Key? key,
    required this.diasAsistencia,
    required this.onChanged,
  }) : super(key: key);

  @override
  _DiasAsistenciaCheckboxState createState() => _DiasAsistenciaCheckboxState();
}

class _DiasAsistenciaCheckboxState extends State<DiasAsistenciaCheckbox> {
  late List<bool> _diasSeleccionados;
  
  final List<String> _nombresDias = [
    'Día 1', 'Día 2', 'Día 3', 'Día 4', 'Día 5', 'Día 6', 'Día 7'
  ];

  @override
  void initState() {
    super.initState();
    _diasSeleccionados = List.from(widget.diasAsistencia);
  }

  void _actualizarSeleccion(int index, bool value) {
    setState(() {
      _diasSeleccionados[index] = value;
    });
    widget.onChanged(_diasSeleccionados);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 0, bottom: 8.0, top: 8.0),
          child: Text(
            'Asistencia:',
            style: TextStyle(
              fontSize: 14,
              color: CupertinoColors.systemGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: CupertinoColors.systemBackground,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: List.generate(7, (index) {
              return Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: index < 6 ? BorderSide(
                      color: CupertinoColors.systemGrey6,
                      width: 0.5,
                    ) : BorderSide.none,
                  ),
                ),
                child: CupertinoListTile(
                  backgroundColor: CupertinoColors.systemBackground,
                  title: Text(
                    _nombresDias[index],
                    style: TextStyle(
                      fontSize: 15,
                      color: CupertinoColors.label,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  trailing: CupertinoSwitch(
                    value: _diasSeleccionados[index],
                    activeColor: CupertinoColors.activeBlue,
                    onChanged: (value) => _actualizarSeleccion(index, value),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}