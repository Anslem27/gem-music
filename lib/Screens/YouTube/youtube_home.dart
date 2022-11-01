import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gem/CustomWidgets/search_bar.dart';
import 'package:gem/Screens/YouTube/youtube_search.dart';
import 'package:gem/Services/youtube_services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';

bool status = false;
List searchedList = Hive.box('cache').get('ytHome', defaultValue: []) as List;
List headList = Hive.box('cache').get('ytHomeHead', defaultValue: []) as List;
List topSongs = [];
bool fetched = false;
bool emptyTop = false;

class YouTube extends StatefulWidget {
  const YouTube({super.key});

  @override
  _YouTubeState createState() => _YouTubeState();
}

class _YouTubeState extends State<YouTube>
    with AutomaticKeepAliveClientMixin<YouTube> {
  final TextEditingController _controller = TextEditingController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    if (!status) {
      YouTubeServices().getMusicHome().then((value) {
        status = true;
        if (value.isNotEmpty) {
          setState(() {
            searchedList = value['body'] ?? [];
            headList = value['head'] ?? [];

            Hive.box('cache').put('ytHome', value['body']);
            Hive.box('cache').put('ytHomeHead', value['head']);
          });
        } else {
          status = false;
        }
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext cntxt) {
    super.build(context);
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool rotated = MediaQuery.of(context).size.height < screenWidth;
    double boxSize = !rotated
        ? MediaQuery.of(context).size.width / 2
        : MediaQuery.of(context).size.height / 2.5;
    if (boxSize > 250) boxSize = 250;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      body: SearchBar(
        isYt: true,
        controller: _controller,
        liveSearch: true,
        hintText: "Search Youtube",
        leading: Icon(
          CupertinoIcons.search,
          color: Theme.of(context).colorScheme.secondary,
        ),
        onQueryChanged: (_query) {
          return YouTubeServices().getSearchSuggestions(query: _query);
        },
        onSubmitted: (_query) {
          Navigator.push(
            context,
            PageRouteBuilder(
              opaque: false,
              pageBuilder: (_, __, ___) => YouTubeSearchPage(
                query: _query,
              ),
            ),
          );
          _controller.text = '';
        },
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset("assets/svg/yt_search.svg",
                  height: 140, width: 100),
              const SizedBox(height: 20),
              Text(
                "Try searching\nsome music",
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                  fontSize: 22,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
