import 'package:flutter/material.dart';

import '../screens/categories_meals_screen.dart';

class CategoryItem extends StatelessWidget {
  final String mID;
  final String mTitle;
  final Color mColor;

  CategoryItem(this.mID, this.mTitle, this.mColor);

  void selectCategory(BuildContext ctx) {
    Navigator.of(ctx).pushNamed(
      CategoriesMealsScreen.routeName,
      arguments: {
        'id': mID,
        'title': mTitle,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => selectCategory(context),
      splashColor: Theme.of(context).primaryColor,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(15),
        child: Text(
          mTitle,
          style: Theme.of(context).textTheme.headline6,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [mColor.withOpacity(0.7), mColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }
}
