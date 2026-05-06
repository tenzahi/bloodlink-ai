import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_state.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import 'main_shell.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() =>
      _SearchScreenState();
}

class _SearchScreenState
    extends State<SearchScreen> {

  final UserService _userService =
  UserService();

  String _selectedBloodType = 'A+';

  String get _lang =>
      langNotifier.value;

  String t(String key) =>
      appTexts[_lang]?[key] ?? key;

  final List<String> bloodTypes = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-'
  ];

  @override
  Widget build(BuildContext context) {

    final isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    return Scaffold(
      body: Column(
        children: [

          // HEADER
          Container(
            color: isDark
                ? const Color(0xFF1E1E1E)
                : Colors.white,

            padding:
            const EdgeInsets.fromLTRB(
              16,
              16,
              16,
              12,
            ),

            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [

                Text(
                  t('trouver_donneur'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  t('selectionner_groupe'),
                  style: TextStyle(
                    color:
                    Colors.grey.shade500,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 12),

                SingleChildScrollView(
                  scrollDirection:
                  Axis.horizontal,

                  child: Row(
                    children:
                    bloodTypes.map((bt) {

                      final selected =
                          _selectedBloodType ==
                              bt;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedBloodType =
                                bt;
                          });
                        },

                        child:
                        AnimatedContainer(
                          duration:
                          const Duration(
                            milliseconds: 200,
                          ),

                          margin:
                          const EdgeInsets.only(
                            right: 8,
                          ),

                          padding:
                          const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 9,
                          ),

                          decoration:
                          BoxDecoration(
                            color: selected
                                ? Colors.red
                                .shade700
                                : (isDark
                                ? const Color(
                                0xFF2A2A2A)
                                : Colors.grey
                                .shade100),

                            borderRadius:
                            BorderRadius.circular(
                                22),
                          ),

                          child: Text(
                            bt,
                            style:
                            TextStyle(
                              color: selected
                                  ? Colors
                                  .white
                                  : Colors.grey
                                  .shade600,

                              fontWeight:
                              FontWeight
                                  .w600,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          Divider(
            height: 1,
            color: Colors.grey.shade200,
          ),

          // LISTE
          Expanded(
            child:
            StreamBuilder<List<UserModel>>(
              stream: _userService
                  .searchDonors(
                _selectedBloodType,
              ),

              builder:
                  (context, snapshot) {

                if (snapshot.connectionState ==
                    ConnectionState.waiting) {

                  return const Center(
                    child:
                    CircularProgressIndicator(
                      color: Colors.red,
                    ),
                  );
                }

                if (!snapshot.hasData ||
                    snapshot.data!.isEmpty) {

                  return Center(
                    child: Column(
                      mainAxisAlignment:
                      MainAxisAlignment
                          .center,

                      children: [

                        Icon(
                          Icons
                              .bloodtype_outlined,
                          size: 64,
                          color: Colors
                              .grey.shade300,
                        ),

                        const SizedBox(
                            height: 12),

                        Text(
                          '${t('aucun_donneur')} $_selectedBloodType',

                          style: TextStyle(
                            color: Colors
                                .grey.shade500,

                            fontSize: 15,

                            fontWeight:
                            FontWeight
                                .w500,
                          ),
                        ),

                        const SizedBox(
                            height: 6),

                        Text(
                          t('essayer_autre'),

                          style: TextStyle(
                            color: Colors
                                .grey.shade400,

                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final donors =
                snapshot.data!;

                return ListView.builder(
                  padding:
                  const EdgeInsets.all(
                      16),

                  itemCount:
                  donors.length,

                  itemBuilder:
                      (_, i) =>
                      _DonorCard(
                        donor: donors[i],
                        t: t,
                      ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DonorCard extends StatelessWidget {

  final UserModel donor;

  final Function(String) t;

  const _DonorCard({
    required this.donor,
    required this.t,
  });

  Future<void> _openWhatsApp(
      BuildContext context) async {

    final phone = donor.phone.replaceAll(
      RegExp(r'[^\d+]'),
      '',
    );

    if (phone.isEmpty) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          content: Text(
            t('pas_whatsapp'),
          ),

          backgroundColor:
          Colors.orange,
        ),
      );

      return;
    }

    final url =
    Uri.parse('https://wa.me/$phone');

    if (await canLaunchUrl(url)) {
      await launchUrl(
        url,
        mode:
        LaunchMode.externalApplication,
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    final isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    return Container(
      margin:
      const EdgeInsets.only(bottom: 14),

      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E1E1E)
            : Colors.white,

        borderRadius:
        BorderRadius.circular(20),
      ),

      child: Padding(
        padding:
        const EdgeInsets.all(16),

        child: Column(
          children: [

            Row(
              children: [

                // AVATAR
                Container(
                  width: 52,
                  height: 52,

                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.red.shade300,
                        Colors.red.shade600,
                      ],
                    ),

                    shape: BoxShape.circle,
                  ),

                  child: Center(
                    child: Text(
                      donor.name.isNotEmpty
                          ? donor.name[0]
                          .toUpperCase()
                          : '?',

                      style:
                      const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                    children: [

                      Text(
                        donor.name,

                        style:
                        const TextStyle(
                          fontSize: 16,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                          height: 6),

                      Row(
                        children: [

                          // GROUPE
                          Container(
                            padding:
                            const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),

                            decoration:
                            BoxDecoration(
                              color: Colors
                                  .red.shade50,

                              borderRadius:
                              BorderRadius.circular(
                                  10),
                            ),

                            child: Text(
                              donor.bloodType,

                              style:
                              TextStyle(
                                color: Colors
                                    .red
                                    .shade700,

                                fontWeight:
                                FontWeight
                                    .bold,

                                fontSize:
                                12,
                              ),
                            ),
                          ),

                          const SizedBox(
                              width: 8),

                          Row(
                            children: [

                              Container(
                                width: 7,
                                height: 7,

                                decoration:
                                const BoxDecoration(
                                  color:
                                  Colors.green,

                                  shape:
                                  BoxShape.circle,
                                ),
                              ),

                              const SizedBox(
                                  width: 4),

                              Text(
                                t(
                                    'disponible'),

                                style:
                                TextStyle(
                                  color: Colors
                                      .green
                                      .shade700,

                                  fontSize:
                                  12,

                                  fontWeight:
                                  FontWeight
                                      .w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // EMAIL
            Row(
              children: [

                Icon(
                  Icons.email_outlined,
                  size: 15,
                  color:
                  Colors.grey.shade400,
                ),

                const SizedBox(width: 8),

                Text(
                  donor.email,

                  style: TextStyle(
                    color:
                    Colors.grey.shade600,

                    fontSize: 13,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // WHATSAPP
            SizedBox(
              width: double.infinity,

              child: ElevatedButton.icon(
                onPressed: () =>
                    _openWhatsApp(context),

                icon: const Icon(
                  Icons.chat,
                  size: 18,
                ),

                label: Text(
                  t('contacter_whatsapp'),
                ),

                style:
                ElevatedButton.styleFrom(
                  backgroundColor:
                  const Color(
                      0xFF25D366),

                  foregroundColor:
                  Colors.white,

                  padding:
                  const EdgeInsets.symmetric(
                    vertical: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}