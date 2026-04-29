import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:projects/features/shop/bloc/modbus_cubit.dart';
import 'package:projects/utils/constants/colors.dart';
import 'package:projects/utils/constants/sizes.dart';

class ModbusBottomSheet extends StatefulWidget {
  const ModbusBottomSheet({super.key});

  @override
  State<ModbusBottomSheet> createState() => _ModbusBottomSheetState();
}

class _ModbusBottomSheetState extends State<ModbusBottomSheet>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(TSizes.cardRadiusLg),
            ),
          ),
          child: Column(
            children: [
              _SheetHandle(),
              _SheetHeader(),
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Read'),
                  Tab(text: 'Write'),
                  Tab(text: 'Stream'),
                ],
                labelStyle: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const Divider(height: 1),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: const [
                    _ReadTab(),
                    _WriteTab(),
                    _StreamTab(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SheetHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.outlineVariant,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        TSizes.defaultSpace,
        0,
        TSizes.defaultSpace,
        TSizes.spaceBtwItems,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: TColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.memory_rounded,
                color: TColors.primary, size: TSizes.iconMd),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Modbus Registers',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                'Read · Write · Stream',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// READ TAB
// ──────────────────────────────────────────────

class _ReadTab extends StatefulWidget {
  const _ReadTab();

  @override
  State<_ReadTab> createState() => _ReadTabState();
}

class _ReadTabState extends State<_ReadTab> {
  final _registerCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _registerCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<ModbusCubit>().readRegister(int.parse(_registerCtrl.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(TSizes.defaultSpace),
      child: BlocBuilder<ModbusCubit, ModbusState>(
        builder: (context, state) {
          final busy = state.operation == ModbusOperation.reading;

          return Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Register Address',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _registerCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    hintText: 'e.g. 100',
                    prefixIcon: Icon(Icons.tag_rounded),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Enter a register address';
                    final n = int.tryParse(v.trim());
                    if (n == null || n < 0 || n > 65535) {
                      return 'Must be 0 – 65535';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: TSizes.spaceBtwItems),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: busy ? null : _submit,
                    icon: busy
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.download_rounded, size: 18),
                    label: Text(busy ? 'Reading…' : 'Read Register'),
                  ),
                ),
                const SizedBox(height: TSizes.spaceBtwSections),
                if (state.errorMessage != null) _ErrorBanner(state.errorMessage!),
                if (state.lastReadValue != null && !busy)
                  _ReadResultCard(
                    register: state.lastReadRegister!,
                    value: state.lastReadValue!,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ReadResultCard extends StatelessWidget {
  const _ReadResultCard({required this.register, required this.value});
  final int register;
  final int value;

  @override
  Widget build(BuildContext context) {
    final hex = '0x${value.toRadixString(16).toUpperCase().padLeft(4, '0')}';
    final bin = value.toRadixString(2).padLeft(16, '0');
    final binFormatted =
        '${bin.substring(0, 8)} ${bin.substring(8)}'; // byte groups

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
        side: BorderSide(
          color: Colors.green.shade300,
        ),
      ),
      color: Colors.green.withValues(alpha: 0.04),
      child: Padding(
        padding: const EdgeInsets.all(TSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: Colors.green, size: TSizes.iconSm),
                const SizedBox(width: 6),
                Text(
                  'Reg ${register.toString().padLeft(3, '0')} — Read OK',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors.green.shade700,
                      ),
                ),
              ],
            ),
            const SizedBox(height: TSizes.spaceBtwItems),
            _ValueRow(label: 'DEC', value: value.toString()),
            _ValueRow(label: 'HEX', value: hex),
            _ValueRow(label: 'BIN', value: binFormatted),
          ],
        ),
      ),
    );
  }
}

class _ValueRow extends StatelessWidget {
  const _ValueRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// WRITE TAB
// ──────────────────────────────────────────────

class _WriteTab extends StatefulWidget {
  const _WriteTab();

  @override
  State<_WriteTab> createState() => _WriteTabState();
}

class _WriteTabState extends State<_WriteTab> {
  final _registerCtrl = TextEditingController();
  final _valueCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _registerCtrl.dispose();
    _valueCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<ModbusCubit>().writeRegister(
          int.parse(_registerCtrl.text.trim()),
          int.parse(_valueCtrl.text.trim()),
        );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(TSizes.defaultSpace),
      child: BlocBuilder<ModbusCubit, ModbusState>(
        builder: (context, state) {
          final busy = state.operation == ModbusOperation.writing;

          return Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Register Address',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _registerCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    hintText: 'e.g. 100',
                    prefixIcon: Icon(Icons.tag_rounded),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Enter a register address';
                    final n = int.tryParse(v.trim());
                    if (n == null || n < 0 || n > 65535) return 'Must be 0 – 65535';
                    return null;
                  },
                ),
                const SizedBox(height: TSizes.spaceBtwItems),
                Text(
                  'Value (0 – 65535)',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _valueCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    hintText: 'e.g. 1024',
                    prefixIcon: Icon(Icons.pin_rounded),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Enter a value';
                    final n = int.tryParse(v.trim());
                    if (n == null || n < 0 || n > 65535) return 'Must be 0 – 65535';
                    return null;
                  },
                ),
                const SizedBox(height: TSizes.spaceBtwItems),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: busy ? null : _submit,
                    icon: busy
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.upload_rounded, size: 18),
                    label: Text(busy ? 'Writing…' : 'Write Register'),
                  ),
                ),
                const SizedBox(height: TSizes.spaceBtwSections),
                if (state.errorMessage != null) _ErrorBanner(state.errorMessage!),
                if (state.writeMessage != null && !busy)
                  _WriteAckCard(
                    register: state.lastWriteRegister!,
                    value: state.lastWriteValue!,
                    success: state.writeSuccess!,
                    message: state.writeMessage!,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _WriteAckCard extends StatelessWidget {
  const _WriteAckCard({
    required this.register,
    required this.value,
    required this.success,
    required this.message,
  });

  final int register;
  final int value;
  final bool success;
  final String message;

  @override
  Widget build(BuildContext context) {
    final color = success ? Colors.green : Colors.red;
    final icon = success
        ? Icons.check_circle_rounded
        : Icons.error_rounded;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
        side: BorderSide(color: color.shade300),
      ),
      color: color.withValues(alpha: 0.04),
      child: Padding(
        padding: const EdgeInsets.all(TSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: TSizes.iconSm),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Reg ${register.toString().padLeft(3, '0')} ← $value',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: color.shade700,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// STREAM TAB
// ──────────────────────────────────────────────

class _StreamTab extends StatefulWidget {
  const _StreamTab();

  @override
  State<_StreamTab> createState() => _StreamTabState();
}

class _StreamTabState extends State<_StreamTab> {
  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ModbusCubit, ModbusState>(
      listenWhen: (prev, curr) =>
          curr.streamEntries.length != prev.streamEntries.length,
      listener: (context, state) => _scrollToBottom(),
      builder: (context, state) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: TSizes.defaultSpace,
                vertical: TSizes.spaceBtwItems,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.isStreaming ? 'Streaming…' : 'Stream stopped',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${state.streamEntries.length} entries',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  if (!state.isStreaming)
                    FilledButton.icon(
                      onPressed: () => context.read<ModbusCubit>().startStream(),
                      icon: const Icon(Icons.play_arrow_rounded, size: 18),
                      label: const Text('Start'),
                    )
                  else
                    FilledButton.icon(
                      onPressed: () => context.read<ModbusCubit>().stopStream(),
                      style: FilledButton.styleFrom(
                          backgroundColor: Colors.red.shade600),
                      icon: const Icon(Icons.stop_rounded, size: 18),
                      label: const Text('Stop'),
                    ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: state.streamEntries.isEmpty
                  ? _StreamEmptyState(isStreaming: state.isStreaming)
                  : ListView.builder(
                      controller: _scrollCtrl,
                      padding: const EdgeInsets.symmetric(
                        horizontal: TSizes.defaultSpace,
                        vertical: 8,
                      ),
                      itemCount: state.streamEntries.length,
                      itemBuilder: (context, index) {
                        final entry = state.streamEntries[index];
                        return _StreamEntryTile(entry: entry, index: index);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _StreamEmptyState extends StatelessWidget {
  const _StreamEmptyState({required this.isStreaming});
  final bool isStreaming;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isStreaming ? Icons.hourglass_top_rounded : Icons.stream_rounded,
            size: 40,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          const SizedBox(height: 8),
          Text(
            isStreaming ? 'Waiting for data…' : 'Press Start to begin streaming',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

class _StreamEntryTile extends StatelessWidget {
  const _StreamEntryTile({required this.entry, required this.index});
  final ModbusEntry entry;
  final int index;

  @override
  Widget build(BuildContext context) {
    final hex =
        '0x${entry.value.toRadixString(16).toUpperCase().padLeft(4, '0')}';
    final time =
        '${entry.timestamp.hour.toString().padLeft(2, '0')}:${entry.timestamp.minute.toString().padLeft(2, '0')}:${entry.timestamp.second.toString().padLeft(2, '0')}.${(entry.timestamp.millisecond ~/ 10).toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              '${index + 1}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              'Reg ${entry.register.toString().padLeft(3, '0')}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: TColors.primary,
                  ),
            ),
          ),
          Text(
            entry.value.toString().padLeft(5),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontFamily: 'monospace',
                ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 52,
            child: Text(
              hex,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontFamily: 'monospace',
                  ),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            time,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  fontSize: 10,
                ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// SHARED WIDGETS
// ──────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner(this.message);
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(TSizes.sm),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(TSizes.borderRadiusMd),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded,
              color: Theme.of(context).colorScheme.onErrorContainer,
              size: TSizes.iconSm),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
