import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const POSApp());
}

class POSApp extends StatelessWidget {
  const POSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Restaurant POS',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: const POSHomePage(),
    );
  }
}

class Product {
  final String name;
  final double price;

  Product({required this.name, required this.price});
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get total => product.price * quantity;
}

class POSHomePage extends StatefulWidget {
  const POSHomePage({super.key});

  @override
  State<POSHomePage> createState() => _POSHomePageState();
}

class _POSHomePageState extends State<POSHomePage> {
  final String shopName = "Gourmet Express";
  final String shopAddress = "123 Foodie Street, Culinary District, FL 56789";

  final List<Product> products = [
    Product(name: "Zinger Burger", price: 650),
    Product(name: "Chicken Pizza", price: 1200),
    Product(name: "Loaded Fries", price: 450),
    Product(name: "Cold Drink", price: 120),
    Product(name: "Club Sandwich", price: 550),
    Product(name: "Hot Wings", price: 350),
  ];

  final List<CartItem> cart = [];
  double discountPercentage = 10.0;
  double taxPercentage = 5.0;

  void addToCart(Product product) {
    setState(() {
      final existingIndex = cart.indexWhere((item) => item.product.name == product.name);
      if (existingIndex >= 0) {
        cart[existingIndex].quantity++;
      } else {
        cart.add(CartItem(product: product));
      }
    });
  }

  void removeFromCart(int index) {
    setState(() {
      if (cart[index].quantity > 1) {
        cart[index].quantity--;
      } else {
        cart.removeAt(index);
      }
    });
  }

  double get subtotal => cart.fold(0, (sum, item) => sum + item.total);
  double get discountAmount => subtotal * (discountPercentage / 100);
  double get taxAmount => (subtotal - discountAmount) * (taxPercentage / 100);
  double get total => subtotal - discountAmount + taxAmount;

  @override
  Widget build(BuildContext context) {
    final String currentDate = DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: Text(shopName, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.deepOrange,
      ),
      body: Row(
        children: [
          // Left Side: Product Selection
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Products Catalog', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 0.85,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return Card(
                          elevation: 3,
                          child: InkWell(
                            onTap: () => addToCart(product),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.fastfood, size: 48, color: Colors.deepOrange),
                                  const SizedBox(height: 12),
                                  Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                                  const SizedBox(height: 4),
                                  Text("Rs. ${product.price}", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Right Side: Billing Details
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.grey.shade50,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        Text(shopName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                        Text(shopAddress, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                        const SizedBox(height: 8),
                        Text("Date: $currentDate", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  const Divider(height: 32),
                  const Text('Invoice Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Expanded(
                    child: cart.isEmpty
                        ? const Center(child: Text("No items in cart", style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)))
                        : ListView.separated(
                            itemCount: cart.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final item = cart[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                                          Text("${item.quantity} x Rs. ${item.product.price}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                        ],
                                      ),
                                    ),
                                    Text("Rs. ${item.total.toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.bold)),
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 20),
                                      onPressed: () => removeFromCart(index),
                                    )
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                  const Divider(thickness: 2),
                  _buildSummaryRow("Subtotal", subtotal),
                  _buildSummaryRow("Discount ($discountPercentage%)", -discountAmount, color: Colors.red),
                  _buildSummaryRow("Sales Tax ($taxPercentage%)", taxAmount),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.deepOrange.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("GRAND TOTAL", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        Text("Rs. ${total.toStringAsFixed(0)}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: cart.isEmpty ? null : () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Success"),
                            content: const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle, color: Colors.green, size: 64),
                                SizedBox(height: 16),
                                Text("Payment Received!"),
                                Text("Thank You for Shopping!", style: TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  setState(() => cart.clear());
                                  Navigator.pop(context);
                                },
                                child: const Text("Done"),
                              )
                            ],
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text("PROCESS PAYMENT", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Center(child: Text("Thank You!", style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text("${value < 0 ? '-' : ''}Rs. ${value.abs().toStringAsFixed(0)}",
               style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
