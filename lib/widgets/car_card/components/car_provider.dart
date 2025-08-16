import 'package:flutter/material.dart';
import '../../../models/car.dart';
import '../services/car_provider_service.dart';

class CarProviderWidget extends StatefulWidget {
  final Car car;

  const CarProviderWidget({super.key, required this.car});

  @override
  State<CarProviderWidget> createState() => _CarProviderWidgetState();
}

class _CarProviderWidgetState extends State<CarProviderWidget> {
  String? providerName;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchProviderName();
  }

  Future<void> _fetchProviderName() async {
    setState(() {
      isLoading = true;
    });

    final name = await CarProviderService.fetchProviderName(widget.car);

    if (mounted) {
      setState(() {
        providerName = name;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.person_outline,
          size: 12,
          color: Theme.of(context).primaryColor,
        ),
        const SizedBox(width: 4),
        Flexible(
          child: isLoading
              ? Container(
                  height: 8,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                )
              : Text(
                  providerName ?? 'Loading...',
                  style: const TextStyle(fontSize: 9, color: Color(0xFF888888)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
        ),
      ],
    );
  }
}
