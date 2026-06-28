import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:happer_app/features/creator/bindings/creator_binding.dart';
import 'package:happer_app/features/creator/data/models/suggestion_model.dart';
import 'package:happer_app/features/creator/data/repositories/creator_repository.dart';
import 'package:shimmer/shimmer.dart';

/// A service class to handle search functionality across the app
class SearchService {
  /// Shows a search overlay with live autocomplete suggestions (creators and
  /// brands) backed by GET /user/selfies/get-suggestions.
  ///
  /// - [onSearch] is called when the user submits free text (Enter).
  /// - [onSelectSuggestion] is called when the user taps a suggestion row.
  static void showSearchOverlay(
    BuildContext context, {
    Function(String)? onSearch,
    Function(SuggestionModel)? onSelectSuggestion,
  }) {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return Material(
          type: MaterialType.transparency,
          child: Stack(
            children: [
              // Semi-transparent background
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.5),
                  ),
                ),
              ),

              // Search popup at the top
              Positioned(
                top: 40.0,
                left: 0,
                right: 0,
                child: _SearchOverlayContent(
                  onSearch: onSearch,
                  onSelectSuggestion: onSelectSuggestion,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SearchOverlayContent extends StatefulWidget {
  final Function(String)? onSearch;
  final Function(SuggestionModel)? onSelectSuggestion;

  const _SearchOverlayContent({this.onSearch, this.onSelectSuggestion});

  @override
  State<_SearchOverlayContent> createState() => _SearchOverlayContentState();
}

class _SearchOverlayContentState extends State<_SearchOverlayContent> {
  final TextEditingController _textController = TextEditingController();
  Timer? _debounce;
  late final CreatorRepository _repo;

  List<SuggestionModel> _suggestions = [];
  bool _isLoading = false;
  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<CreatorRepository>()) {
      CreatorBinding().dependencies();
    }
    _repo = Get.find<CreatorRepository>();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _textController.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    final query = value.trim();
    if (query.isEmpty) {
      setState(() {
        _suggestions = [];
        _isLoading = false;
      });
      return;
    }
    setState(() => _isLoading = true);
    _debounce = Timer(const Duration(milliseconds: 350), () => _fetch(query));
  }

  Future<void> _fetch(String query) async {
    final reqId = ++_requestId;
    try {
      final results = await _repo.getSuggestions(query);
      // Ignore out-of-order responses from earlier keystrokes.
      if (!mounted || reqId != _requestId) return;
      setState(() {
        _suggestions = results;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted || reqId != _requestId) return;
      setState(() {
        _suggestions = [];
        _isLoading = false;
      });
    }
  }

  void _submit(String query) {
    Navigator.pop(context);
    if (widget.onSearch != null) widget.onSearch!(query);
  }

  void _selectSuggestion(SuggestionModel item) {
    Navigator.pop(context);
    if (widget.onSelectSuggestion != null) widget.onSelectSuggestion!(item);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Search field
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            child: TextField(
              controller: _textController,
              autofocus: true,
              onChanged: _onChanged,
              decoration: const InputDecoration(
                hintText: 'Filtrer par créateur...',
                prefixIcon: Icon(Icons.search),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
              onSubmitted: _submit,
            ),
          ),
        ),

        // Suggestions panel
        if (_isLoading || _suggestions.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.5,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: _isLoading
                  ? _buildShimmerList()
                  : ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _suggestions.length,
                      separatorBuilder: (_, __) =>
                          Divider(height: 1, color: Colors.grey.shade200),
                      itemBuilder: (context, index) =>
                          _buildSuggestionRow(_suggestions[index]),
                    ),
            ),
          ),
      ],
    );
  }

  Widget _buildShimmerList() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: 6,
        separatorBuilder: (_, __) =>
            Divider(height: 1, color: Colors.grey.shade200),
        itemBuilder: (_, __) => ListTile(
          leading: Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          title: Container(
            height: 12,
            width: double.infinity,
            margin: const EdgeInsets.only(right: 60),
            color: Colors.white,
          ),
          subtitle: Container(
            height: 10,
            width: 100,
            margin: const EdgeInsets.only(top: 6),
            color: Colors.white,
          ),
          trailing: Container(
            width: 56,
            height: 18,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionRow(SuggestionModel item) {
    return ListTile(
      onTap: () => _selectSuggestion(item),
      leading: _buildAvatar(item),
      title: Text(
        item.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontFamily: 'Lato', fontWeight: FontWeight.w600),
      ),
      subtitle: item.subtitle != null
          ? Text(
              item.subtitle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontFamily: 'Lato', color: Colors.grey.shade600),
            )
          : null,
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          item.isBrand ? 'Marque' : 'Créateur',
          style: TextStyle(
            fontFamily: 'Lato',
            fontSize: 11,
            color: Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(SuggestionModel item) {
    final url = item.imageUrl;
    final shape = item.isBrand ? BoxShape.rectangle : BoxShape.circle;
    final radius = item.isBrand ? BorderRadius.circular(6) : null;
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        shape: shape,
        borderRadius: radius,
      ),
      clipBehavior: Clip.antiAlias,
      child: (url != null && url.isNotEmpty)
          ? CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => _avatarFallback(item),
            )
          : _avatarFallback(item),
    );
  }

  Widget _avatarFallback(SuggestionModel item) => Icon(
        item.isBrand ? Icons.storefront : Icons.person,
        color: Colors.grey.shade500,
        size: 22,
      );
}
