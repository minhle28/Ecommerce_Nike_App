import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app_project/pages/itemPage.dart';
import 'package:mobile_app_project/product/bloc/product_bloc.dart';
import '../product/DUMMY_MODELS.dart';

// Bottom Favorite Sheet

class BottomFavoriteSheet extends StatefulWidget {
  @override
  _BottomFavoriteSheetState createState() => _BottomFavoriteSheetState();
}

class _BottomFavoriteSheetState extends State<BottomFavoriteSheet> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        if (state is ProductLoading) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (state is ProductLoaded) {
          List<Product> favList = state.products
              .where((products) => products.favorite
                  .contains(FirebaseAuth.instance.currentUser!.uid))
              .toList();
          return SingleChildScrollView(
            child: Column(
              children: favList.map((product) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  color: Colors.blue[100],
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FavoriteCard(product: product),
                    ],
                  ),
                );
              }).toList(),
            ),
          );
        } else {
          return Text('Something went wrong.');
        }
      },
    );
  }
}

class FavoriteCard extends StatelessWidget {
  FavoriteCard({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    Future<void> removeFav({required Product product}) async {
      final User? user = FirebaseAuth.instance.currentUser;
      if (product.favorite.contains(user!.uid)) {
        await FirebaseFirestore.instance
            .collection('products')
            .doc(product.id)
            .update({
          "favorite": FieldValue.arrayRemove([user?.uid])
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            duration: Duration(seconds: 1),
            content: Text("Product removed from favorites")));
      } else {}
    }

    return Material(
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            height: 140,
            // decoration: BoxDecoration(
            //   color: Colors.white,
            //   borderRadius: BorderRadius.circular(10),
            //   boxShadow: [
            //     BoxShadow(
            //       color: const Color(0xFF475269).withOpacity(0.3),
            //       blurRadius: 5,
            //       spreadRadius: 1,
            //     ),
            //   ],
            // ),
            child: Row(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ItemPage(product: product)));
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 0, right: 30),
                        height: 90,
                        width: 110,
                        decoration: BoxDecoration(
                         
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      Positioned(
                        left: 5,
                        child: Image.asset(
                          product.img,
                          height: 100,
                          width: 100,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        product.name,
                        style: TextStyle(
                          color: Color(0xFF475269),
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        children: [
                        
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              "\$${product.price}",
                              style: TextStyle(
                                color: Color(0xFF475269),
                                fontWeight: FontWeight.w500,
                                fontSize: 20,
                              ),
                            ),
                          ),
                          
                        ],
                      )
                    ],
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 50),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.purple.withOpacity(0.4),
                              blurRadius: 5,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: SizedBox(
                          width: 40, // Adjust width as needed
                          height: 40, // Adjust height as needed
                          child: IconButton(
                            icon: Icon(Icons.favorite),
                            color: Colors.red,
                            iconSize: 20, // Adjust icon size as needed
                            onPressed: () {
                              removeFav(product: product);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
