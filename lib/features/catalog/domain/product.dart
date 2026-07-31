import 'package:flutter/material.dart';

class Product {
  const Product({
    required this.id,
    required this.slug,
    required this.name,
    required this.category,
    required this.price,
    required this.description,
    required this.imageAlignment,
    this.has3dAsset = true,
    this.isNew = false,
  });

  final String id;
  final String slug;
  final String name;
  final String category;
  final int price;
  final String description;
  final Alignment imageAlignment;
  final bool has3dAsset;
  final bool isNew;

  String get formattedPrice =>
      '₦${price.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
}

const sampleProducts = <Product>[
  Product(
    id: 'p1',
    slug: 'ara-drape-blouse',
    name: 'Ara Drape Blouse',
    category: 'Tops',
    price: 85000,
    description:
        'A fluid satin blouse shaped with asymmetric folds and a softly structured shoulder.',
    imageAlignment: Alignment.topLeft,
    isNew: true,
  ),
  Product(
    id: 'p2',
    slug: 'nuru-architectural-blazer',
    name: 'Nuru Architectural Blazer',
    category: 'Outerwear',
    price: 148000,
    description:
        'Precision tailoring with a sculpted shoulder, clean lapel and relaxed unisex proportion.',
    imageAlignment: Alignment.topRight,
    isNew: true,
  ),
  Product(
    id: 'p3',
    slug: 'ede-wide-leg-trouser',
    name: 'Ede Wide-Leg Trouser',
    category: 'Bottoms',
    price: 92000,
    description:
        'Long-line ivory tailoring with deep pleats and an effortless high-rise silhouette.',
    imageAlignment: Alignment.bottomLeft,
  ),
  Product(
    id: 'p4',
    slug: 'tola-gathered-dress',
    name: 'Tola Gathered Dress',
    category: 'Dresses',
    price: 126000,
    description:
        'A soft charcoal midi dress, drawn into sculptural gathers at the waist.',
    imageAlignment: Alignment.bottomRight,
    isNew: true,
  ),
  Product(
    id: 'p5',
    slug: 'sol-knit-shell',
    name: 'Sol Knit Shell',
    category: 'Tops',
    price: 58000,
    description:
        'A close, finely ribbed base layer designed for light, elegant layering.',
    imageAlignment: Alignment.bottomLeft,
    has3dAsset: false,
  ),
  Product(
    id: 'p6',
    slug: 'kora-evening-jacket',
    name: 'Kora Evening Jacket',
    category: 'Outerwear',
    price: 162000,
    description:
        'A clean evening jacket with satin detail and a deliberate oversized line.',
    imageAlignment: Alignment.topRight,
  ),
  Product(
    id: 'p7',
    slug: 'lumi-column-skirt',
    name: 'Lumi Column Skirt',
    category: 'Bottoms',
    price: 76000,
    description:
        'A minimal column skirt with a fluid back split and precise waistband.',
    imageAlignment: Alignment.bottomRight,
  ),
  Product(
    id: 'p8',
    slug: 'ama-silk-shirt',
    name: 'Ama Silk Shirt',
    category: 'Tops',
    price: 79000,
    description:
        'A relaxed silk shirt with dropped shoulders and a quietly luminous finish.',
    imageAlignment: Alignment.topLeft,
  ),
];
