#ifndef DARTIFY_H
#define DARTIFY_H

#include <stdlib.h>
#include <stdio.h>
#include <gmp.h>
#include "include/dart_api.h"
#include "include/dart_native_api.h"

/* 
 * ==========================
 * Boilerplate Nat. Ext. code
 * ==========================
 */

Dart_Handle Dartify_HandleError(Dart_Handle handle) {
  if (Dart_IsError(handle)) {
    Dart_PropagateError(handle);
  }
  return handle;
}

Dart_NativeFunction _Dartify_ResolveName(Dart_Handle name, int argc, bool* ass);

/*
 * ========================
 * Extensions to dart_api.h
 * ========================
 */

/**
 * Returns an integer with the provided value by converting to and from a 
 * hexadecimal string representation.
 */
Dart_Handle Dartify_NewIntegerFromMpz(mpz_t val) {
  size_t size = mpz_sizeinbase(val, 16);
  char hex[3 + size];
  hex[0] = '0';
  hex[1] = 'x';
  hex[size + 2] = '\0';
  mpz_get_str(hex + 2, 16, val);
  return Dart_NewIntegerFromHexCString(hex);
}

/** 
 * Set the return value for an extension from a mpz_t value.
 */
void Dartify_SetIntegerReturnValueFromMpz(Dart_NativeArguments args, mpz_t retval) {
  Dart_SetReturnValue(args, Dartify_HandleError(Dartify_NewIntegerFromMpz(retval)));
}

/*
 * ==========================
 * Native ext function macros
 * ==========================
 */

/** 
 * Evaluates to the generated extension's initialization function
 */
#define Dartify_InitializeExtension()\
  DART_EXPORT Dart_Handle dartified_extension_Init(Dart_Handle parent_library) {\
    if (Dart_IsError(parent_library)) return parent_library;\
    Dart_Handle result_code =\
      Dart_SetNativeResolver(parent_library, _Dartify_ResolveName, NULL);\
    if (Dart_IsError(result_code)) return result_code;\
    return Dart_Null();\
  }

/** 
 * Evaluates to the generated extension's name resolver using resolution
 * to perform the actual resolution.  resolution should be a series of 
 * string comparisons which assign 'result' to the function corresponding to
 * the matched string.
 */
#define Dartify_ResolveName(resolution)\
  Dart_NativeFunction _Dartify_ResolveName(Dart_Handle name, int argc, bool* ass) {\
    if (!Dart_IsString(name)) return NULL;\
    Dart_NativeFunction result = NULL;\
    const char *cname;\
    *ass = true;\
    Dartify_HandleError(Dart_StringToCString(name, &cname));\
    resolution\
    return result;\
  }

/* Holds the result of any getter in this library upon successful completion */
union DartifyResult {
  int i;
  uint ui;
  int64_t i64;
  uint64_t ui64;
  mpz_t mpz;
  double d;
  bool b;
} dartifyResult;

/* 
 * ======================
 * NativeArgument getters
 * ======================
 * All getters compute the C value of the Dart parameter passed to the extension.  
 * This value is stored in the corresponding field of the union dartifyResult.
 * If no errors occur then every getter should return Dart_Null.  If any errors
 * occur they should be returned so that the caller can free any allocated 
 * resources before terminating.
 */

Dart_Handle Dartify_GetBooleanNativeArgument(Dart_NativeArguments arguments, int pos) {
  Dart_Handle result;

  bool value;
  result = Dart_GetNativeBooleanArgument(arguments, pos, &value);
  if (Dart_IsError(result)) return result;
  dartifyResult.b = value;
  return Dart_Null();
}

Dart_Handle Dartify_GetIntNativeArgument(Dart_NativeArguments arguments, int pos) {
  Dart_Handle result;

  int64_t value;
  result = Dart_GetNativeIntegerArgument(arguments, pos, &value);
  if (Dart_IsError(result)) return result;
  dartifyResult.i = value;
  return Dart_Null();
}

Dart_Handle Dartify_GetInt64NativeArgument(Dart_NativeArguments arguments, int pos) {
  Dart_Handle result;

  int64_t value;
  result = Dart_GetNativeIntegerArgument(arguments, pos, &value);
  if (Dart_IsError(result)) return result;
  dartifyResult.i64 = value;
  return Dart_Null();
}

Dart_Handle Dartify_GetUintNativeArgument(Dart_NativeArguments arguments, int pos) {
  Dart_Handle result;

  uint64_t value;
  result = Dart_GetNativeArgument(arguments, pos);
  if (Dart_IsError(result)) return result;
  result = Dart_IntegerToUint64(result, &value);
  if (Dart_IsError(result)) return result;
  dartifyResult.ui = value;
  return Dart_Null();
}

Dart_Handle Dartify_GetUint64NativeArgument(Dart_NativeArguments arguments, int pos) {
  Dart_Handle result;

  uint64_t value;
  result = Dart_GetNativeArgument(arguments, pos);
  if (Dart_IsError(result)) return result;
  result = Dart_IntegerToUint64(result, &value);
  if (Dart_IsError(result)) return result;
  dartifyResult.ui64 = value;
  return Dart_Null();
}

Dart_Handle Dartify_GetDoubleNativeArgument(Dart_NativeArguments arguments, int pos) {
  Dart_Handle result;

  double value;
  result = Dart_GetNativeDoubleArgument(arguments, pos, &value);
  if (Dart_IsError(result)) return result;
  dartifyResult.d = value;
  return Dart_Null();
}

Dart_Handle Dartify_GetMpzNativeArgument(Dart_NativeArguments arguments, int pos) {
  Dart_Handle result;
  const char *hex;

  result = Dart_GetNativeArgument(arguments, pos);
  if (Dart_IsError(result)) return result;

  result = Dart_IntegerToHexCString(result, &hex);
  if (Dart_IsError(result)) return result;

  // Assumes dartifyResult.mpz is initialized
  if (mpz_set_str(dartifyResult.mpz, hex, 0) != 0) {
    char msg[256];
    sprintf(msg, "could not convert value %s to mpz_t\n", hex);
    return Dart_NewApiError(msg);
  }

  return Dart_Null();
}

#endif //DARTIFY_H
