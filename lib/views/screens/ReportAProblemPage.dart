import 'package:flutter/material.dart';

class ReportAProblemPage extends StatefulWidget {
  const ReportAProblemPage({super.key});

  @override
  State<ReportAProblemPage> createState() => _ReportAProblemPageState();
}

class _ReportAProblemPageState extends State<ReportAProblemPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _firstName = TextEditingController();
  final TextEditingController _lastName = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _appUserId = TextEditingController();

  String _countryCode = '+91';

  final List<Map<String, dynamic>> _complaintOptions = [
    {'label': 'Objection to Content', 'value': 'objection'},
    {'label': 'Nudity/Pornography', 'value': 'nudity'},
    {'label': 'Reinstatement of Account', 'value': 'reinstatement'},
    {'label': 'Violation of Copyright/IP', 'value': 'copyright'},
    {'label': 'Judicial Order', 'value': 'judicial'},
  ];

  final Set<String> _selectedComplaints = {};

  bool _autoValidate = false;

  // Gradient used throughout
  final LinearGradient _mainGradient = const LinearGradient(
    colors: [Color(0xFFFF00CC), Color(0xFF9A00F0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  void _submit() {
    setState(() => _autoValidate = true);

    final bool hasComplaint = _selectedComplaints.isNotEmpty;

    if (_formKey.currentState!.validate() && hasComplaint) {
      final data = {
        'firstName': _firstName.text.trim(),
        'lastName': _lastName.text.trim(),
        'phone': '$_countryCode ${_phone.text.trim()}',
        'email': _email.text.trim(),
        'appUserId': _appUserId.text.trim(),
        'complaints': _selectedComplaints.toList(),
      };

      showDialog(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text('Submitted'),
          content: Text('Form submitted successfully:\n\n${data.toString()}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(c).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else if (!hasComplaint) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one nature of complaint'),
        ),
      );
    }
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _phone.dispose();
    _email.dispose();
    _appUserId.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration(String label, {bool required = false}) {
    return InputDecoration(
      labelText: required ? '$label *' : label,
      labelStyle: const TextStyle(fontSize: 14),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Report a Problem',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: _mainGradient),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: _autoValidate
                        ? AutovalidateMode.always
                        : AutovalidateMode.disabled,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Please fill the details below',
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                        const SizedBox(height: 18),

                        // First Name & Last Name
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _firstName,
                                decoration: _fieldDecoration(
                                  'First Name',
                                  required: true,
                                ),
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                    ? 'Enter first name'
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: _lastName,
                                decoration: _fieldDecoration(
                                  'Last Name',
                                  required: true,
                                ),
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                    ? 'Enter last name'
                                    : null,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        // Phone Number
                        Row(
                          children: [
                            Flexible(
                              flex: 2,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _countryCode,
                                    isExpanded: true,
                                    items: const [
                                      DropdownMenuItem(
                                        value: '+91',
                                        child: Text('🇮🇳 +91'),
                                      ),
                                      DropdownMenuItem(
                                        value: '+1',
                                        child: Text('🇺🇸 +1'),
                                      ),
                                      DropdownMenuItem(
                                        value: '+44',
                                        child: Text('🇬🇧 +44'),
                                      ),
                                    ],
                                    onChanged: (v) {
                                      if (v != null) {
                                        setState(() => _countryCode = v);
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Flexible(
                              flex: 5,
                              child: TextFormField(
                                controller: _phone,
                                keyboardType: TextInputType.phone,
                                decoration: _fieldDecoration(
                                  'Registered Contact Number',
                                  required: true,
                                ),
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                    ? 'Enter contact number'
                                    : null,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Email
                        TextFormField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          decoration: _fieldDecoration(
                            'Email Address',
                            required: true,
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Enter email address';
                            }
                            final emailRegex = RegExp(
                              r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                            );
                            if (!emailRegex.hasMatch(v.trim())) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // App User ID
                        TextFormField(
                          controller: _appUserId,
                          decoration: _fieldDecoration(
                            'App User ID',
                            required: true,
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Enter App User ID'
                              : null,
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          'What is the nature of your complaint? *',
                          style: TextStyle(fontSize: 15),
                        ),
                        const SizedBox(height: 8),

                        // Complaint Checkboxes
                        ..._complaintOptions.map((opt) {
                          final label = opt['label'] as String;
                          final value = opt['value'] as String;
                          final isChecked = _selectedComplaints.contains(value);

                          return Theme(
                            data: Theme.of(context).copyWith(
                              checkboxTheme: CheckboxThemeData(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                side: BorderSide(
                                  color: isChecked
                                      ? Colors.transparent
                                      : Colors.grey.shade400,
                                ),
                                fillColor: MaterialStateProperty.resolveWith((
                                  states,
                                ) {
                                  if (states.contains(MaterialState.selected)) {
                                    // Use a solid fallback color for the checked box.
                                    // For a true gradient inside the box you'd need a custom widget.
                                    return const Color(0xFF9A00F0);
                                  }
                                  return Colors.white;
                                }),
                              ),
                            ),
                            child: CheckboxListTile(
                              contentPadding: EdgeInsets.zero,
                              // Always use the same text color for the label
                              title: Text(
                                label,
                                style: const TextStyle(color: Colors.black87),
                              ),
                              value: isChecked,
                              onChanged: (v) {
                                setState(() {
                                  if (v == true) {
                                    _selectedComplaints.add(value);
                                  } else {
                                    _selectedComplaints.remove(value);
                                  }
                                });
                              },
                              controlAffinity: ListTileControlAffinity.leading,
                              activeColor: const Color(0xFF9A00F0),
                              checkColor: Colors.white,
                            ),
                          );
                        }).toList(),

                        const SizedBox(height: 20),

                        Row(
                          children: const [
                            Icon(
                              Icons.info_outline,
                              size: 18,
                              color: Colors.black54,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Attaching image is optional. Priority level can be chosen separately.',
                                style: TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Gradient Submit Button
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: _mainGradient,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                offset: const Offset(0, 4),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _submit,
                                child: const SizedBox(
                                  height: 48,
                                  child: Center(
                                    child: Text(
                                      'Submit',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
