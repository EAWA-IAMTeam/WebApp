import 'package:flutter/material.dart';
import 'package:kclogin/home/controllers/create_user_viewmodel';
import 'package:provider/provider.dart';

class CreateUserPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CreateUserViewModel(),
      child: Consumer<CreateUserViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(title: Text("Create User")),
            body: Padding(
              padding: EdgeInsets.fromLTRB(64, 32, 64, 32),
              child: Column(
                children: [
                  Form(
                    child: Column(
                      children: [
                        TextFormField(
                          controller: viewModel.firstNameController,
                          decoration: InputDecoration(labelText: "First Name"),
                        ),
                        TextFormField(
                          controller: viewModel.lastNameController,
                          decoration: InputDecoration(labelText: "Last Name"),
                        ),
                        TextFormField(
                          controller: viewModel.emailController,
                          decoration: InputDecoration(labelText: "Email"),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Text("Add Store Permission"),
                  ElevatedButton(
                    onPressed: () {
                      _showAddStoreDialog(context, viewModel);
                    },
                    child: Text("Add Permission"),
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: viewModel.storeList.length,
                      itemBuilder: (context, index) {
                        final store = viewModel.storeList[index];
                        return ListTile(
                          title: Text("${store['store_name']} - ${store['store_role']}"),
                          subtitle: Text(
                              "ID: ${store['store_id']} | Permissions: ${store['store_permission']}"),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: viewModel.isFormValid()
                        ? () => viewModel.createUser(context)
                        : null,
                    child: Text("Create User"),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAddStoreDialog(BuildContext context, CreateUserViewModel viewModel) {
    TextEditingController storeIdController = TextEditingController();
    TextEditingController storeNameController = TextEditingController();
    TextEditingController storeRoleController = TextEditingController();
    TextEditingController storePermissionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add Store Permission"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: storeIdController, decoration: InputDecoration(labelText: "Store ID")),
            TextField(controller: storeNameController, decoration: InputDecoration(labelText: "Store Name")),
            TextField(controller: storeRoleController, decoration: InputDecoration(labelText: "Role")),
            TextField(controller: storePermissionController, decoration: InputDecoration(labelText: "Permissions")),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (storeIdController.text.isNotEmpty &&
                  storeNameController.text.isNotEmpty &&
                  storeRoleController.text.isNotEmpty &&
                  storePermissionController.text.isNotEmpty) {
                viewModel.addStore(
                  storeIdController.text,
                  storeNameController.text,
                  storeRoleController.text,
                  storePermissionController.text,
                );
                Navigator.pop(context);
              }
            },
            child: Text("Add"),
          ),
        ],
      ),
    );
  }
}
