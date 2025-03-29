import 'package:flutter/material.dart';

class Destination {
  const Destination({required this.label,required this.icon});

  final String label;
  final IconData icon;
}

const destinations = [
  Destination(label: "Início", icon: Icons.home),
  Destination(label: "Explorar", icon: Icons.explore),
  //Destination(label: "Offline", icon: Icons.download),
  Destination(label: "Favoritos", icon: Icons.favorite),
  //Destination(label: "Perfil", icon: Icons.person),
];