import 'package:flutter/material.dart';
import 'package:frontend/core/constants/utils.dart';
import 'package:intl/intl.dart';

class DateSelector extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime date) onTap;

  const DateSelector(
      {super.key, required this.selectedDate, required this.onTap});

  @override
  State<DateSelector> createState() => _DateSelectorState();
}

class _DateSelectorState extends State<DateSelector> {
  int weekOffset = 0;

  @override
  Widget build(BuildContext context) {
    final weekDates = generateWeekDates(weekOffset);
    String monthName = DateFormat("MMMM").format(weekDates.first);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
                onPressed: () {
                  setState(() {
                    weekOffset--;
                  });
                },
                icon: Icon(Icons.chevron_left),
                iconSize: 40.0),
            Text(
              monthName,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            IconButton(
                onPressed: () {
                  setState(() {
                    weekOffset++;
                  });
                },
                icon: Icon(Icons.chevron_right),
                iconSize: 40.0),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: SizedBox(
              height: 70,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: weekDates.length,
                itemBuilder: (context, index) {
                  final weekDate = weekDates[index];
                  bool isSelected = DateFormat('d').format(weekDate) ==
                          DateFormat('d').format(widget.selectedDate) &&
                      widget.selectedDate.month == weekDate.month &&
                      widget.selectedDate.year == weekDate.year;
                  return GestureDetector(
                    onTap: () {
                      widget.onTap(weekDate);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: isSelected ? Colors.deepOrangeAccent : null,
                          border: isSelected
                              ? Border.all(
                                  color: Colors.deepOrangeAccent,
                                )
                              : Border.all(
                                  color: Colors.grey.shade400, width: 2),
                          borderRadius: BorderRadius.circular(10)),
                      width: 70,
                      margin: EdgeInsets.only(right: 15),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            DateFormat('d').format(weekDate),
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : null),
                          ),
                          Text(
                            DateFormat('E').format(weekDate),
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : null),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        )
      ],
    );
  }
}
