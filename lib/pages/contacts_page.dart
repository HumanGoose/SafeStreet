import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:safestreet/pages/intro.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart'; // Import vibration package

class ContactsPage extends StatefulWidget {
  @override
  _ContactsPageState createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  List<Contact> _contacts = [];
  List<Contact> _selectedContacts = [];

  @override
  void initState() {
    super.initState();
    _getContactsPermission();
    _loadSelectedContacts();
  }

  Future<void> _getContactsPermission() async {
    PermissionStatus permission = await Permission.contacts.status;
    if (permission != PermissionStatus.granted) {
      permission = await Permission.contacts.request();
    }
    if (permission == PermissionStatus.granted) {
      _loadContacts();
    }
  }

  Future<void> _loadContacts() async {
    List<Contact> contacts = (await ContactsService.getContacts()).toList();
    setState(() {
      _contacts = contacts;
    });
  }

  Future<void> _loadSelectedContacts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? storedContacts = prefs.getStringList('selectedContacts');
    if (storedContacts != null) {
      setState(() {
        _selectedContacts = storedContacts.map((contactJson) {
          Map<String, dynamic> contactMap = jsonDecode(contactJson);
          if (contactMap['avatar'] is List<dynamic>) {
            contactMap['avatar'] = Uint8List.fromList(
                List<int>.from(contactMap['avatar'] as List<dynamic>));
          }
          return Contact.fromMap(contactMap);
        }).toList();
      });
    }
    _loadContacts();
  }

  Future<void> _saveSelectedContacts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> storedContacts = _selectedContacts.map((contact) {
      Map contactMap = contact.toMap();
      if (contactMap['avatar'] != null) {
        contactMap['avatar'] = (contactMap['avatar'] as Uint8List).toList();
      }
      return jsonEncode(contactMap);
    }).toList();
    prefs.setStringList('selectedContacts', storedContacts);
  }

  void _pickContact() async {
    if (_selectedContacts.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You can only add up to 5 contacts.')),
      );
      return;
    }
    Contact? contact = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return _ContactPickerDialog(
          contacts: _contacts,
          selectedContacts: _selectedContacts,
        );
      },
    );
    if (contact != null && !_isDuplicate(contact)) {
      setState(() {
        _selectedContacts.add(contact);
      });
      _saveSelectedContacts(); // Save contacts without vibration
      _loadContacts(); // Refresh the available contacts list
    } else if (contact != null) {
      _showDuplicateContactDialog();
    }
  }

  bool _isDuplicate(Contact contact) {
    for (var selectedContact in _selectedContacts) {
      if (selectedContact.displayName == contact.displayName) {
        for (var selectedPhone in selectedContact.phones ?? []) {
          for (var phone in contact.phones ?? []) {
            if (selectedPhone.value == phone.value) {
              return true;
            }
          }
        }
      }
    }
    return false;
  }

  void _showDuplicateContactDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Duplicate Contact'),
          content: Text('This contact is already added.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteContact(Contact contact) async {
    setState(() {
      _selectedContacts.remove(contact);
    });
    _saveSelectedContacts(); // Save contacts without vibration
    _loadContacts(); // Refresh the available contacts list

    // Vibrate for a short duration (100 milliseconds) when deleting contact
    bool hasVibrator =
        await Vibration.hasVibrator() ?? false; // Default to false if null
    if (hasVibrator) {
      Vibration.vibrate(duration: 100);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.all(16.0),
      color: yelloww,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, // Center align content
          children: [
            Center(
              child: Text(
                'Select up to 5 contacts to whom your location would be sent in times of emergency:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center, // Optionally, center align text
              ),
            ),
            SizedBox(height: 20),
            ..._selectedContacts.map((contact) {
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                color: brownn,
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.0), // Adjust horizontal padding
                  title: Text(
                    contact.displayName ?? '',
                    style: TextStyle(color: yelloww),
                  ),
                  trailing: IconButton(
                    padding:
                        EdgeInsets.zero, // Remove padding around IconButton
                    icon: Icon(Icons.delete,
                        color: Color.fromARGB(255, 180, 27, 16)),
                    onPressed: () {
                      _deleteContact(contact);
                    },
                  ),
                ),
              );
            }).toList(),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _pickContact,
                style: ElevatedButton.styleFrom(
                  padding:
                      EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                  backgroundColor: Color.fromARGB(255, 36, 17, 5),
                  foregroundColor: Colors.white,
                  textStyle: TextStyle(fontSize: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text('Add Contact'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactPickerDialog extends StatefulWidget {
  final List<Contact> contacts;
  final List<Contact> selectedContacts;

  _ContactPickerDialog(
      {required this.contacts, required this.selectedContacts});

  @override
  __ContactPickerDialogState createState() => __ContactPickerDialogState();
}

class __ContactPickerDialogState extends State<_ContactPickerDialog> {
  TextEditingController _searchController = TextEditingController();
  List<Contact> _filteredContacts = [];

  @override
  void initState() {
    super.initState();
    _filteredContacts = widget.contacts
        .where((contact) => !widget.selectedContacts.contains(contact))
        .toList();
    _searchController.addListener(_filterContacts);
  }

  void _filterContacts() {
    setState(() {
      _filteredContacts = widget.contacts
          .where((contact) =>
              contact.displayName!
                  .toLowerCase()
                  .contains(_searchController.text.toLowerCase()) &&
              !widget.selectedContacts.contains(contact))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Column(
        children: [
          Text('Select a contact'),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search contacts',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
        ],
      ),
      children: _filteredContacts.map((contact) {
        return SimpleDialogOption(
          child: Text(contact.displayName ?? ''),
          onPressed: () {
            Navigator.pop(context, contact);
          },
        );
      }).toList(),
    );
  }
}
