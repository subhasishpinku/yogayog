import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yogayog/constants/app_colors.dart';
import 'package:yogayog/core/services/home_service.dart';
import 'package:yogayog/paperworkrequired/provider/paperwork_required_provider.dart';

class PaperworkRequired extends StatefulWidget {
  const PaperworkRequired({super.key});

  @override
  State<PaperworkRequired> createState() => _PaperworkRequiredState();
}

class _PaperworkRequiredState extends State<PaperworkRequired> {
  static const _green = AppColors.primaryMain;
  String _accountType = 'Individual';
  final _panController = TextEditingController();
  final _aadharController = TextEditingController();
  final _voterController = TextEditingController();
  XFile? _panImage;

  bool get _isBusiness => _accountType.trim().toLowerCase() == 'business';

  String _documentType(String title) {
    switch (title) {
      case 'Business PAN':
      case 'PAN':
        return 'pan';
      case 'Aadhaar':
        return 'aadhar';
      case 'Voter ID':
        return 'voter';
      case 'GST':
        return 'gst';
      case 'IEC Code':
        return 'iec';
      case 'MSME Certificate':
        return 'msme';
      default:
        return title.toLowerCase().replaceAll(' ', '_');
    }
  }

  String? _documentNumber(String title) {
    final type = _documentType(title);
    final documents = context.watch<PaperworkRequiredProvider>().documents;
    for (final document in documents) {
      if (document.type == type &&
          document.number != null &&
          document.number!.trim().isNotEmpty) {
        return document.number;
      }
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _loadAccountType();
    context.read<PaperworkRequiredProvider>().loadDocuments();
  }

  @override
  void dispose() {
    _panController.dispose();
    _aadharController.dispose();
    _voterController.dispose();
    super.dispose();
  }

  Future<void> _showPanUploadDialog() async {
    var isSubmitting = false;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Upload PAN Card'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _panController,
                  textCapitalization: TextCapitalization.characters,
                  maxLength: 10,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                    UpperCaseTextFormatter(),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'PAN Number',
                    hintText: 'ABCDE1234F',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                if (_panImage != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      File(_panImage!.path),
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  Container(
                    height: 120,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F4F8),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFD8D8E0)),
                    ),
                    child: const Text('No PAN image selected'),
                  ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () async {
                    final image = await ImagePicker().pickImage(
                      source: ImageSource.camera,
                      imageQuality: 85,
                    );
                    if (image != null) {
                      setDialogState(() => _panImage = image);
                    }
                  },
                  icon: const Icon(Icons.upload_file),
                  label: Text(
                    _panImage == null ? 'Take PAN Photo' : 'Retake PAN Photo',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      final pan = _panController.text.trim().toUpperCase();
                      if (!RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$').hasMatch(pan)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Enter a valid PAN number'),
                          ),
                        );
                        return;
                      }
                      if (_panImage == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please select PAN image'),
                          ),
                        );
                        return;
                      }
                      setDialogState(() => isSubmitting = true);
                      final success = await context
                          .read<PaperworkRequiredProvider>()
                          .verifyAndUploadPan(pan: pan, image: _panImage!);
                      if (!mounted) return;
                      if (!success) {
                        setDialogState(() => isSubmitting = false);
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          SnackBar(
                            content: Text(
                              this.context
                                      .read<PaperworkRequiredProvider>()
                                      .errorMessage ??
                                  'Unable to verify or upload PAN',
                            ),
                          ),
                        );
                        return;
                      }
                      Navigator.pop(dialogContext);
                      this.setState(() {});
                    },
              child: isSubmitting
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Verify & Upload'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadOptionalDocument(_Document document) async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (image == null || !mounted) return;
    final documentType = document.title
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
    final provider = context.read<PaperworkRequiredProvider>();
    final success = await provider.uploadDocument(
      documentType: documentType,
      image: image,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? '${document.title} uploaded successfully'
              : provider.errorMessage ?? 'Unable to upload ${document.title}',
        ),
      ),
    );
  }

  Future<void> _showFakeVerificationDialog(_Document document) async {
    XFile? image;
    var isSubmitting = false;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Upload ${document.title}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (image != null)
                  Image.file(File(image!.path), height: 130, fit: BoxFit.cover)
                else
                  Text('No ${document.title} image selected'),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () async {
                    final selected = await ImagePicker().pickImage(
                      source: ImageSource.camera,
                      imageQuality: 85,
                    );
                    if (selected != null) {
                      setDialogState(() => image = selected);
                    }
                  },
                  icon: const Icon(Icons.upload_file),
                  label: Text(
                    image == null
                        ? 'Take ${document.title} Photo'
                        : 'Retake Photo',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      if (image == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Please select ${document.title} image',
                            ),
                          ),
                        );
                        return;
                      }
                      if (!mounted) return;
                      Navigator.pop(dialogContext);
                    },
              child: isSubmitting
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Upload'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAadharUploadDialog() async {
    XFile? aadharImage;
    var isSubmitting = false;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Upload Aadhaar Card'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _aadharController,
                keyboardType: TextInputType.number,
                maxLength: 12,
                decoration: const InputDecoration(
                  labelText: 'Aadhaar Number',
                  hintText: '1234 5678 9012',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              if (aadharImage != null)
                Image.file(
                  File(aadharImage!.path),
                  height: 130,
                  fit: BoxFit.cover,
                )
              else
                const Text('No Aadhaar image selected'),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () async {
                  final image = await ImagePicker().pickImage(
                    source: ImageSource.camera,
                    imageQuality: 85,
                  );
                  if (image != null) setDialogState(() => aadharImage = image);
                },
                icon: const Icon(Icons.upload_file),
                label: Text(
                  aadharImage == null
                      ? 'Take Aadhaar Photo'
                      : 'Retake Aadhaar Photo',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      final aadhar = _aadharController.text.replaceAll(' ', '');
                      if (!RegExp(r'^\d{12}$').hasMatch(aadhar)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Enter a valid Aadhaar number'),
                          ),
                        );
                        return;
                      }
                      if (aadharImage == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please select Aadhaar image'),
                          ),
                        );
                        return;
                      }
                      setDialogState(() => isSubmitting = true);
                      final success = await context
                          .read<PaperworkRequiredProvider>()
                          .verifyAndUploadAadhar(
                            aadhar: aadhar,
                            image: aadharImage!,
                          );
                      if (!mounted) return;
                      if (success) {
                        Navigator.pop(dialogContext);
                        setState(() {});
                      } else {
                        setDialogState(() => isSubmitting = false);
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          SnackBar(
                            content: Text(
                              this.context
                                      .read<PaperworkRequiredProvider>()
                                      .errorMessage ??
                                  'Unable to verify or upload Aadhaar',
                            ),
                          ),
                        );
                      }
                    },
              child: isSubmitting
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Verify & Upload'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showVoterUploadDialog() async {
    XFile? voterImage;
    var isSubmitting = false;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Upload Voter ID'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _voterController,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Voter ID Number',
                  hintText: 'HZG0031781',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              if (voterImage != null)
                Image.file(
                  File(voterImage!.path),
                  height: 130,
                  fit: BoxFit.cover,
                )
              else
                const Text('No Voter ID image selected'),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () async {
                  final image = await ImagePicker().pickImage(
                    source: ImageSource.camera,
                    imageQuality: 85,
                  );
                  if (image != null) setDialogState(() => voterImage = image);
                },
                icon: const Icon(Icons.upload_file),
                label: Text(
                  voterImage == null ? 'Take Voter ID Photo' : 'Retake Photo',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      final voterNo = _voterController.text
                          .trim()
                          .toUpperCase();
                      if (voterNo.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Enter Voter ID number'),
                          ),
                        );
                        return;
                      }
                      if (voterImage == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please select Voter ID image'),
                          ),
                        );
                        return;
                      }
                      setDialogState(() => isSubmitting = true);
                      final success = await context
                          .read<PaperworkRequiredProvider>()
                          .verifyAndUploadVoter(
                            voterNo: voterNo,
                            image: voterImage!,
                          );
                      if (!mounted) return;
                      if (success) {
                        Navigator.pop(dialogContext);
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Voter ID verified and uploaded successfully',
                            ),
                          ),
                        );
                      } else {
                        setDialogState(() => isSubmitting = false);
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          SnackBar(
                            content: Text(
                              this.context
                                      .read<PaperworkRequiredProvider>()
                                      .errorMessage ??
                                  'Unable to verify or upload Voter ID',
                            ),
                          ),
                        );
                      }
                    },
              child: isSubmitting
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Verify & Upload'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadAccountType() async {
    final preferences = await SharedPreferences.getInstance();
    final accountType = preferences.getString(
      HomeService.profileAccountTypeKey,
    );
    if (!mounted || accountType == null || accountType.trim().isEmpty) return;
    setState(() => _accountType = accountType);
  }

  List<_Document> get _accountDocuments => _isBusiness
      ? const [
          _Document('📄', 'Business PAN', 'Business PAN card', true),
          _Document('🧾', 'GST', 'GST registration certificate', false),
          _Document('🌐', 'IEC Code', 'Import Export Code', false),
          _Document('🏢', 'MSME Certificate', 'Udyam/MSME registration', false),
          // _Document(
          //   '🧾',
          //   'Commercial Invoice',
          //   'Signed invoice for the shipment',
          //   false,
          // ),
          // _Document(
          //   '🧾',
          //   'Commercial Invoice',
          //   'Signed invoice for the shipment',
          //   false,
          // ),
          // _Document('📦', 'Packing List', 'Item-wise package details', false),
          // _Document(
          //   '🏢',
          //   'Company Proof',
          //   'Certificate of incorporation or company ID',
          //   false,
          // ),
          // _Document(
          //   '🪪',
          //   'Personal ID Proof / Personal PAN Card',
          //   'Authorized person identity proof',
          //   false,
          // ),
          _Document('🪪', 'Aadhaar', 'Authorized person Aadhaar card', false),
          _Document(
            '🗳️',
            'Voter ID',
            'Authorized person Voter ID card',
            false,
          ),
        ]
      : const [
          _Document('📄', 'PAN', 'Personal PAN card', true),
          _Document(
            '🧾',
            'GST',
            'GST registration certificate, if available',
            false,
          ),
          _Document(
            '🌐',
            'IEC Code',
            'Import Export Code, if applicable',
            false,
          ),
          _Document(
            '🏢',
            'MSME Certificate',
            'Udyam/MSME registration, if available',
            false,
          ),
          _Document('🪪', 'Aadhaar', 'Personal identity proof', false),
          _Document('🗳️', 'Voter ID', 'Personal Voter ID card', false),
        ];

  static const _shipmentDocuments = [
    _Document('🔖', 'AWB', 'Airway Bill / shipment document', false),
    // _Document('📦', 'Packing List', 'Item-wise package details', false),
    _Document('🚢', 'Shipping Bill', 'Required for export shipment', false),
    // _Document(
    //   '🧾',
    //   'Commercial Invoice',
    //   'Required for customs clearance',
    //   false,
    // ),
  ];

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: _green,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            const _PaperHeader(),
            Container(
              margin: const EdgeInsets.fromLTRB(9, 10, 9, 9),
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFE9ECFF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.account_circle_outlined,
                    color: _green,
                    size: 22,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      'Account type: $_accountType',
                      style: const TextStyle(
                        color: _green,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _SectionHeading(
                    title: _isBusiness
                        ? 'Business Documents'
                        : 'Individual Documents',
                    subtitle: _isBusiness
                        ? 'Documents required for business shipments'
                        : 'Documents required for individual shipments',
                  ),
                  ..._accountDocuments.map(
                    (document) => _DocumentRow(
                      document: document,
                      number: _documentNumber(document.title),
                      onUpload:
                          document.title == 'PAN' ||
                              document.title == 'Business PAN'
                          ? _showPanUploadDialog
                          : document.title == 'Aadhaar'
                          ? _showAadharUploadDialog
                          : document.title == 'Voter ID'
                          ? _showVoterUploadDialog
                          : document.title == 'GST' ||
                                document.title == 'IEC Code' ||
                                document.title == 'MSME Certificate'
                          ? () => _showFakeVerificationDialog(document)
                          : () => _uploadOptionalDocument(document),
                    ),
                  ),
                  // const _SectionHeading(
                  //   title: 'Shipment Documents',
                  //   subtitle: 'Upload documents related to this shipment',
                  // ),
                  // ..._shipmentDocuments.map(
                  //   (document) => _DocumentRow(
                  //     document: document,
                  //     onUpload: () => _uploadOptionalDocument(document),
                  //   ),
                  // ),
                  if (!_isBusiness)
                    _DocumentRow(
                      document: _Document(
                        '📍',
                        'Need Shipment Track Upload',
                        'Upload shipment tracking details',
                        false,
                      ),
                      onUpload: () => _uploadOptionalDocument(
                        const _Document(
                          '📍',
                          'Need Shipment Track Upload',
                          'Upload shipment tracking details',
                          false,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaperHeader extends StatelessWidget {
  const _PaperHeader();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 136,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Container(color: _PaperworkRequiredState._green),
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
                        'Paperwork Required',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    'Documents needed per shipment type',
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

class _TypeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TypeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(20),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected
            ? _PaperworkRequiredState._green
            : const Color(0xFFF0F0F5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.white : const Color(0xFF667085),
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
  );
}

class _SectionHeading extends StatelessWidget {
  final String title;
  final String subtitle;
  const _SectionHeading({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(9, 10, 9, 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 13, color: Color(0xFF7B8493)),
        ),
      ],
    ),
  );
}

class _DocumentRow extends StatelessWidget {
  final _Document document;
  final String? number;
  final VoidCallback? onUpload;
  const _DocumentRow({required this.document, this.number, this.onUpload});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 66,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE8E8ED))),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: document.required
                  ? const Color(0xFFFFF6D8)
                  : const Color(0xFFF0F0F5),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Text(document.icon, style: const TextStyle(fontSize: 19)),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  document.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  document.subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF7B8493),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (number != null)
                  Text(
                    'Number: $number',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF667085),
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: document.required
                  ? const Color(0xFFFFEAEA)
                  : const Color(0xFFF0F0F5),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              document.required ? 'Must' : 'Optional',
              style: TextStyle(
                color: document.required ? Colors.red : const Color(0xFF667085),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 6),
          if (onUpload != null)
            ElevatedButton(
              onPressed: onUpload,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryButton,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                minimumSize: const Size(0, 34),
              ),
              child: const Text('Upload'),
            ),
        ],
      ),
    );
  }
}

class _PaperSection {
  final String title;
  final String subtitle;
  final List<_Document> documents;
  const _PaperSection({
    required this.title,
    required this.subtitle,
    required this.documents,
  });
}

class _Document {
  final String icon;
  final String title;
  final String subtitle;
  final bool required;
  const _Document(this.icon, this.title, this.subtitle, this.required);
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
