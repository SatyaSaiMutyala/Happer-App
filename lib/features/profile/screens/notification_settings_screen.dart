import 'package:flutter/material.dart';
import 'package:happer_app/shared/widgets/happer_app_bar.dart';
import 'package:happer_app/l10n/app_localizations.dart';
import 'package:happer_app/shared/models/notification_settings.dart';
import 'package:happer_app/features/profile/api/profile_api.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({Key? key}) : super(key: key);

  @override
  _NotificationSettingsScreenState createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  final ProfileApiService _apiService = ProfileApiService();
  NotificationSettings _settings = NotificationSettings();
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    try {
      final settingsData = await _apiService.fetchNotificationSettings();
      setState(() {
        _settings = NotificationSettings.fromJson(settingsData);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load notification settings: $e')),
      );
    }
  }

  Future<void> _updateServerSettings() async {
    setState(() => _isSaving = true);
    try {
      await _apiService.updateNotificationSettings(
        wishlist: _settings.wishlistNotifications,
        credits: _settings.creditsNotifications,
        push: _settings.pushNotifications,
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update: $e')));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Widget _buildSettingTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
        value: value,
        onChanged: (newValue) async {
          onChanged(newValue); // update local model
          await _updateServerSettings(); // instantly sync to API
        },
        activeColor: Colors.black,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: HapperAppBar(
        title: localizations.notificationSettings,
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                ),
              ),
            ),
        ],
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        localizations.notificationSettings,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    _buildSettingTile(
                      title: localizations.wishlistNotifications,
                      subtitle: localizations.wishlistNotificationsDesc,
                      value: _settings.wishlistNotifications,
                      onChanged: (value) {
                        setState(() {
                          _settings.wishlistNotifications = value;
                        });
                      },
                    ),
                    SizedBox(height: 8),
                    _buildSettingTile(
                      title: localizations.creditsNotifications,
                      subtitle: localizations.creditsNotificationsDesc,
                      value: _settings.creditsNotifications,
                      onChanged: (value) {
                        setState(() {
                          _settings.creditsNotifications = value;
                        });
                      },
                    ),
                    SizedBox(height: 8),
                    _buildSettingTile(
                      title: localizations.pushNotifications,
                      subtitle: localizations.pushNotificationsDesc,
                      value: _settings.pushNotifications,
                      onChanged: (value) {
                        setState(() {
                          _settings.pushNotifications = value;
                        });
                      },
                    ),
                    SizedBox(height: 40),
                  ],
                ),
              ),
    );
  }
}
