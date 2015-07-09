import "dart-ext:example_extension";
import "dart:math";

int _int(int a, int b) native "_int";
String _String() native "_String";
int _mpzadd(int a, int b) native "_mpzadd";
int _mpz() native "_mpz";
int _uint() native "_uint";
double _float() native "_float";
double _double() native "_double";
bool _boolt() native "_boolt";
bool _boolf() native "_boolf";
void _void() native "_void";
void _speak(String msg) native "_speak";

main() {
  print('Got an int: ${_int(12, 10)}');
  print('Got a uint: ${_uint()}');
  print('Got a float: ${_float()}');
  print('Got a double: ${_double()}');
  print('Got a string: ${_String()}');
  print('Got an mpz_t: ${_mpzadd(12, 13)}');
  print('Got an mpz_t: ${_mpz()}');
  print('Got a false: ${_boolf()}');
  print('Got a true: ${_boolt()}');
  _void();
  _speak("This is your captain speaking");
}
  
