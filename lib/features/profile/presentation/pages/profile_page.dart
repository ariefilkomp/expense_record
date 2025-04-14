import 'package:cached_network_image/cached_network_image.dart';
import 'package:expense_record/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:expense_record/features/auth/presentation/cubits/auth_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: BlocConsumer<AuthCubit, AuthStates>(
          builder: (context, state) {
            final authCubit = context.read<AuthCubit>();
            final user = authCubit.currentUser;
            return user?.isAnonymous == true
                ? Center(
                  child: Column(
                    children: [
                      Text('Anonymous'),
                      SizedBox(height: 20),
                      Text(
                        'Kamu masuk dengan akun anonim, tautkan dengan akun google agar datamu tidak hilang!',
                      ),
                      SizedBox(height: 20),
                      GestureDetector(
                        onTap: authCubit.linkAnonymousWithGoogle,
                        child: Container(
                          padding: const EdgeInsets.all(25),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/google-icon.png',
                                  width: 30,
                                  height: 30,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Tautkan dengan Akun Google',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                : Center(
                  child: Column(
                    children: [
                      user?.photoUrl != null && user!.photoUrl.isNotEmpty
                          ? CachedNetworkImage(
                            imageUrl: user.photoUrl,
                            fit: BoxFit.cover,
                            placeholder:
                                (context, url) =>
                                    const CircularProgressIndicator(),
                            errorWidget:
                                (context, url, error) =>
                                    const Icon(Icons.person),
                            imageBuilder:
                                (context, imageProvider) => Container(
                                  height: 80,
                                  width: 80,
                                  clipBehavior: Clip.hardEdge,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                  ),
                                  child: Image(
                                    image: imageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                          )
                          : Icon(
                            Icons.person,
                            size: 80,
                            color: Theme.of(context).colorScheme.primary,
                          ),

                      SizedBox(height: 20),

                      Text(
                        user?.name ?? '',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text(
                        user?.email ?? '',
                        style: TextStyle(fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                );
          },
          listener: (context, state) {},
        ),
      ),
    );
  }
}
