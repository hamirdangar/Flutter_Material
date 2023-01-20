//@dart=2.9
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../sign_in_up_page/Sign_In_Page.dart';


class SidMenu extends StatefulWidget {
  @override
  State<SidMenu> createState() => _SidMenuState();
}

class _SidMenuState extends State<SidMenu>
{
  SharedPreferences logindata;
  String username;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initial();
  }
  //get
  void initial() async {
    logindata = await SharedPreferences.getInstance();
    setState(()
    {
      username = logindata.getString('username');
    });
  }
  @override
  Widget build(BuildContext context) {
       return Drawer(
        child: ListView(
          padding: EdgeInsets.zero,

          children: [
            UserAccountsDrawerHeader(
              accountName: Text('welcome to $username'),
              accountEmail: Text('dangarhamir3333@gmail.com'),
              currentAccountPicture: CircleAvatar(
                child: ClipOval(
                  child: Image.network('https://png.pngtree.com/png-clipart/20190115/ourmid/pngtree-chibi-boy-with-glasses-png-image_318105.jpg',
                    width: 90,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              decoration: BoxDecoration(
                color: Colors.greenAccent,
                 /* image: DecorationImage(
                      image: NetworkImage(
                        'https://images.all-free-download.com/images/graphiclarge/blue_textile_background_8_211913.jpg',
                      ),
                      fit: BoxFit.cover
                  )*/
              ),
            ),
            ListTile(
              leading: Icon(Icons.favorite),
              title: Text('Favorite'),
              onTap:()=>null,
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('settings'),
              onTap:()=>null,
            ),
            ListTile(
              leading: Icon(Icons.call),
              title: Text('call'),
              onTap:()=>null,
            ),
            ListTile(
              leading: Icon(Icons.cleaning_services),
              title: Text('sevirces'),
              onTap:()=>null,
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('logout'),
              onTap: ()
              {
                logindata.setBool('login', true);
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => LoginPage()));
              },
            ),
          ],
        ),
    );
  }
}
