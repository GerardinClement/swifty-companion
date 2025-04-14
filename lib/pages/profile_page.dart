import 'package:flutter/material.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:swifty_companion/services/42_api_service.dart';
import 'package:swifty_companion/services/auth_service.dart';
import 'package:swifty_companion/models/user.dart';
import 'package:swifty_companion/models/skill.dart';
import 'package:swifty_companion/models/cursus.dart';
import 'package:swifty_companion/models/project.dart';
import 'package:swifty_companion/app.dart';
import 'package:swifty_companion/widgets/skillsChartWidget.dart';

class ProfilePage extends StatefulWidget {
  final oauth2.Client client;
  final User? user;

  const ProfilePage({super.key, required this.client, this.user});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService authService = AuthService();
  late ApiService apiService;
  late bool isLoading = true;
  late User user;
  late bool isHomePage = true;
  String pageTitle = "";
  double? selectedCursusId;
  Cursus? selectedCursus;

  @override
  void initState() {
    super.initState();
    apiService = ApiService(client: widget.client);
    _fetchUserInfo();
  }

  Future<void> _fetchUserInfo() async {
    try {
      if (widget.user != null) {
        user = widget.user!;
        final projects = await apiService.fetchProjects(user);
        final cursus = await apiService.fetchUserCursus(user);
        user.projects = projects;
        user.cursusUsers = cursus;
        isHomePage = false;
      } else {
        user = await apiService.fetchUserInfo();
        isHomePage = true;
      }
      setState(() {
        isLoading = false;
        user = user;
        getDefaultCursus();
        setPageTitle();
      });
    } catch (e) {
      // Handle error
      print("Error fetching user info: $e");
    }
  }

  void setPageTitle() {
    if (isHomePage) {
      pageTitle = "Home";
    } else {
      pageTitle = user.username;
    }
  }

  void onChangedCursus(double? newValue) {
    setState(() {
      selectedCursusId = newValue;
      selectedCursus = user.cursusUsers.firstWhere(
        (cursus) => cursus.id.toDouble() == newValue,
        orElse: () => Cursus(id: 0, name: "Unknown", skills: [], level: 0),
      );
    });
  }

  void getDefaultCursus() {
    if (user.cursusUsers.isNotEmpty) {
      final cursusWithSpecificId =
          user.cursusUsers.where((c) => c.name == "42cursus").toList();
      if (cursusWithSpecificId.isNotEmpty) {
        selectedCursusId = cursusWithSpecificId.first.id.toDouble();
        selectedCursus = cursusWithSpecificId.first;
      } else {
        selectedCursusId = user.cursusUsers.first.id.toDouble();
        selectedCursus = user.cursusUsers.first;
      }
    }
  }

  List<Skill> getSelectedCursusSkills() {
    if (selectedCursusId == null) {
      return [];
    }

    for (var cursus in user.cursusUsers) {
      if (cursus.id.toDouble() == selectedCursusId) {
        return cursus.skills;
      }
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pageTitle),
        actions: [
          if (isHomePage)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await authService.clearCredentials();
                if (context.mounted) {
                  Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const App()),
                    (route) => false,
                  );
                }
              },
            ),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(user.profilePictureUrl),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Column(
                          children: [
                            Text(
                              user.username,
                              style: Theme.of(context).textTheme.headlineSmall,
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              "${user.firstName} ${user.lastName}",
                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              user.email,
                              style: Theme.of(context).textTheme.bodySmall,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: Row(
                                children: [
                                  Text(
                                    'Wallet: ${user.wallet.toStringAsFixed(2)}',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  const Spacer(),
                                  Text(
                                    'Correction Points: ${user.correction_points.toStringAsFixed(2)}',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Center(
                              child: Text(
                                user.location,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Text(
                            'Cursus: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          DropdownButton<double>(
                            value: selectedCursusId,
                            hint: const Text('Sélectionner un cursus'),
                            onChanged: (double? newValue) {
                              onChangedCursus(newValue);
                            },
                            items:
                                user.cursusUsers.map<DropdownMenuItem<double>>((
                                  Cursus value,
                                ) {
                                  return DropdownMenuItem<double>(
                                    value: value.id.toDouble(),
                                    child: Text(value.name),
                                  );
                                }).toList(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (selectedCursusId != null)
                        SkillsChart(user: user, cursus: selectedCursus!),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: const Text(
                          'Projects',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: user.projects.length,
                        itemBuilder: (context, index) {
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8.0),
                            child: ListTile(
                              title: Text(user.projects[index].name),
                              subtitle: Text(user.projects[index].status),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (user.projects[index].finalMark !=
                                      "Unknown")
                                    Text(user.projects[index].finalMark),
                                  if (user.projects[index].status ==
                                          "finished" &&
                                      user.projects[index].finalMark !=
                                          "Unknown" &&
                                      (int.tryParse(
                                                user.projects[index].finalMark,
                                              ) ??
                                              0) >=
                                          100)
                                    const SizedBox(width: 4),
                                  if (user.projects[index].isValidated)
                                    const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                      size: 16,
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
