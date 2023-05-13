import 'dart:convert';
import 'package:first_test/views/results.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Vote extends StatefulWidget {
  final int id;
  const Vote({Key? key, required this.id}) : super(key: key);

  @override
  State<Vote> createState() => _VoteState();
}

class _VoteState extends State<Vote> {
  late final Future<Map<String, dynamic>> response;
  int currentIndex = 0;

  Future<Map<String, dynamic>> get(int id) async {
    var url = Uri.https('koeg.000webhostapp.com', 'sop/api.php/get',
        {"id": widget.id.toString()});
    var response = await http.get(url);

    return jsonDecode(response.body);
  }

  void vote(int id, bool isyes, List response) async {
    if (currentIndex < response.length) {
      setState(() {
        currentIndex++;
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Results(),
        ),
      );
    }
  }

  @override
  void initState() {
    response = get(widget.id);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder<Map<String, dynamic>>(
        future: response,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final success = snapshot.data!['success'];
            final images = snapshot.data!['images'];
            final name = snapshot.data!['name'];
            final id = widget.id;

            return Center(
              child: Column(
                children: [
                  Text('Name: $name'),
                  SizedBox.expand(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Image(
                        image: NetworkImage(
                            'http://koeg.000webhostapp.com/sop/images/$id/${images[currentIndex]['file_Name']}'),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          int? expecdtByts = loadingProgress.expectedTotalBytes;
                          int? currentByts =
                              loadingProgress.cumulativeBytesLoaded;
                          if (expecdtByts != null) {
                            var loadingProcent = currentByts / expecdtByts;
                            return Center(
                              child: SizedBox(
                                width: 300,
                                child: LinearProgressIndicator(
                                    value: loadingProcent),
                              ),
                            );
                          } else {
                            return child;
                          }
                          // You can use LinearProgressIndicator or CircularProgressIndicator instead
                        },
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      TextButton(
                          onPressed: () {
                            vote(10, true, images);
                          },
                          child: const Text("yes"))
                    ],
                  ),
                  Text(images[currentIndex]['id'].toString()),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
