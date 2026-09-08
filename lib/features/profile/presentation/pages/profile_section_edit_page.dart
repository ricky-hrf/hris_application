import 'package:flutter/material.dart';

import '../../../../core/errors/exceptions.dart';

typedef ProfileEditValueGetter = String Function();

class ProfileEditField {
  final String key;
  final String label;
  final IconData icon;
  final Widget Function(BuildContext context) builder;
  final ProfileEditValueGetter getValue;

  const ProfileEditField({
    required this.key,
    required this.label,
    required this.icon,
    required this.builder,
    required this.getValue,
  });

  static ProfileEditField text({
    required String key,
    required String label,
    required IconData icon,
    required TextEditingController controller,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return ProfileEditField(
      key: key,
      label: label,
      icon: icon,
      getValue: () => controller.text.trim(),
      builder: (context) => TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 19),
          filled: true,
          fillColor: const Color(0xFFF7FAF9),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  static ProfileEditField date({
    required String key,
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required BuildContext Function() contextGetter,
  }) {
    Future<void> pick() async {
      final ctx = contextGetter();
      final initial = DateTime.tryParse(controller.text) ?? DateTime(2000, 1, 1);
      final picked = await showDatePicker(
        context: ctx,
        initialDate: initial,
        firstDate: DateTime(1950),
        lastDate: DateTime.now(),
      );
      if (picked != null) {
        controller.text =
        '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      }
    }

    return ProfileEditField(
      key: key,
      label: label,
      icon: icon,
      getValue: () => controller.text.trim(),
      builder: (context) => TextFormField(
        controller: controller,
        readOnly: true,
        onTap: pick,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 19),
          suffixIcon: const Icon(Icons.calendar_month_rounded, size: 18),
          filled: true,
          fillColor: const Color(0xFFF7FAF9),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  static ProfileEditField dropdown({
    required String key,
    required String label,
    required IconData icon,
    required ValueNotifier<String> notifier,
    required Map<String, String> options,
  }) {
    return ProfileEditField(
      key: key,
      label: label,
      icon: icon,
      getValue: () => notifier.value,
      builder: (context) => ValueListenableBuilder<String>(
        valueListenable: notifier,
        builder: (context, value, _) {
          return DropdownButtonFormField<String>(
            initialValue: options.containsKey(value) ? value : options.keys.first,
            decoration: InputDecoration(
              labelText: label,
              prefixIcon: Icon(icon, size: 19),
              filled: true,
              fillColor: const Color(0xFFF7FAF9),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            items: options.entries
                .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                .toList(),
            onChanged: (v) {
              if (v != null) notifier.value = v;
            },
          );
        },
      ),
    );
  }
}

class ProfileSectionEditPage extends StatefulWidget {
  final String title;
  final List<ProfileEditField> fields;
  final Future<void> Function(Map<String, String> values) onSubmit;

  const ProfileSectionEditPage({
    super.key,
    required this.title,
    required this.fields,
    required this.onSubmit,
  });

  @override
  State<ProfileSectionEditPage> createState() => _ProfileSectionEditPageState();
}

class _ProfileSectionEditPageState extends State<ProfileSectionEditPage> {
  static const _teal = Color(0xFF0F5C48);

  bool _isSaving = false;

  Future<void> _handleSave() async {
    setState(() => _isSaving = true);

    try {
      final values = {for (final f in widget.fields) f.key: f.getValue()};
      await widget.onSubmit(values);

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on AppException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('Gagal menyimpan perubahan');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF9),
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: const Color(0xFFF7FAF9),
        foregroundColor: _teal,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final field in widget.fields) ...[
              field.builder(context),
              const SizedBox(height: 14),
            ],
            const SizedBox(height: 8),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _isSaving
                    ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                )
                    : const Text('Simpan Perubahan', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}