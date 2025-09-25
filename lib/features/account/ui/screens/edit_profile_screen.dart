import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'package:bookapp_customer/app/app_colors.dart';
import 'package:bookapp_customer/app/assets_path.dart';
import 'package:bookapp_customer/features/common/ui/widgets/custom_app_bar.dart';
import 'package:bookapp_customer/features/common/ui/widgets/custom_cpi.dart';
import 'package:bookapp_customer/features/common/ui/widgets/custom_snack_bar_widget.dart';
import 'package:bookapp_customer/features/common/ui/widgets/form_header_text_widget.dart';
import 'package:bookapp_customer/features/auth/providers/auth_provider.dart';

import '../../providers/profile_provider.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ProfileProvider>(
        builder: (context, prov, _) {
          if (prov.isFetching) {
            return const Center(child: CustomCPI());
          }

          return Column(
            children: [
              CustomAppBar(title: 'Edit Profile'),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      _ProfileImage(),
                      const SizedBox(height: 32),
                      _Field(
                        header: 'Username',
                        hint: 'Enter user name',
                        keyName: 'username',
                      ),
                      _Field(
                        header: 'Name',
                        hint: 'Enter your name',
                        keyName: 'name',
                      ),
                      _Field(
                        header: 'Email',
                        hint: 'Enter email address',
                        keyName: 'email',
                      ),
                      _Field(
                        header: 'Phone',
                        hint: 'Enter phone number',
                        keyName: 'phone',
                      ),
                      _Field(
                        header: 'State',
                        hint: 'Enter your state',
                        keyName: 'state',
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: _Field(
                              header: 'Postcode/Zip',
                              hint: 'Enter Zip/post code',
                              keyName: 'zip',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _Field(
                              header: 'Country',
                              hint: 'Enter your country',
                              keyName: 'country',
                            ),
                          ),
                        ],
                      ),
                      _Field(
                        header: 'Address',
                        hint: 'Enter your address',
                        keyName: 'address',
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: prov.isLoading
                              ? null
                              : () async {
                                  final ok = await prov.updateProfile();
                                  if (!context.mounted) return;

                                  await context
                                      .read<AuthProvider>()
                                      .refreshDashboard();
                                  if (!context.mounted) return;
                                  context
                                      .read<AuthProvider>()
                                      .bumpAvatarVersion();

                                  CustomSnackBar.show(
                                    context,
                                    prov.lastMessage ??
                                        (ok
                                            ? 'Your profile has been updated successfully'
                                                  .tr
                                            : 'Failed to update profile!'.tr),
                                    icon: ok
                                        ? Icons.check
                                        : Icons.error_outline,
                                    iconBgColor: ok
                                        ? AppColors.snackSuccess
                                        : AppColors.snackError,
                                  );

                                  if (ok) Navigator.pop(context, true);
                                },
                          child: Text('Update Profile'.tr),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProfileImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ProfileProvider>();
    final imageFile = prov.imageFile;
    final network = prov.profileImageUrl;

    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: imageFile != null
                ? FileImage(imageFile)
                : (network != null && network.isNotEmpty
                      ? NetworkImage(network)
                      : const AssetImage(AssetsPath.userPlaceholderPng)
                            as ImageProvider),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: prov.pickImage,
              child: CircleAvatar(
                backgroundColor: Colors.grey.shade100,
                child: const Icon(
                  Icons.camera_alt_outlined,
                  color: AppColors.colorText,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String header;
  final String hint;
  final String keyName;
  const _Field({
    required this.header,
    required this.hint,
    required this.keyName,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.read<ProfileProvider>().controllers[keyName]!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormHeaderTextWidget(text: header),
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 16),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: AppColors.colorText),
            ),
          ),
        ),
      ],
    );
  }
}
