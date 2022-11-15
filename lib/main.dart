// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.dark(),
      darkTheme: ThemeData.dark(),
      home: const MyHomePage(),
    );
  }
}

class Person {
  final String name;
  final int age;
  final String uid;
  Person({
    required this.name,
    required this.age,
    String? uid,
  }) : uid = uid ?? const Uuid().v4();

  Person updated([String? name, int? age]) =>
      Person(name: name ?? this.name, age: age ?? this.age, uid: uid);

  String get displayName => '$name ($age years old)';

  @override
  bool operator ==(covariant Person other) => uid == other.uid;

  @override
  int get hashCode => uid.hashCode;

  @override
  String toString() {
    return 'String of Person(name:$name,age:$age, uid:$uid)';
  }
}

class PersonsDataModel extends ChangeNotifier {
  final List<Person> _persons = [Person(name: 'name', age: 12, uid: 'AZZAZA')];

  UnmodifiableListView<Person> get persons => UnmodifiableListView(_persons);

  addPerson(Person person) {
    _persons.add(person);
    notifyListeners();
  }

  updatePerson(Person person) {
    print('print${person.toString()}');
    print('printS${_persons.toString()}');
    var index = _persons.indexOf(person);
    print('index$index');
    final oldPerson = _persons[index];
    if (person.name != _persons[index].name ||
        person.age != _persons[index].age) {
      _persons[index] = oldPerson.updated(person.name, person.age);
      print(_persons[index].toString());
      notifyListeners();
    }
  }
}

Future<Person?> _showMyDialog(context, [Person? person]) async {
  String? userName = person?.name;
  int? age = person?.age;
  TextEditingController userNameController =
      TextEditingController(text: userName ?? "");

  TextEditingController ageController = TextEditingController();
  ageController.text = age!=null ? age.toString() : '';

  return showDialog<Person?>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Edit Person'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              TextField(
                controller: userNameController,
                decoration: const InputDecoration(hintText: 'user name'),
                onChanged: (value) => userName = value,
              ),
              TextField(
                controller: ageController,
                decoration: const InputDecoration(hintText: 'user age'),
                onChanged: (value) => age = int.tryParse(value),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
              child: const Text('Save'),
              onPressed: () {
                if (userName != null || age != null) {
                  if (person != null) {
                    final newPerson = person.updated(
                      userName,
                      age,
                    );
                    Navigator.of(context).pop(newPerson);
                  } else {
                    Navigator.of(context).pop(Person(
                      name: userName!,
                      age: age!,
                    ));
                  }
                }
              }),
        ],
      );
    },
  );
}

// final dataModelPeoples= c
final peopleProvider = ChangeNotifierProvider(
  (_) => PersonsDataModel(),
);

class MyHomePage extends ConsumerWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(),
      body: Consumer(
        builder: (context, ref, child) {
          final listPersons = ref.watch(peopleProvider);
          return ListView.builder(
            itemCount: listPersons.persons.length,
            itemBuilder: (context, index) => InkWell(
              child:
                  ListTile(title: Text(listPersons.persons[index].displayName)),
              onTap: () async {
                final updatePerson =
                    await _showMyDialog(context, listPersons.persons[index]);
                if (updatePerson != null) {
                  listPersons.updatePerson(updatePerson);
                }
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final person = await _showMyDialog(context);
          if (person != null) {
            final dataModel = ref.read(peopleProvider).addPerson(person);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
