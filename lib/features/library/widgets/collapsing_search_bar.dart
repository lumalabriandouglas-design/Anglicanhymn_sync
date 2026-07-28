import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../../../core/constants/app_colors.dart';

class CollapsingSearchBar extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final ScrollController? scrollController;

  const CollapsingSearchBar({
    super.key,
    required this.onChanged,
    this.scrollController,
  });

  @override
  State<CollapsingSearchBar> createState() => _CollapsingSearchBarState();
}

class _CollapsingSearchBarState extends State<CollapsingSearchBar> {
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    widget.scrollController?.addListener(_onScroll);
  }

  void _onScroll() {
    final controller = widget.scrollController;
    if (controller == null) return;

    if (controller.position.userScrollDirection == ScrollDirection.reverse && _isVisible) {
      setState(() => _isVisible = false);
    } else if (controller.position.userScrollDirection == ScrollDirection.forward && !_isVisible) {
      setState(() => _isVisible = true);
    }
  }

  @override
  void dispose() {
    widget.scrollController?.removeListener(_onScroll);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.fastOutSlowIn,
      height: _isVisible ? 68.0 : 0.0,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            onChanged: widget.onChanged,
            style: const TextStyle(fontSize: 14, color: AppColors.textWhite),
            decoration: InputDecoration(
              hintText: 'Search by number, title, or verse lyrics...',
              hintStyle: const TextStyle(color: AppColors.textGrey, fontSize: 13),
              prefixIcon: const Icon(Icons.search, color: AppColors.celestialGold, size: 20),
              filled: true,
              fillColor: AppColors.cardNavy,
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      ),
    );
  }
}