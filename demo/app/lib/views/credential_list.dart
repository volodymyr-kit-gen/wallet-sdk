import 'package:app/services/storage_service.dart';
import 'package:app/widgets/credential_card.dart';
import 'package:flutter/material.dart';
import 'package:app/models/store_credential_data.dart';

class CredentialList extends StatefulWidget {
  final String title;
  final String user;
  const CredentialList({Key? key, required this.title, required this.user}) : super(key: key);

  @override
  State<CredentialList> createState() => _CredentialListState();
}

class _CredentialListState extends State<CredentialList> {
  final StorageService _storageService = StorageService();
  late List<StorageItem> _credentialList;
  bool _loading = true;
  static String userIDLoggedIn = '';
  @override
  void initState() {
    super.initState();
    userIDLoggedIn = widget.user;
    initList(userIDLoggedIn);
  }

  void initList(String userIDLoggedIn) async {
    var username = await _storageService.retrieve("username");
      _credentialList = await _storageService.retrieveAll();
    var credentialResultFound = _credentialList.where((credential) => credential.key.contains(username!));
    if (credentialResultFound.isEmpty) {
      _loading = true;
      _credentialList.clear();
    }
    _credentialList = credentialResultFound.toList();
    _loading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : _credentialList.isEmpty
            ? const Text("Add data in secure storage to display here.")
            : ListView.builder(
            itemCount: _credentialList.length,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemBuilder: (_, index) {
              return Dismissible(
                key: Key(_credentialList[index].toString()),
                child: CredentialCard(item: _credentialList[index]),
                onDismissed: (direction) async {
                  await _storageService.deleteData(_credentialList[index]!)
                      .then((value) => _credentialList.removeAt(index));
                  initList(widget.user);
                },
              );
            }),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}