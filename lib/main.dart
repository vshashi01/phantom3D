import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phantom3d/data_model/scene_tab_container.dart';
import 'package:phantom3d/widgets/follow_viewport_scene_widget.dart';
import 'package:phantom3d/widgets/main_viewport_scene_widget.dart';

void main() async {
  //var channel = null;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Phantom 3D',
      theme: ThemeData(
          //primarySwatch: Color.black,
          accentColor: Colors.grey[800]),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  final List<SceneTabContainer> containers = List<SceneTabContainer>();
  SceneViewCubit _sceneViewCubit;
  TabController _tabController;
  int _followPortCounter = 0;
  int _mainPortCounter = 0;

  @override
  void initState() {
    final mainPort = MainViewportTabContainer("mainPort");
    mainPort.init();
    containers.add(mainPort);

    final followPort = FollowViewportTabContainer("followPort");
    followPort.init();
    containers.add(followPort);

    _sceneViewCubit = SceneViewCubit(0, containers.length);

    _tabController = TabController(
        initialIndex: _sceneViewCubit.state,
        length: _sceneViewCubit.totalLength,
        vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.dark,
      home: DefaultTabController(
        length: containers.length,
        initialIndex: _sceneViewCubit.state,
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.black,
              shadowColor: Colors.white,
              title: Text("Phantom 3D"),
              actions: [popUpMenu()],
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(kToolbarHeight),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: false,
                    indicatorSize: TabBarIndicatorSize.label,
                    indicatorColor: Colors.yellow[600],
                    tabs: _getTabBars(),
                    onTap: (index) {
                      _sceneViewCubit.setCurrentSceneIndex(index);
                    },
                  ),
                ),
              ),
            ),
            body: BlocBuilder<SceneViewCubit, int>(
              cubit: _sceneViewCubit,
              builder: (context, index) {
                return containers[index].getWidget();
              },
            )

            // TabBarView(
            //   children: [
            //     ...containers.map((tabContainer) {
            //       return tabContainer.getWidget();
            //     }).toList()
            //   ],
            // )

            ),
      ),
    );
  }

  Widget popUpMenu() {
    return PopupMenuButton<String>(
      color: Colors.grey[800],
      icon: Icon(
        Icons.menu,
        color: Colors.white,
      ),
      onSelected: (value) {
        if (value == 'Follow Mode') {
          _followPortCounter++;
          final followPort = FollowViewportTabContainer(
              "followPort $_followPortCounter",
              closable: true);
          followPort.init();
          containers.add(followPort);
        } else if (value == 'Create Mode') {
          _mainPortCounter++;
          final mainPort = MainViewportTabContainer(
              "mainPort $_mainPortCounter",
              closable: true);
          mainPort.init();
          containers.add(mainPort);
        }

        _sceneViewCubit.totalLength = containers.length;
        _sceneViewCubit.goToLast();
        _tabController = TabController(
            initialIndex: _sceneViewCubit.state,
            length: _sceneViewCubit.totalLength,
            vsync: this);
        setState(() {});
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'Follow Mode',
          child: ListTile(
            tileColor: Colors.transparent,
            leading: Icon(
              Icons.panorama_fisheye_outlined,
              color: Colors.white,
            ),
            title: Text(
              'Follow Mode',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        PopupMenuItem(
          value: 'Create Mode',
          child: ListTile(
            tileColor: Colors.transparent,
            leading: Icon(
              Icons.photo,
              color: Colors.white,
            ),
            title: Text(
              'Create Mode',
              style: TextStyle(color: Colors.white),
            ),
          ),
        )
      ],
    );
  }

  List<Widget> _getTabBars() {
    final containerMap = containers.asMap();
    final widgets = List<Widget>();

    containerMap.forEach((index, tabContainer) {
      final tabBar = Container(
          width: 200,
          child: ListTile(
            title: Text(tabContainer.title(),
                style: TextStyle(color: Colors.white)),
            trailing: tabContainer.canClose()
                ? IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      tabContainer.close();
                      containers.removeAt(index);

                      _sceneViewCubit.totalLength = containers.length;
                      _sceneViewCubit.setCurrentSceneIndex(index - 1);
                      _tabController = TabController(
                          initialIndex: _sceneViewCubit.state,
                          length: _sceneViewCubit.totalLength,
                          vsync: this);
                      setState(() {});
                    },
                  )
                : SizedBox(
                    width: 20,
                    height: 20,
                  ),
          ));

      widgets.add(tabBar);
    });

    return widgets;
  }

  // Widget _buildRTCVideoRender() {
  //   final size = 100.0;
  //   return ConditionalBuilder(
  //     conditionalStream: renderingCubit.connectionStream,
  //     child: Positioned(
  //         bottom: 100,
  //         right: 100,
  //         width: size,
  //         height: size,
  //         child: BlocProvider<ViewportRenderingCubit>.value(
  //           value: renderingCubit,
  //           child: ViewportDisplay(),
  //         )),
  //   );
  // }
}

class SceneViewCubit extends Cubit<int> {
  SceneViewCubit(int initialIndex, int initialLength) : super(initialIndex) {
    totalLength = initialLength;
  }

  int totalLength;

  void closingScene(int index) {
    emit(0);
  }

  void setCurrentSceneIndex(int index) {
    emit(index);
  }

  void goToLast() {
    emit(totalLength - 1);
  }
}
