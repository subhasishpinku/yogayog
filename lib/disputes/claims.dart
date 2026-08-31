import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yogayog/constants/app_colors.dart';
import 'package:yogayog/dashboard/dashboard_scren.dart';
import 'package:yogayog/disputes/provider/disputes_provider.dart';

class Claims extends StatefulWidget {
  const Claims({
    super.key,
    this.orderNo = 'YCG-2025-00921',
    this.orderId = '',
    this.issue = 'Package issue',
    this.description = '',
    this.amount = 149,
  });

  final String orderNo;
  final String orderId;
  final String issue;
  final String description;
  final double amount;

  @override
  State<Claims> createState() => _ClaimsState();
}

class _ClaimsState extends State<Claims> {
  static const _blue = AppColors.primaryMain;
  static const _background = Color(0xFFF5F6FA);

  final List<XFile> _photos = [];
  XFile? _video;
  final ImagePicker _picker = ImagePicker();
  final _provider = DisputesProvider();

  Future<void> _addPhoto() async {
    try {
      final photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo == null || !mounted) return;
      setState(() {
        if (_photos.length < 5) _photos.add(photo);
      });
    } catch (_) {
      if (mounted) _showPickerError('Unable to open the camera');
    }
  }

  Future<void> _addVideo() async {
    try {
      final video = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(seconds: 30),
      );
      if (video == null || !mounted) return;
      const maxVideoBytes = 20 * 1024 * 1024;
      final videoSize = await video.length();
      if (videoSize > maxVideoBytes) {
        _showPickerError('Video must be smaller than 20 MB');
        return;
      }
      setState(() {
        _video = video;
      });
    } catch (_) {
      if (mounted) _showPickerError('Unable to open the video camera');
    }
  }

  void _showPickerError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _blue,
        foregroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 86,
        leading: IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Review your claim',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 3),
            Text(
              '${widget.orderNo} · ${widget.issue}',
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 17, 14, 22),
        children: [
          const Text(
            'Add evidence',
            style: TextStyle(
              color: Color(0xFF667085),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          _evidenceCard(
            icon: Icons.photo_camera_outlined,
            title: 'Photos of the package',
            subtitle: _photos.isEmpty
                ? 'Up to 5 JPG, PNG or HEIC files'
                : '${_photos.length} photo${_photos.length == 1 ? '' : 's'} added',
            onAdd: _addPhoto,
          ),
          const SizedBox(height: 9),
          _evidenceCard(
            icon: Icons.videocam_outlined,
            title: 'Video (optional)',
            subtitle: _video != null
                ? '1 video added'
                : 'Show damage clearly, up to 30 seconds',
            onAdd: _addVideo,
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.fromLTRB(13, 13, 13, 11),
            decoration: BoxDecoration(
              color: const Color(0xFFE9ECFF),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Refund preference',
                  style: TextStyle(
                    color: _blue,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Once approved, ₹${widget.amount.toStringAsFixed(0)} will be returned to the\noriginal payment method in 5–7 business days.',
                  style: TextStyle(color: _blue, fontSize: 12, height: 1.45),
                ),
              ],
            ),
          ),
          const SizedBox(height: 17),
          const Text(
            'Claim summary',
            style: TextStyle(
              color: Color(0xFF667085),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 7),
          _summaryCard(),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(14, 11, 14, 10),
        child: ElevatedButton(
          onPressed: _submitClaim,
          style: ElevatedButton.styleFrom(
            backgroundColor: _blue,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(48),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Submit claim',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ),
    );
  }

  Future<void> _submitClaim() async {
    final id = int.tryParse(
      widget.orderId.isEmpty ? widget.orderNo : widget.orderId,
    );
    if (id == null) {
      _showPickerError('Order ID is unavailable');
      return;
    }
    if (_photos.isEmpty) {
      _showPickerError('Please add at least one package photo');
      return;
    }
    if (_video != null && await _video!.length() > 20 * 1024 * 1024) {
      _showPickerError('Video must be smaller than 20 MB');
      return;
    }
    final submitted = await _provider.submitIssue(
      orderId: id,
      issue: widget.issue,
      description: widget.description.isEmpty
          ? 'Claim submitted from the app'
          : widget.description,
      photos: _photos,
      video: _video,
    );
    if (!mounted) return;
    if (!submitted) {
      _showPickerError(_provider.errorMessage ?? 'Unable to submit claim');
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Claim submitted successfully')),
    );
    Navigator.push(context, MaterialPageRoute(builder: (_) => Dashboard()));
  }

  Widget _evidenceCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onAdd,
  }) {
    return Container(
      height: 66,
      padding: const EdgeInsets.symmetric(horizontal: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE1E4EC)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.black87, size: 22),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF667085),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onAdd,
            style: TextButton.styleFrom(
              foregroundColor: _blue,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Add',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 9,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(13, 15, 15, 13),
            child: Row(
              children: [
                Text(
                  'Claimed amount',
                  style: TextStyle(color: Color(0xFF667085), fontSize: 12),
                ),
                Spacer(),
                Text(
                  '₹${widget.amount.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: _blue,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Color(0xFFE9ECF2)),
          Padding(
            padding: EdgeInsets.fromLTRB(13, 13, 15, 15),
            child: Row(
              children: [
                Text(
                  'Resolution target',
                  style: TextStyle(color: Color(0xFF667085), fontSize: 12),
                ),
                Spacer(),
                Text(
                  'Within 48 hours',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
