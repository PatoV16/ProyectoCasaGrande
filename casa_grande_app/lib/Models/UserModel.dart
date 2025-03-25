// Modelo de Usuario para Flutter
class UserModel {
  final String? idEmpleado; // Nullable para permitir creación de nuevos usuarios sin ID
  final String correo;
  final String contrasena;
  final String nombre;
  final String apellido;
  final String cargo;
  
  // Constructor principal
  UserModel({
    this.idEmpleado,
    required this.correo, 
    required this.contrasena, 
    required this.nombre, 
    required this.apellido,
    required this.cargo,
  });
  
  // Constructor para crear desde JSON (para cuando lees de API/BD)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      idEmpleado: json['id_empleado'],
      correo: json['correo'],
      contrasena: json['contrasena'],
      nombre: json['nombre'],
      apellido: json['apellido'],
      cargo: json['cargo'],
    );
  }
  
  // Método para convertir a JSON (para cuando envías a API/BD)
  Map<String, dynamic> toJson() {
    return {
      'id_empleado': idEmpleado,
      'correo': correo,
      'contrasena': contrasena,
      'nombre': nombre,
      'apellido': apellido,
      'cargo': cargo,
    };
  }
  
  // Método para copiar y modificar propiedades
  UserModel copyWith({
    String? idEmpleado,
    String? correo,
    String? contrasena,
    String? nombre,
    String? apellido,
    String? cargo,
  }) {
    return UserModel(
      idEmpleado: idEmpleado ?? this.idEmpleado,
      correo: correo ?? this.correo,
      contrasena: contrasena ?? this.contrasena,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      cargo: cargo ?? this.cargo,
    );
  }
  
  // Para debugear y mostrar en la consola
  @override
  String toString() {
    return 'UserModel(idEmpleado: $idEmpleado, correo: $correo, nombre: $nombre, apellido: $apellido, cargo: $cargo)';
  }
  
  // Para comparar objetos
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel &&
        other.idEmpleado == idEmpleado &&
        other.correo == correo &&
        other.contrasena == contrasena &&
        other.nombre == nombre &&
        other.apellido == apellido &&
        other.cargo == cargo;
  }
  
  @override
  int get hashCode {
    return idEmpleado.hashCode ^
      correo.hashCode ^
      contrasena.hashCode ^
      nombre.hashCode ^
      apellido.hashCode ^
      cargo.hashCode;
  }
}