import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:beautifood_lite/providers/shop.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FoodTitleWidget extends StatelessWidget {
  final MenuItem fooddata;
  const FoodTitleWidget(this.fooddata, this.onSelectMenuItem, {Key? key})
      : super(key: key);
  final Function(String) onSelectMenuItem;
  @override
  Widget build(BuildContext context) {
    gotoFoodDetails() {
      onSelectMenuItem(fooddata.id);
      // Navigator.push(context, MaterialPageRoute(builder: (context)=>FoodDetailPage(fooddata)));
    }

    bool isAvailable = true;
    if (!fooddata.inStock) {
      isAvailable = false;
    }
    final currentDayAvailableTimeIndex = fooddata.availableTimes
        .indexWhere((element) => element.day == (DateTime.now().weekday % 7));
    final now = DateTime.now();
    final currentTimeInSeconds = now.hour * 60 + now.second;
    if (currentDayAvailableTimeIndex < 0) {
      isAvailable = false;
    } else if (fooddata.availableTimes[currentDayAvailableTimeIndex].start >
            currentTimeInSeconds ||
        fooddata.availableTimes[currentDayAvailableTimeIndex].end <
            currentTimeInSeconds) {
      isAvailable = false;
    }

    return Stack(
      children: [
        InkWell(
          onTap: () => isAvailable ? gotoFoodDetails() : null,
          child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  if (fooddata.imageUrls.isNotEmpty)
                    SizedBox(
                      height: 120.0,
                      width: 120.0,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Hero(
                            tag: "avatar_${fooddata.id}",
                            child: fooddata.imageUrls.isEmpty
                                ? const Icon(Icons.local_restaurant_rounded)
                                : Image.network(
                                    fooddata.imageUrls[0],
                                    fit: BoxFit.cover,
                                  )),
                      ),
                    ),
                  const SizedBox(
                    width: 10.0,
                  ),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: AutoSizeText(
                            fooddata.title,
                            maxLines: 2,
                            style: const TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            fooddata.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Row(
                        //   children: [
                        //     const SizedBox(
                        //       height: 10.0,
                        //     ),
                        //     const Icon(
                        //       Icons.star,
                        //       color: Colors.orangeAccent,
                        //     ),
                        //     Text(
                        //       doubleInRange(random, 3.5, 5.0).toStringAsFixed(1),
                        //       style: const TextStyle(
                        //           fontWeight: FontWeight.bold,
                        //           color: Colors.orangeAccent),
                        //     ),
                        //     const SizedBox(
                        //       width: 5.0,
                        //     ),
                        //     const Text(
                        //       "Cafe Western Food",
                        //       overflow: TextOverflow.ellipsis,
                        //       style: TextStyle(color: Colors.black45),
                        //     ),
                        //   ],
                        // ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            "${Provider.of<Shop>(context).shopData!.currency.symbol} ${fooddata.price.toStringAsFixed(2)}",
                            style: const TextStyle(
                                fontSize: 17.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              )),
        ),
        if (!isAvailable)
          Positioned.fill(
            child: Container(
              color: Colors.grey.shade300.withOpacity(0.75),
              child: const Center(
                child: Text(
                  'Not Available',
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
      ],
    );
  }

  //we are generating random rating for now
  double doubleInRange(Random source, num start, num end) =>
      source.nextDouble() * (end - start) + start;
}
