#include <stdlib.h>
#include <stdio.h>
#include <gmp.h>

/*
 * These are just a few examples of dartifiable functions.  
 * Run `dartify example.c` to see the extension that gets generated for this 
 * example.
 */


//@dartify:sync
int _intp(int* list, size_t size) {
  int i;
  for (i = 0; i < size; i++) {
    printf("%d ", list[i]);
    list[i] = 1;
  }
  printf("\n");
  return list;
}

//@dartify:sync
void _void();

//@dartify:sync
const char* _String() { 
  return "This is a string"; 
}

//@dartify:sync
int _int(int a, int b) { 
  return a + b; 
}

//@dartify:sync
uint _uint() { 
  return 1<<31; 
}

//@dartify:sync
float _float() { 
  return 3.141; 
}

//@dartify:sync
double _double() { 
  return 3.1415926; 
}

//@dartify:sync
bool _boolf() { 
  return false; 
}

//@dartify:sync
bool _boolt() { 
  return true; 
}

//@dartify:syncgmp
void _mpzadd(mpz_t ret, mpz_t a, mpz_t b) {
  mpz_add(ret, a, b);
}

//@dartify:syncgmp
void _mpz(mpz_t ret) {
  mpz_set_str(ret, "4954735094375043750498753420975243095743095", 10);
}

//@dartify:sync
void _speak(const char * msg) { printf("%s\n", msg); }

void _void() { printf("called _void() from extension\n"); }