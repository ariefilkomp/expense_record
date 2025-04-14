import 'package:cached_network_image/cached_network_image.dart';
import 'package:expense_record/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:expense_record/features/home/presentation/components/my_drawer_title.dart';
import 'package:expense_record/features/profile/presentation/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authCubit = context.read<AuthCubit>();
    final user = authCubit.currentUser;
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 50.0),
          child: Column(
            children: [
              SizedBox(height: 50),

              user?.photoUrl != null && user!.photoUrl.isNotEmpty
                  ? CachedNetworkImage(
                    imageUrl: user.photoUrl,
                    fit: BoxFit.cover,
                    placeholder:
                        (context, url) => const CircularProgressIndicator(),
                    errorWidget:
                        (context, url, error) => const Icon(Icons.person),
                    imageBuilder:
                        (context, imageProvider) => Container(
                          height: 80,
                          width: 80,
                          clipBehavior: Clip.hardEdge,
                          decoration: BoxDecoration(shape: BoxShape.circle),
                          child: Image(image: imageProvider, fit: BoxFit.cover),
                        ),
                  )
                  : Icon(
                    Icons.person,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),

              // home title
              MyDrawerTitle(
                title: 'H O M E',
                icon: Icons.home,
                onTap: () => Navigator.of(context).pop(),
              ),

              //profile title
              MyDrawerTitle(
                title: 'P R O F I L E',
                icon: Icons.person,
                onTap: () {
                  // close drawer
                  Navigator.of(context).pop();

                  // navigate to profile page
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfilePage()),
                  );
                },
              ),

              const Spacer(),

              //logout title
              MyDrawerTitle(
                title: 'L O G O U T',
                icon: Icons.logout,
                onTap: () {
                  authCubit.logOut();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
