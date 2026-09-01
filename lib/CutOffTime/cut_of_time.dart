import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yogayog/constants/app_colors.dart';
import 'package:yogayog/CutOffTime/provider/cut_of_time_provider.dart';
import 'package:yogayog/core/services/cut_of_time_service.dart';
import 'package:provider/provider.dart';

class CutOfTime extends StatefulWidget {
  const CutOfTime({super.key});

  @override
  State<CutOfTime> createState() => _CutOfTimeState();
}

class _CutOfTimeState extends State<CutOfTime> {
  static const _green = AppColors.primaryMain;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<CutOffTimeProvider>().loadCutOffTimes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CutOffTimeProvider>();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: _green,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F4F8),
        body: Column(
          children: [
            const _CutOffHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(11, 8, 11, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CutOffCard(
                      cutOffTime: provider.cutOffTimes.isEmpty
                          ? null
                          : provider.cutOffTimes.first,
                      isLoading: provider.isLoading,
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'What happens after cut-off?',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (provider.isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (provider.errorMessage != null)
                      Text(
                        provider.errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      )
                    else
                      ...provider.cutOffTimes.map(
                        (cutOff) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _ImpactCard(
                            icon: _serviceIcon(cutOff.service),
                            title: cutOff.service,
                            description:
                                'Same-day acceptance until ${cutOff.cutoffTimeDisplay}',
                          ),
                        ),
                      ),
                    const SizedBox(height: 13),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6F5EE),
                        border: Border.all(color: const Color(0xFFB5DCC7)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        '💡 Always inform the customer of the cut-off\nbefore accepting their shipment at the counter.',
                        style: TextStyle(
                          color: _green,
                          fontSize: 13,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _serviceIcon(String service) {
    final value = service.toLowerCase();
    if (value.contains('bike')) return Icons.two_wheeler;
    if (value.contains('truck')) return Icons.local_shipping;
    if (value.contains('international')) return Icons.flight_takeoff;
    return Icons.local_shipping_outlined;
  }
}

class _CutOffHeader extends StatelessWidget {
  const _CutOffHeader();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // Include enough room for the system status-bar inset and header text
      // at the device's current text scale.
      height: 134,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Container(color: _CutOfTimeState._green),
          Positioned(
            right: -18,
            top: -58,
            child: Container(
              width: 132,
              height: 132,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.hintGray, width: 15),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 7, 12, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      InkWell(
                        onTap: () => Navigator.of(context).maybePop(),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          width: 36,
                          height: 36,
                          // decoration: BoxDecoration(
                          //   color: Colors.white.withValues(alpha: .15),
                          //   borderRadius: BorderRadius.circular(10),
                          // ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Cut-Off Time',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),

                  const Text(
                    'Last acceptance time for same-day pickup',
                    style: TextStyle(color: Color(0xFFB8DDC8), fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CutOffCard extends StatelessWidget {
  const _CutOffCard({this.cutOffTime, required this.isLoading});

  final CutOffTimeData? cutOffTime;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 221,
      decoration: BoxDecoration(
        color: const Color(0xFF211000),
        borderRadius: BorderRadius.circular(19),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "TODAY'S CUT-OFF",
            style: TextStyle(
              color: Color(0xFFFFC400),
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: .5,
            ),
          ),
          SizedBox(height: 7),
          Text(
            isLoading ? '...' : (cutOffTime?.cutoffTimeDisplay ?? '--'),
            style: TextStyle(
              color: Color(0xFFFFC400),
              fontSize: 52,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 8),
          DecoratedBox(
            decoration: BoxDecoration(
              color: Color(0xFF51160C),
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                '◷  Service-wise time below',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          SizedBox(height: 15),
          Text(
            'Live service-wise cut-off times are shown below',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFB18B00),
              fontSize: 13,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _ImpactCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _ImpactCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 77,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F5),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(icon, size: 26, color: Colors.black),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF667085),
                    height: 1.25,
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
