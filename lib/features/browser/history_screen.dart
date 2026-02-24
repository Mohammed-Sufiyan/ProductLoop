import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:productloop/features/browser/browser_screen.dart';
import 'package:productloop/features/browser/history_provider.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Browsing History',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        actions: [
          if (history.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                icon: const Icon(Icons.delete_sweep_rounded),
                tooltip: 'Clear History',
                onPressed: () => _showClearDialog(context, ref, isDark),
              ),
            ),
        ],
      ),
      body: history.isEmpty
          ? _buildEmptyState(theme)
          : _buildHistoryList(context, ref, history, theme, isDark),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.history_rounded,
              size: 48,
              color: theme.colorScheme.primary.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No History Yet',
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Products you view will appear here',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(
    BuildContext context,
    WidgetRef ref,
    List<String> history,
    ThemeData theme,
    bool isDark,
  ) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: history.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final rawItem = history[index];
        try {
          final data = jsonDecode(rawItem);
          final title = (data['title'] ?? 'Unknown Item').toString();
          final imageUrl = data['image']?.toString();
          final timeParsed = DateTime.tryParse(data['timestamp'] ?? '');

          String dateStr = 'Visited';
          if (timeParsed != null) {
            final now = DateTime.now();
            final diff = now.difference(timeParsed);
            if (diff.inMinutes < 1) {
              dateStr = 'Just now';
            } else if (diff.inMinutes < 60) {
              dateStr = '${diff.inMinutes}m ago';
            } else if (diff.inHours < 24) {
              dateStr = '${diff.inHours}h ago';
            } else {
              dateStr = '${diff.inDays}d ago';
            }
          }

          return _HistoryTile(
            title: title,
            imageUrl: imageUrl,
            dateStr: dateStr,
            isDark: isDark,
            theme: theme,
            onTap: () {
              if (data['id'] != null && imageUrl != null && data['url'] != null) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => BrowserScreen(
                      productId: int.parse(data['id'].toString()),
                      imageUrl: imageUrl,
                      url: data['url'].toString(),
                      title: title,
                    ),
                  ),
                );
              }
            },
            onDismissed: () {
              final updatedHistory = List<String>.from(history);
              updatedHistory.removeAt(index);
              ref.read(historyProvider.notifier).replaceHistory(updatedHistory);
            },
          );
        } catch (_) {
          // Fallback for legacy history entries
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.link_rounded, color: Colors.grey),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    rawItem,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  void _showClearDialog(BuildContext context, WidgetRef ref, bool isDark) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Clear History',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (context, anim1, anim2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
          child: FadeTransition(opacity: anim1, child: child),
        );
      },
      pageBuilder: (context, anim1, anim2) {
        final theme = Theme.of(context);
        return Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.delete_forever_rounded,
                      color: Colors.redAccent,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Clear History?',
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This will permanently remove all your browsing history. This action cannot be undone.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      height: 1.5,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            side: BorderSide(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.15),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            ref.read(historyProvider.notifier).clearHistory();
                            Navigator.pop(context);
                          },
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: Colors.redAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            'Clear All',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final String title;
  final String? imageUrl;
  final String dateStr;
  final bool isDark;
  final ThemeData theme;
  final VoidCallback onTap;
  final VoidCallback onDismissed;

  const _HistoryTile({
    required this.title,
    required this.imageUrl,
    required this.dateStr,
    required this.isDark,
    required this.theme,
    required this.onTap,
    required this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(title + dateStr),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismissed(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 28),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.grey.shade100,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Product Thumbnail
              Container(
                width: 56,
                height: 56,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: imageUrl != null
                    ? Image.network(
                        imageUrl!,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stack) =>
                            const Icon(Icons.broken_image_rounded, color: Colors.grey),
                      )
                    : const Icon(Icons.shopping_bag_outlined, color: Colors.grey),
              ),
              const SizedBox(width: 14),
              // Title & Timestamp
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 13,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          dateStr,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Arrow
              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.25),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
