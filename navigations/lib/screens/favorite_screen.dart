import 'package:flutter/material.dart';

import '../models/meal.dart';
import '../widgets/meal_item.dart';

class FavoritessScreen extends StatelessWidget {
  final List<Meal> favoriteMeals;

  FavoritessScreen(this.favoriteMeals);

  @override
  Widget build(BuildContext context) {
    if (favoriteMeals.isEmpty) {
      return Center(
        child: Text('You Have No Favorites Yet - Start Adding Some!'),
      );
    } else {
      return ListView.builder(
        itemBuilder: (ctx, index) {
          return MealItem(
            mID: favoriteMeals[index].id,
            mTitle: favoriteMeals[index].title,
            mImageURL: favoriteMeals[index].imageUrl,
            mDuration: favoriteMeals[index].duration,
            complexity: favoriteMeals[index].complexity,
            affordability: favoriteMeals[index].affordability,
          );
        },
        itemCount: favoriteMeals.length,
      );
    }
  }
}
