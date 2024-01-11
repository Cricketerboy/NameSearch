import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> leads = [];

  @override
  void initState() {
    super.initState();
    fetchLeads();
  }

  Future<void> fetchLeads() async {
    final response = await http.post(
      Uri.parse('https://api.thenotary.app/lead/getLeads'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'notaryId': '643074200605c500112e0902'}),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      setState(() {
        leads = List<Map<String, dynamic>>.from(data['leads']);
      });
    } else {
      throw Exception('Failed to fetch leads');
    }
  }

  List<Map<String, dynamic>> getFilteredLeads() {
    String searchTerm = searchController.text.toLowerCase();
    return leads
        .where((lead) =>
            lead['firstName'].toLowerCase().contains(searchTerm) ||
            lead['lastName'].toLowerCase().contains(searchTerm))
        .toList();
  }

  bool isValidUrl(String url) {
    Uri uri = Uri.parse(url);
    return uri.isAbsolute && uri.hasScheme && uri.host != null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Tutorial'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              'List view search',
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 17),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                setState(() {});
              },
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.blue,
                ),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.close, color: Colors.blue),
                        onPressed: () {
                          setState(() {
                            searchController.clear();
                          });
                        },
                      )
                    : null,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(6),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) {
                Map<String, dynamic> lead = getFilteredLeads()[index];
                return InkWell(
                  onTap: () {},
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ClipOval(
                          child: Container(
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                fit: BoxFit.fill,
                                image: isValidUrl(lead['imageURL'])
                                    ? NetworkImage(lead['imageURL'])
                                    : AssetImage(
                                            "lib/assets/images/blue world.jpg")
                                        as ImageProvider,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${lead['firstName']} ${lead['lastName']}',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 18),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Email: ${lead['email']}',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
              itemCount: getFilteredLeads().length,
            ),
          ),
        ],
      ),
    );
  }
}
