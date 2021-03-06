import 'package:flutter/material.dart';
import 'package:disaster_reporting/models/info.dart';
import 'package:disaster_reporting/controllers/infoController.dart';
import 'package:disaster_reporting/pages/partials/msgBar.dart';

// import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// final storage = new FlutterSecureStorage();

class AddRecord extends StatefulWidget {
  @override
  _AddRecordState createState() => _AddRecordState();
}

class _AddRecordState extends State<AddRecord> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _autoValidate = false;
  Info _info = Info();
  bool _isLoading = false;
  DateTime _selectedDate = DateTime.now();
  var dateController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    dateController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/images/addRec.jpg"),
              alignment: Alignment(0.0, -0.9),
              fit: BoxFit.scaleDown),
        ),
        child: ListView(
          children: <Widget>[
            Center(
                child: _isLoading
                    ? LinearProgressIndicator()
                    : SizedBox(height: 6.0)),
            Padding(
              padding: EdgeInsets.fromLTRB(24.0, 160.0, 24.0, 0.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                ),
                elevation: 5.0,
                child: Builder(
                  builder: (context) => Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 24.0, horizontal: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              IconButton(
                                padding: EdgeInsets.all(0.0),
                                iconSize: 36.0,
                                icon: Icon(
                                  Icons.arrow_back_ios,
                                  color: Colors.black54,
                                ),
                                onPressed: () => Navigator.pop(context),
                              ),
                              Text(
                                ' Add record',
                                style: TextStyle(fontSize: 36.0),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 16.0),
                          child: Column(
                            children: <Widget>[
                              TextFormField(
                                enabled: !this._isLoading,
                                decoration:
                                    decorate('Location', Icons.location_on),
                                validator: (value) {
                                  return validate(value);
                                },
                                autovalidate: _autoValidate,
                                onSaved: (val) => _info.location = val,
                              ),
                              SizedBox(
                                height: 16.0,
                              ),
                              TextFormField(
                                enabled: !this._isLoading,
                                decoration: decorate('Disaster', Icons.flag),
                                validator: (value) {
                                  return validate(value);
                                },
                                autovalidate: _autoValidate,
                                onSaved: (val) => _info.dname = val,
                              ),
                              SizedBox(
                                height: 16.0,
                              ),
                              TextFormField(
                                readOnly: true,
                                onTap: () => _selectDate(context),
                                enabled: !this._isLoading,
                                controller: dateController,
                                decoration: decorate(
                                    'Date (YYYY.MM.DD)', Icons.date_range),
                                validator: (value) {
                                  return validate(value);
                                },
                                autovalidate: _autoValidate,
                                onSaved: (val) => _info.date = val,
                              ),
                              SizedBox(
                                height: 16.0,
                              ),
                              TextFormField(
                                enabled: !this._isLoading,
                                decoration: decorate('Weather', Icons.wb_sunny),
                                validator: (value) {
                                  return validate(value);
                                },
                                autovalidate: _autoValidate,
                                onSaved: (val) => _info.weather = val,
                              ),
                              SizedBox(
                                height: 16.0,
                              ),
                              TextFormField(
                                enabled: !this._isLoading,
                                decoration:
                                    decorate('Situation', Icons.landscape),
                                validator: (value) {
                                  return validate(value);
                                },
                                autovalidate: _autoValidate,
                                onSaved: (val) => _info.situation = val,
                              ),
                              SizedBox(
                                height: 16.0,
                              ),
                              TextFormField(
                                enabled: !this._isLoading,
                                decoration:
                                    decorate('Condition', Icons.landscape),
                                validator: (value) {
                                  return validate(value);
                                },
                                autovalidate: _autoValidate,
                                onSaved: (val) => _info.worsen = val,
                              ),
                              SizedBox(
                                height: 16.0,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  MaterialButton(
                                    child: Text(
                                      'Post',
                                      style: TextStyle(
                                        fontSize: 22.0,
                                      ),
                                    ),
                                    onPressed: this._isLoading
                                        ? null
                                        : () async {
                                            // bool pop =
                                            await postRecord();
                                            // if (pop) {
                                            //   Navigator.pop(context);
                                            // }
                                          },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime.now());
    if (picked != null && picked != _selectedDate)
      setState(() {
        _selectedDate = picked;
        dateController.text =
            "${picked.year.toString()}.${picked.month.toString().padLeft(2, '0')}.${picked.day.toString().padLeft(2, '0')}";
      });
  }

  Future<bool> postRecord() async {
    String mssg;
    Color color;
    bool pop = false;

    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      setState(() {
        this._isLoading = true;
      });

      Map<String, dynamic> result = await addRecord(_info);

      if (result['msg'] != null) {
        setState(() {
          this._isLoading = false;
        });
        mssg = result['msg'];
        color = Colors.green[400];
        pop = true;
      } else {
        // If no internet connection
        setState(() {
          this._isLoading = false;
        });
        mssg = result['err'];
        color = Colors.red[400];
      }
    } else {
      mssg = "Please fill up all the details";
      color = Colors.red[400];
    }
    final SnackBar snackBar = msgBar(
      mssg,
      color,
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
    Future.delayed(Duration(milliseconds: 500));
    return pop;
  }

  String validate(value) {
    this._autoValidate = true;
    if (value.isEmpty) {
      return 'Please fill this field';
    }
    return null;
  }

  InputDecoration decorate(String text, IconData icon) {
    return InputDecoration(
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: Colors.teal[100],
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: Colors.green,
        ),
      ),
      disabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: Colors.grey,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: Colors.red,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: Colors.deepOrange[200],
        ),
      ),
      labelText: text,
      prefixIcon: Icon(icon),
    );
  }
}
