import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';
import '../models/http_exception.dart';

enum AuthMode { Signup, Login }

class AuthScreen extends StatelessWidget {
  static const routeName = '/auth';

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    // final transformConfig = Matrix4.rotationZ(-8 * pi / 180);
    // transformConfig.translate(-10.0);
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(215, 117, 255, 1).withOpacity(0.5),
                  Color.fromRGBO(255, 188, 117, 1).withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0, 1],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  // Flexible(
                  //   child: Container(
                  //     margin: EdgeInsets.only(bottom: 20.0),
                  //     padding:
                  //         EdgeInsets.symmetric(vertical: 8.0, horizontal: 94.0),
                  //     // transform allows you to rotate, scale or move a Container()
                  //     // rotationX is left to right, rotationY is up to down
                  //     // rotationZ is into the device in 3D space
                  //     // ..enables you trigger a method on an object but not
                  //     // return the value of the aforemetioned method
                  //     // but the method before it
                  //     // e.g. rotationZ().translate would return what translate() provides
                  //     // whereas rotationZ()..translate returns what rotationZ() provides
                  //     // .. operator does the same as doing `final transformConfig = Matrix4.rotationZ(-8 * pi / 180)`
                  //     // `transformConfig.translate()`
                  //     transform: Matrix4.rotationZ(-8 * pi / 180)
                  //       ..translate(-10.0),
                  //     decoration: BoxDecoration(
                  //       borderRadius: BorderRadius.circular(20),
                  //       color: Colors.deepOrange.shade900,
                  //       boxShadow: [
                  //         BoxShadow(
                  //           blurRadius: 8,
                  //           color: Colors.black26,
                  //           offset: Offset(0, 2),
                  //         )
                  //       ],
                  //     ),
                  //     child: Text(
                  //       'MyShop',
                  //       style: TextStyle(
                  //         color:
                  //             Theme.of(context).accentTextTheme.headline6.color,
                  //         fontSize: 50,
                  //         fontFamily: 'Anton',
                  //         fontWeight: FontWeight.normal,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  Flexible(
                    flex: deviceSize.width > 600 ? 2 : 1,
                    child: AuthCard(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  const AuthCard({
    Key key,
  }) : super(key: key);

  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;
  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };
  var _isLoading = false;
  final _passwordController = TextEditingController();
  AnimationController _animationController;

  // need to tell animation class what you want to animate, e.g. Size
  Animation<Size> _heightAnimation;
  Animation<Offset> _slideAnimation;
  Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    // vsync points at target widget, only tells the animation controller
    // to render the animation when the widget is visible
    // vsync requires SingleTickerProviderStateMixin Mixin
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 500,
      ),
    );
    // Tween() knows how to animate between 2 values
    // e.g. increase height from 260 to 320
    _heightAnimation = Tween<Size>(
        begin: Size(
          double.infinity,
          260,
        ),
        end: Size(
          double.infinity,
          320,
        )).animate(
      CurvedAnimation(
        parent: _animationController,
        // change the speed of the 2 values
        // e.g. linear is steady
        // e.g. easeIn, easeOut
        curve: Curves.fastOutSlowIn,
      ),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, -1.5),
      end: Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      // change the speed of the 2 values
      // e.g. linear is steady
      // e.g. easeIn, easeOut
      curve: Curves.fastOutSlowIn,
    ));
    _opacityAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    // add a listener to call set state whenever animation updates
    // _heightAnimation.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    super.dispose();
    // make sure to dispose of the animation controller when state is removed
    _animationController.dispose();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('An error occurred'),
        content: Text(message),
        actions: [
          FlatButton(
            child: Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });
    try {
      if (_authMode == AuthMode.Login) {
        await Provider.of<AuthProvider>(context, listen: false).signIn(
          _authData['email'],
          _authData['password'],
        );
      } else {
        await Provider.of<AuthProvider>(context, listen: false).signUp(
          _authData['email'],
          _authData['password'],
        );
      }
      // `on ... catch` will trigger on a specific error class
    } on HttpException catch (error) {
      var errorMessage = 'Authentication Failed';
      if (error.toString().contains('EMAIL_EXISTS')) {
        errorMessage = 'This email address is already in use.';
      } else if (error.toString().contains('INVALID_EMAIL')) {
        errorMessage = 'This is not a valid email address.';
      } else if (error.toString().contains('WEAK_PASSWORD')) {
        errorMessage = 'This password is too weak.';
      } else if (error.toString().contains('EMAIL_NOT_FOUND')) {
        errorMessage = 'Could not find a user with that email';
      } else if (error.toString().contains('INVALID_PASSWORD')) {
        errorMessage = 'Invalid password.';
      }
      _showErrorDialog(errorMessage);
    } catch (error) {
      const errorMessage = 'Could not authenticate. Please try again later.';
      _showErrorDialog(errorMessage);
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Signup;
      });
      // forward() starts the animation
      _animationController.forward();
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
      // reverse the animation
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 8.0,
      // AnimatedBuilder automatically sets up listeners for you
      // also means you can minimise widget re-building (just the parent widget)
      // with the help of builder
      // AnimatedBuilder(
      //   animation: _heightAnimation,
      //   // using the ch (child) parameter enables you to only rebuild/animate
      //   // the Container() widget, rather than all of it's content too
      //   builder: (ctx, ch) => Container(
      //     // height: _authMode == AuthMode.Signup ? 320 : 260,
      //     // references the Animation Tween object specified above in initState()
      child: AnimatedContainer(
        // AnimatedContainer automatically detects the value changes e.g. Height
        // and smoothly animates
        // dont need animation AnimationController or Animation<Size> for this widget
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
        // height: _heightAnimation.value.height,
        height: _authMode == AuthMode.Signup ? 320 : 260,
        constraints:
            BoxConstraints(minHeight: _authMode == AuthMode.Signup ? 320 : 260),
        width: deviceSize.width * 0.75,
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(labelText: 'E-Mail'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value.isEmpty || !value.contains('@')) {
                      return 'Invalid email!';
                    }
                    return null;
                    return null;
                  },
                  onSaved: (value) {
                    _authData['email'] = value;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  controller: _passwordController,
                  validator: (value) {
                    if (value.isEmpty || value.length < 5) {
                      return 'Password is too short!';
                    }
                  },
                  onSaved: (value) {
                    _authData['password'] = value;
                  },
                ),
                // FadeTransition requires AnimationController and Animation object
                AnimatedContainer(
                  // add AnimatedContainer to set height to 0 if field not visible
                  // then increase height when text field is visible
                  duration: Duration(milliseconds: 300),
                  constraints: BoxConstraints(
                    minHeight: _authMode == AuthMode.Signup ? 60 : 0,
                    maxHeight: _authMode == AuthMode.Signup ? 120 : 0,
                  ),
                  curve: Curves.easeIn,
                  child: FadeTransition(
                    // pass Animation<double> into opacity
                    opacity: _opacityAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: TextFormField(
                        enabled: _authMode == AuthMode.Signup,
                        decoration:
                            InputDecoration(labelText: 'Confirm Password'),
                        obscureText: true,
                        validator: _authMode == AuthMode.Signup
                            ? (value) {
                                if (value != _passwordController.text) {
                                  return 'Passwords do not match!';
                                }
                              }
                            : null,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                if (_isLoading)
                  CircularProgressIndicator()
                else
                  RaisedButton(
                    child:
                        Text(_authMode == AuthMode.Login ? 'LOGIN' : 'SIGN UP'),
                    onPressed: _submit,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding:
                        EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
                    color: Theme.of(context).primaryColor,
                    textColor: Theme.of(context).primaryTextTheme.button.color,
                  ),
                FlatButton(
                  child: Text(
                      '${_authMode == AuthMode.Login ? 'SIGNUP' : 'LOGIN'} INSTEAD'),
                  onPressed: _switchAuthMode,
                  padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
                  // materialTapTargetSize reduces the clickable area for the button
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textColor: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
