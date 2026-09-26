import 'package:employee_management_assessment/framework/controller/auth_controller.dart';
import 'package:employee_management_assessment/framework/controller/emp_controller.dart';
import 'package:employee_management_assessment/framework/model/employee.dart';
import 'package:employee_management_assessment/framework/services/sharedpreferences_service.dart';
import 'package:employee_management_assessment/ui/emp_form.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _search = TextEditingController();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
          (_) => context.read<EmployeeController>().load(),
    );
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Consumer<EmployeeController>(
    builder: (context, data, _) {
      final wide = MediaQuery.sizeOf(context).width >= 760;
      return Scaffold(
        appBar: AppBar(
          title: const Text('PeopleDesk'),
          actions: [
            Consumer<SharedPreferencesService>(
              builder: (context, prefs, _) => IconButton(
                tooltip: 'Toggle theme',
                onPressed: () => prefs.setDarkMode(!prefs.darkMode),
                icon: Icon(
                  prefs.darkMode
                      ? Icons.light_mode_outlined
                      : Icons.dark_mode_outlined,
                ),
              ),
            ),
            Consumer<AuthController>(
              builder: (context, auth, _) {
                final user = auth.user;
                final photoUrl = user?.photoURL;
                final name = user?.displayName ?? user?.email ?? '';
                final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';

                return PopupMenuButton<String>(
                  tooltip: 'Account',
                  onSelected: (v) {
                    if (v == 'profile') _showProfileDialog(context);
                    if (v == 'logout') context.read<AuthController>().logout();
                  },
                  icon: CircleAvatar(
                    radius: 16,
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    backgroundImage: (photoUrl != null && photoUrl.isNotEmpty)
                        ? NetworkImage(photoUrl)
                        : null,
                    child: (photoUrl == null || photoUrl.isEmpty)
                        ? Text(
                            initial,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                            ),
                          )
                        : null,
                  ),
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      enabled: false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.displayName ?? 'User',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            user?.email ?? '',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const Divider(),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'profile',
                      child: Row(
                        children: [
                          Icon(Icons.person_outline, size: 20),
                          SizedBox(width: 8),
                          Text('Edit Profile Photo'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.logout, size: 20),
                          SizedBox(width: 8),
                          Text('Sign out'),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () => data.load(refresh: true),
          child: ListView(
            padding: EdgeInsets.symmetric(
              horizontal: wide ? 32 : 16,
              vertical: 16,
            ),
            children: [
              _welcome(context),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Employees',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: () => _openForm(context),
                    icon: const Icon(Icons.add),
                    label: Text(wide ? 'Add employee' : 'Add'),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _metrics(context, data.employees.length, wide),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      key: const Key('employeeSearch'),
                      controller: _search,
                      onChanged: (v) => data.search(v),
                      decoration: const InputDecoration(
                        hintText: 'Search employees',
                        prefixIcon: Icon(Icons.search),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  DropdownButton<String>(
                    value: data.filter,
                    items: const ['Name', 'Email', 'Mobile', 'Country', 'ID']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => data.search(_search.text, by: v),
                  ),
                ],
              ),
              if (data.error != null)
                _message(
                  Icons.error_outline,
                  data.error!,
                  onTap: () => data.load(refresh: true),
                ),
              if (data.loading && data.employees.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(44),
                  child: Center(child: CircularProgressIndicator()),
                ),
              if (!data.loading && data.employees.isEmpty && data.error == null)
                _message(
                  Icons.people_outline,
                  'No employees yet. Add your first team member.',
                ),
              if (!data.loading &&
                  data.filteredEmployees.isEmpty &&
                  data.employees.isNotEmpty)
                _message(Icons.search_off, 'No employees match your search.'),
              if (data.filteredEmployees.isNotEmpty && wide)
                _table(context, data.filteredEmployees),
              if (data.filteredEmployees.isNotEmpty && !wide)
                ...data.filteredEmployees.map((e) => _employeeCard(context, e)),
            ],
          ),
        ),
      );
    },
  );
  Widget _welcome(BuildContext context) {
    final user = context.watch<AuthController>().user;
    final name = user?.displayName?.trim().isNotEmpty == true
        ? user!.displayName!
        : (user?.email?.split('@').first ?? 'there');
    final photoUrl = user?.photoURL;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(18),
        leading: GestureDetector(
          onTap: () => _showProfileDialog(context),
          child: Stack(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor:
                    Theme.of(context).colorScheme.primaryContainer,
                backgroundImage: (photoUrl != null && photoUrl.isNotEmpty)
                    ? NetworkImage(photoUrl)
                    : null,
                child: (photoUrl == null || photoUrl.isEmpty)
                    ? Text(
                        initial,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimaryContainer,
                        ),
                      )
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.edit,
                    size: 11,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        title: Text(
          'Good day, $name',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(user?.email ?? 'Your team overview'),
        trailing: IconButton(
          icon: const Icon(Icons.edit_outlined, size: 20),
          tooltip: 'Edit Profile Photo',
          onPressed: () => _showProfileDialog(context),
        ),
      ),
    );
  }

  Widget _metrics(BuildContext context, int count, bool wide) => Row(
    children: [
      Expanded(
        child: _metric('Total employees', '$count', Icons.groups_outlined),
      ),
      const SizedBox(width: 12),
      Expanded(child: _metric('Workspace', 'Active', Icons.verified_outlined)),
      if (wide) const SizedBox(width: 12),
      if (wide)
        Expanded(
          child: _metric('Directory', 'Up to date', Icons.sync_outlined),
        ),
    ],
  );
  Widget _metric(String label, String value, IconData icon) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
  Widget _table(BuildContext context, List<Employee> items) => Card(
    clipBehavior: Clip.antiAlias,
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('ID')),
          DataColumn(label: Text('Photo')),
          DataColumn(label: Text('Name')),
          DataColumn(label: Text('Email')),
          DataColumn(label: Text('Mobile')),
          DataColumn(label: Text('Country')),
          DataColumn(label: Text('Location')),
          DataColumn(label: Text('Actions')),
        ],
        rows: items
            .map(
              (e) => DataRow(
            cells: [
              DataCell(Text(e.id ?? '—')),
              DataCell(
                CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(e.displayAvatar),
                ),
              ),
              DataCell(Text(e.name)),
              DataCell(Text(e.email)),
              DataCell(Text(e.mobile)),
              DataCell(Text(e.country)),
              DataCell(Text('${e.state}, ${e.district}')),
              DataCell(_actions(context, e)),
            ],
          ),
        )
            .toList(),
      ),
    ),
  );
  Widget _employeeCard(BuildContext context, Employee e) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundImage: NetworkImage(e.displayAvatar),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'ID ${e.id ?? '—'}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              _actions(context, e),
            ],
          ),
          const Divider(height: 24),
          _line(Icons.mail_outline, e.email),
          _line(Icons.phone_outlined, e.mobile),
          _line(
            Icons.location_on_outlined,
            '${e.district}, ${e.state}, ${e.country}',
          ),
        ],
      ),
    ),
  );
  Widget _line(IconData icon, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        Icon(icon, size: 17),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    ),
  );
  Widget _actions(BuildContext context, Employee e) => PopupMenuButton<String>(
    tooltip: 'Employee actions',
    onSelected: (v) {
      if (v == 'edit') _openForm(context, employee: e);
      if (v == 'view') _details(context, e);
      if (v == 'delete') _confirmDelete(context, e);
    },
    itemBuilder: (_) => const [
      PopupMenuItem(value: 'view', child: Text('View details')),
      PopupMenuItem(value: 'edit', child: Text('Edit')),
      PopupMenuItem(value: 'delete', child: Text('Delete')),
    ],
  );
  Future<void> _openForm(BuildContext context, {Employee? employee}) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => EmployeeFormScreen(employee: employee)),
    );
    if (result == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            employee == null ? 'Employee added' : 'Employee updated',
          ),
        ),
      );
    }
  }

  void _details(BuildContext context, Employee e) => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (_) => Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundImage: NetworkImage(e.displayAvatar),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(e.name, style: Theme.of(context).textTheme.headlineSmall),
                    Text('ID: ${e.id ?? '—'}', style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(),
          const SizedBox(height: 12),
          Text('Email: ${e.email}'),
          Text('Mobile: ${e.mobile}'),
          Text('Country: ${e.country}'),
          Text('State: ${e.state}'),
          Text('District: ${e.district}'),
          const SizedBox(height: 16),
        ],
      ),
    ),
  );
  Future<void> _confirmDelete(BuildContext context, Employee e) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete employee?'),
        content: Text('Remove ${e.name} from your directory?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (yes == true && context.mounted) {
      try {
        await context.read<EmployeeController>().remove(e.id!);
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Employee deleted')));
        }
      } catch (err) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not delete employee: $err')),
          );
        }
      }
    }
  }

  Widget _message(IconData icon, String text, {VoidCallback? onTap}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 52),
    child: InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, size: 40),
          const SizedBox(height: 12),
          Text(text, textAlign: TextAlign.center),
        ],
      ),
    ),
  );

  Future<void> _showProfileDialog(BuildContext context) async {
    final user = context.read<AuthController>().user;
    final nameController =
        TextEditingController(text: user?.displayName ?? '');
    final photoController = TextEditingController(text: user?.photoURL ?? '');

    await showDialog<void>(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setState) {
          final photoUrl = photoController.text.trim();
          final name = nameController.text.trim();
          final initial = name.isNotEmpty
              ? name[0].toUpperCase()
              : (user?.email?.isNotEmpty == true
                  ? user!.email![0].toUpperCase()
                  : 'U');

          return AlertDialog(
            title: const Text('Edit User Profile'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor:
                        Theme.of(ctx).colorScheme.primaryContainer,
                    backgroundImage:
                        photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                    child: photoUrl.isEmpty
                        ? Text(
                            initial,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color:
                                  Theme.of(ctx).colorScheme.onPrimaryContainer,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Display Name',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: photoController,
                    decoration: const InputDecoration(
                      labelText: 'Profile Photo URL',
                      prefixIcon: Icon(Icons.image_outlined),
                      hintText: 'https://example.com/photo.jpg',
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Sample Avatars:',
                      style: Theme.of(ctx).textTheme.labelMedium,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _avatarChoice(
                        ctx,
                        'https://i.pravatar.cc/150?img=60',
                        photoController,
                        setState,
                      ),
                      _avatarChoice(
                        ctx,
                        'https://i.pravatar.cc/150?img=68',
                        photoController,
                        setState,
                      ),
                      _avatarChoice(
                        ctx,
                        'https://i.pravatar.cc/150?img=33',
                        photoController,
                        setState,
                      ),
                      _avatarChoice(
                        ctx,
                        'https://i.pravatar.cc/150?img=12',
                        photoController,
                        setState,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  Navigator.pop(dialogCtx);
                  try {
                    await context.read<AuthController>().updateProfile(
                          displayName: nameController.text,
                          photoURL: photoController.text,
                        );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Profile updated successfully'),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to update profile: $e')),
                      );
                    }
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _avatarChoice(
    BuildContext context,
    String url,
    TextEditingController controller,
    StateSetter setState,
  ) {
    final selected = controller.text.trim() == url;
    return GestureDetector(
      onTap: () {
        setState(() {
          controller.text = url;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: selected
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            width: 2.5,
          ),
        ),
        child: CircleAvatar(
          radius: 18,
          backgroundImage: NetworkImage(url),
        ),
      ),
    );
  }
}
