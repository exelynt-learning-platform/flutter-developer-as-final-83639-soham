import 'package:employee_management_assessment/framework/controller/emp_controller.dart';
import 'package:employee_management_assessment/framework/model/employee.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class EmployeeFormScreen extends StatefulWidget {
  const EmployeeFormScreen({super.key, this.employee});
  final Employee? employee;
  @override
  State<EmployeeFormScreen> createState() => _EmployeeFormScreenState();
}

class _EmployeeFormScreenState extends State<EmployeeFormScreen> {
  final _form = GlobalKey<FormState>();
  late final List<TextEditingController> _fields;
  bool _saving = false;
  @override
  void initState() {
    super.initState();
    final e = widget.employee;
    _fields = [
      TextEditingController(text: e?.name),
      TextEditingController(text: e?.email),
      TextEditingController(text: e?.mobile),
      TextEditingController(text: e?.country),
      TextEditingController(text: e?.state),
      TextEditingController(text: e?.district),
    ];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<EmployeeController>().loadCountries();
    });
  }

  @override
  void dispose() {
    for (final f in _fields) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.employee == null ? 'Add employee' : 'Edit employee'),
    ),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: Form(
          key: _form,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Employee information',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              ...List.generate(
                6,
                (i) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _buildField(
                    i,
                    context.watch<EmployeeController>().countries,
                  ),
                ),
              ),
              if (context.watch<EmployeeController>().error != null)
                Text(
                  context.watch<EmployeeController>().error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : Text(
                  widget.employee == null
                      ? 'Save employee'
                      : 'Save changes',
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _buildField(int i, List<String> countries) {
    final key = Key('employeeField$i');
    final label = [
      'Full name',
      'Email address',
      'Mobile number',
      'Country',
      'State',
      'District',
    ][i];
    final icon = Icon(
      [
        Icons.person_outline,
        Icons.mail_outline,
        Icons.phone_outlined,
        Icons.public,
        Icons.map_outlined,
        Icons.location_city_outlined,
      ][i],
    );

    if (i == 3 && countries.isNotEmpty) {
      return Autocomplete<String>(
        initialValue: TextEditingValue(text: _fields[3].text),
        optionsBuilder: (textEditingValue) {
          if (textEditingValue.text.isEmpty) return countries;
          return countries.where(
            (c) => c.toLowerCase().contains(textEditingValue.text.toLowerCase()),
          );
        },
        onSelected: (selection) {
          _fields[3].text = selection;
        },
        fieldViewBuilder: (ctx, controller, focusNode, onFieldSubmitted) {
          controller.addListener(() {
            _fields[3].text = controller.text;
          });
          return TextFormField(
            key: key,
            controller: controller,
            focusNode: focusNode,
            decoration: InputDecoration(
              labelText: label,
              prefixIcon: icon,
            ),
            validator: (v) => _validate(i, v),
          );
        },
      );
    }

    return TextFormField(
      key: key,
      controller: _fields[i],
      keyboardType: i == 1
          ? TextInputType.emailAddress
          : i == 2
          ? TextInputType.phone
          : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon,
      ),
      validator: (v) => _validate(i, v),
    );
  }

  String? _validate(int i, String? v) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) return 'This field is required';
    if (i == 1 && !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)) {
      return 'Enter a valid email';
    }
    if (i == 2 && !RegExp(r'^\+?[0-9 ()-]{7,20}$').hasMatch(value)) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    final e = Employee(
      id: widget.employee?.id,
      name: _fields[0].text.trim(),
      email: _fields[1].text.trim(),
      mobile: _fields[2].text.trim(),
      country: _fields[3].text.trim(),
      state: _fields[4].text.trim(),
      district: _fields[5].text.trim(),
    );
    try {
      await context.read<EmployeeController>().save(e);
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
