import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:wallpaper_demo/service/api_service.dart';
import 'package:wallpaper_demo/service/firebase_file.dart';

import 'fullscreen.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late Future<List<FirebaseFile>> futureFiles;

  @override
  void initState() {
    super.initState();
    futureFiles = FirebaseApi.listAll('files/');
  }
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          actions: [
            TextButton(
              onPressed: refreshCache,
              style: TextButton.styleFrom(primary: Colors.white),
              child: Text('Refresh'),
            ),
          ],
          title: Text('hello'),
          centerTitle: true,
        ),
        body: FutureBuilder<List<FirebaseFile>>(
          future: futureFiles,
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return Center(child: CircularProgressIndicator());
              default:
                if (snapshot.hasError) {
                  return Center(child: Text('Some error occurred!'));
                } else {
                  final files = snapshot.data!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildHeader(files.length),
                      Expanded(
                        child: StaggeredGridView.countBuilder(
                          itemCount: files.length,
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          itemBuilder: (context, index) {
                            final file = files[index];
                            return buildFile(context, file);
                          },
                          staggeredTileBuilder: (int index) {
                            return new StaggeredTile.count(
                                1, index.isEven ? 1.8 : 2.2);
                          },
                        ),
                      ),
                    ],
                  );
                }
            }
          },
        ),
      );

  Widget buildFile(BuildContext context, FirebaseFile file) =>
      Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        child: InkWell(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ImagePage(file: file),
          )),
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            child: CachedNetworkImage(
              key: UniqueKey(),
              imageUrl: file.url,
              fit: BoxFit.cover,
              placeholder: (context, url) => Image.asset('assets/images/placeholder_bp.png'),
              errorWidget: (context, url, error) => Icon(Icons.error_outline,color: Colors.red,),
            )
          ),
        ),
      );

  Widget buildHeader(int length) => ListTile(
        tileColor: Colors.blue,
        leading: Container(
          width: 52,
          height: 52,
          child: Icon(
            Icons.file_copy,
            color: Colors.white,
          ),
        ),
        title: Text(
          '$length Files',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      );
  void refreshCache(){
    imageCache!.clear();
    imageCache!.clearLiveImages();
    setState(() {

    });
  }
}
