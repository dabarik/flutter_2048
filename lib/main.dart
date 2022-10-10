import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

void main() {
  runApp(const MyApp());
}

class Tuile {
  final int x;
  final int y;
  int valeur;

  Animation<double>? animationX;
  Animation<double>? animationY;
  Animation<int>? animationVal;
  Animation<double>? scale;

  Tuile(this.x, this.y, this.valeur) {
    resetAnimations();
  }

  void resetAnimations() {
    animationX = AlwaysStoppedAnimation(this.x.toDouble());
    animationY = AlwaysStoppedAnimation(this.y.toDouble());
    animationVal = AlwaysStoppedAnimation(this.valeur);
    scale = AlwaysStoppedAnimation(1);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '2048 Flutter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: '2048 !'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  AnimationController? animControl;

  //Creation de la grille
  late List<List<Tuile>> grille = [];
  List<Tuile> tuilesAdd = [];

  Iterable<Tuile> get flattenedGrid => grille.expand((e) => e);

  //liste des tuiles par colonnes
  Iterable<List<Tuile>> get columns =>
    List.generate(4, (x) => List.generate(4, (y) => grille[y][x]));

  // retourne une liste de 16 (4x4) tuiles vides
  List<List<Tuile>> generateEmptyTiles() {
    return List.generate(4, (y) => List.generate(4, (x) => Tuile(x, y, 0)));
  }
  
  List<List<Tuile>> initTuiles() {
    // inititalisation
    List<List<Tuile>> grilleTemp = generateEmptyTiles();
    
    // ajout de deux tuiles de valeurs
    grilleTemp = addTuilesInit(grilleTemp);

    return grilleTemp;
  }

  List<List<Tuile>> addTuilesInit(List<List<Tuile>> grilleTemp) {
    List<Tuile> emptyTuiles = grilleTemp.expand((e) => e).where((element) => element.valeur == 0).toList();

    Random rdm = Random();
    int randomIndex1 = rdm.nextInt(emptyTuiles.length);
    int randomIndex2 = rdm.nextInt(emptyTuiles.length);
    while (randomIndex1 == randomIndex2) {
      randomIndex2 = rdm.nextInt(emptyTuiles.length);
    }

    emptyTuiles[randomIndex1] = Tuile(emptyTuiles[randomIndex1].x, emptyTuiles[randomIndex1].y, rdmValue());

    emptyTuiles[randomIndex2] = Tuile(emptyTuiles[randomIndex2].x, emptyTuiles[randomIndex2].y, rdmValue());


    List<List<Tuile>> tuile2DArray = [];
    int chunkSize = 4;

    // Split the list into chunks of 4.
    for (var i = 0; i < emptyTuiles.length; i += chunkSize) {
      // Add the chunk to the 2D array.
      tuile2DArray.add(emptyTuiles.sublist(
          i, i + chunkSize > emptyTuiles.length ? emptyTuiles.length : i + chunkSize));
    }
    return tuile2DArray;
  }

  int rdmValue(){
    return Random().nextDouble() < 0.9 ? 2 : 4;
  }

  @override
  void initState() {
    super.initState();
    grille = initTuiles();

    animControl =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
        animControl!.addStatusListener((status) {
          if (status == AnimationStatus.completed){
            tuilesAdd.forEach((element) {
              grille[element.y][element.x].valeur = element.valeur;
              });
            flattenedGrid.forEach((element) {
              element.resetAnimations();
            });
            tuilesAdd.clear();
          }
        });

    animControl!.forward();

    flattenedGrid.forEach((e) => e.resetAnimations());
  }

  void addTuiles(){
    List<Tuile> vide = flattenedGrid.where((element) => element.valeur == 0).toList();
    vide.shuffle();
    tuilesAdd.add(Tuile(vide.first.x, vide.first.y, 2));
  }

  @override
  Widget build(BuildContext context) {
    double tailleGrille = MediaQuery.of(context).size.width - 16 * 2;
    double tailleCase = (tailleGrille - 4 * 2) / 4;
    List<Widget> cases = [];
    cases.addAll(flattenedGrid.map((e) => Positioned(
        left: e.x * tailleCase - 7,
        top: e.y * tailleCase - 7,
        width: tailleCase,
        height: tailleCase,
        child: Center(
          child: Container(
              width: tailleCase - 4 * 2,
              height: tailleCase - 4 * 2,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Color.fromARGB(51, 1, 103, 255),
              )),
        ))));

    cases.addAll(
      [flattenedGrid, tuilesAdd].expand((element) => element).map((e) => AnimatedBuilder(
      animation: animControl!, 
      builder: (context, child) => e.animationVal!.value == 0 
      ? SizedBox()
      : Positioned(
        left: e.x * tailleCase - 7,
        top: e.y * tailleCase - 7,
        width: tailleCase,
        height: tailleCase,
        child: Center(
          child: Container(
              width: tailleCase - 4 * 2,
              height: tailleCase - 4 * 2,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Color.fromARGB(51, 1, 103, 255),
              ),
              child: Center(
                child: Text(
                  "${e.animationVal!.value}",
                  style: TextStyle(
                    color: e.animationVal!.value <= 4
                      ? Color.fromARGB(255, 119, 110, 101) 
                      : Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.w900),
                ),
              ))),
            ))));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          SizedBox(
            width: 500,
            height: 70,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  grille = initTuiles();
                });
              },
              child: Text('Nouvelle partie'),
              ),
          ),
         Container(
          width: tailleGrille,
          height: tailleGrille,
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Color.fromARGB(51, 1, 170, 255)), 
          
          child: GestureDetector(
            onVerticalDragEnd: (details){
              if(details.velocity.pixelsPerSecond.dy < -250 && canMoveUp()){
                move(moveUp);
              }else if(details.velocity.pixelsPerSecond.dy > 250 && canMoveDown()){
                move(moveDown);
              }
            },
            onHorizontalDragEnd: (details){
              if(details.velocity.pixelsPerSecond.dx < -1000 && canMoveLeft()){
                move(moveLeft);
              }else if(details.velocity.pixelsPerSecond.dx > 1000 && canMoveRight()){
                move(moveRight);
              }
            },
          child: Stack(
            children: cases
            )
        ),
      )
        
      ],
    )
    );
  }

  void move(void Function() moveDir){
    setState(() {
      moveDir();
      addTuiles();
      animControl!.forward(from: 0);
    });
  }

  bool canMoveLeft() => grille.any(canMove);
  bool canMoveRight() => grille.map((e) => e.reversed.toList()).any(canMove);
  bool canMoveUp() => columns.any(canMove);
  bool canMoveDown() => columns.map((e) => e.reversed.toList()).any(canMove);

  bool canMove(List<Tuile> tuiles){
    for (var i = 0; i < tuiles.length; i++) {
      if(tuiles[i].valeur == 0){
        if(tuiles.skip(i + 1).any((element) => element.valeur != 0)){
          return true;
        }
      } else{
        Tuile? nextNumber = tuiles.skip(i + 1).firstWhereOrNull((element) => element.valeur != 0);
        if(nextNumber != null && nextNumber.valeur == tuiles[i].valeur){
          return true;
        }
      }
    }
    return false;
  }

  void moveLeft() => grille.forEach(mergeTuiles);
  void moveRight() => grille.map((e) => e.reversed.toList()).forEach(mergeTuiles);
  void moveUp() => columns.forEach(mergeTuiles);
  void moveDown() => columns.map((e) => e.reversed.toList()).forEach(mergeTuiles);

  void mergeTuiles(List<Tuile> tuiles){
    for (var i = 0; i < tuiles.length; i++) {
      Iterable<Tuile> nonZeroTuile = tuiles.skip(i).skipWhile((value) => value.valeur == 0);
      if (nonZeroTuile.isNotEmpty){
        Tuile t = nonZeroTuile.first;
        Tuile? merge = nonZeroTuile.skip(1).firstWhereOrNull((element) => element.valeur != 0);
        if(merge != null && merge.valeur != t.valeur){
          merge = null;
        } 
        if (tuiles[i] != t || merge != null){
          int resultat = t.valeur;
          if(merge != null){
            resultat += merge.valeur;
            merge.valeur = 0;
          }
          t.valeur = 0;
          tuiles[i].valeur = resultat;
        }
      }
    }
  }
}
