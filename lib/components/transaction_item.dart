import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import '../config/currency_provider.dart';

class TransactionItem extends StatefulWidget {
  final double amount;
  final String type;
  final String date;
  final String tag;
  final String note;
  final Function(BuildContext)? deleteFunction;
  final Function(BuildContext)? editFunction;

  const TransactionItem({
    super.key,
    required this.amount,
    required this.date,
    required this.tag,
    required this.type,
    required this.note,
    required this.deleteFunction,
    required this.editFunction,
  });

  @override
  State<TransactionItem> createState() => _TransactionItemState();
}

class _TransactionItemState extends State<TransactionItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final currencyProvider = Provider.of<CurrencyProvider>(context);
    final currencySymbol = currencyProvider.currencySymbol;

    return Padding(
      padding: const EdgeInsets.only(right: 20.0, left: 20.0, top: 10.0),
      child: Slidable(
        startActionPane: ActionPane(motion: StretchMotion(), children: [
          SlidableAction(
            onPressed: widget.editFunction,
            icon: Icons.edit,
            backgroundColor: Colors.yellow.shade300,
          ),
        ]),
        endActionPane: ActionPane(motion: StretchMotion(), children: [
          SlidableAction(
            onPressed: widget.deleteFunction,
            icon: Icons.delete,
            backgroundColor: Colors.red.shade300,
          )
        ]),
        child: GestureDetector(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: EdgeInsets.all(15.0),
            decoration: BoxDecoration(
              color: widget.type == "expense" ? Colors.red : Colors.green,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "$currencySymbol ${widget.amount.toStringAsFixed(2)}",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.date,
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  widget.tag,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10),
                AnimatedCrossFade(
                  firstChild: Text(
                    widget.note,
                    style: const TextStyle(color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  secondChild: Text(
                    widget.note,
                    style: const TextStyle(color: Colors.white),
                  ),
                  crossFadeState: _isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 300),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
