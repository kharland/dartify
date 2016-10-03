#ifndef NERF_H
#define NERF_H

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

Dart_Handle Nerf_HandleError(Dart_Handle handle) {
  if (Dart_IsError(handle)) {
    Dart_PropagateError(handle);
  }
  return handle;
}

Dart_NativeFunction _Nerf_ResolveName(Dart_Handle name, int argc, bool* ass);

/*
 * ========================
 * Extensions to dart_api.h
 * ========================
 */

/**
 * Returns an integer with the provided value by converting to and from a 
 * hexadecimal string representation.
 */
Dart_Handle Nerf_NewIntegerFromMpz(mpz_t val) {
  size_t size = mpz_sizeinbase(val, 16);
  char hex[3 + size];
  hex[0] = '0';
  hex[1] = 'x';
  hex[2 + size] = '\0';
  mpz_get_str(hex + 2, 16, val);
  return Dart_NewIntegerFromHexCString(hex);
}

/** 
 * Set the return value for an extension from a mpz_t value.
 */
void Nerf_SetIntegerReturnValueFromMpz(Dart_NativeArguments args, mpz_t retval) {
  Dart_SetReturnValue(args, Nerf_HandleError(Nerf_NewIntegerFromMpz(retval)));
}

void Nerf_SetStringReturnValue(Dart_NativeArguments args, const char * rettval) {
  Dart_SetReturnValue(args, Nerf_HandleError(Dart_NewStringFromCString(rettval)));
}
/*
 * ==========================
 * Native ext function macros
 * ==========================
 */

/** 
 * Evaluates to the generated extension's initialization function
 */
#define Nerf_InitializeExtension(initializerId)\
  DART_EXPORT Dart_Handle initializerId(Dart_Handle parent_library) {\
    if (Dart_IsError(parent_library)) return parent_library;\
    Dart_Handle result_code =\
      Dart_SetNativeResolver(parent_library, _Nerf_ResolveName, NULL);\
    if (Dart_IsError(result_code)) return result_code;\
    return Dart_Null();\
  }

/** 
 * Evaluates to the generated extension's name resolver using resolution
 * to perform the actual resolution.  resolution should be a series of 
 * string comparisons which assign 'result' to the function corresponding to
 * the matched string.
 */
#define Nerf_ResolveName(resolution)\
  Dart_NativeFunction _Nerf_ResolveName(Dart_Handle name, int argc, bool* ass) {\
    if (!Dart_IsString(name)) return NULL;\
    Dart_NativeFunction result = NULL;\
    const char *cname;\
    *ass = true;\
    Nerf_HandleError(Dart_StringToCString(name, &cname));\
    resolution\
    return result;\
  }

/* Holds the result of any getter in this library upon successful completion */
union NerfResult {
  int i;
  uint ui;
  int64_t i64;
  uint64_t ui64;
  mpz_t mpz;
  double d;
  bool b;
  const char * str;
} nerfResult;

/* 
 * ======================
 * NativeArgument getters
 * ======================
 * 
 * Getters compute the C value of the Dart parameter passed to the extension.
 * If no errors occur then the getter returns Dart_Null and the computed value
 * is stored in the corresponding field of the union nerfResult.  If any 
 * errors occur they should be returned so that the caller can free any 
 * allocated resources before terminating.
 */

Dart_Handle Nerf_GetNativeBooleanArgument(Dart_NativeArguments arguments, int pos) {
  Dart_Handle result;

  bool value;
  result = Dart_GetNativeBooleanArgument(arguments, pos, &value);
  if (Dart_IsError(result)) return result;
  nerfResult.b = value;
  return Dart_Null();
}

Dart_Handle Nerf_GetNativeIntArgument(Dart_NativeArguments arguments, int pos) {
  Dart_Handle result;

  int64_t value;
  result = Dart_GetNativeIntegerArgument(arguments, pos, &value);
  if (Dart_IsError(result)) return result;
  nerfResult.i = value;
  return Dart_Null();
}

Dart_Handle Nerf_GetNativeInt64Argument(Dart_NativeArguments arguments, int pos) {
  Dart_Handle result;

  int64_t value;
  result = Dart_GetNativeIntegerArgument(arguments, pos, &value);
  if (Dart_IsError(result)) return result;
  nerfResult.i64 = value;
  return Dart_Null();
}

Dart_Handle Nerf_GetNativeUintArgument(Dart_NativeArguments arguments, int pos) {
  Dart_Handle result;

  uint64_t value;
  result = Dart_GetNativeArgument(arguments, pos);
  if (Dart_IsError(result)) return result;
  result = Dart_IntegerToUint64(result, &value);
  if (Dart_IsError(result)) return result;
  nerfResult.ui = value;
  return Dart_Null();
}

Dart_Handle Nerf_GetNativeUint64Argument(Dart_NativeArguments arguments, int pos) {
  Dart_Handle result;

  uint64_t value;
  result = Dart_GetNativeArgument(arguments, pos);
  if (Dart_IsError(result)) return result;
  result = Dart_IntegerToUint64(result, &value);
  if (Dart_IsError(result)) return result;
  nerfResult.ui64 = value;
  return Dart_Null();
}

Dart_Handle Nerf_GetNativeDoubleArgument(Dart_NativeArguments arguments, int pos) {
  Dart_Handle result;

  double value;
  result = Dart_GetNativeDoubleArgument(arguments, pos, &value);
  if (Dart_IsError(result)) return result;
  nerfResult.d = value;
  return Dart_Null();
}

Dart_Handle Nerf_GetNativeMpzArgument(Dart_NativeArguments arguments, int pos) {
  Dart_Handle result;
  const char *hex;

  result = Dart_GetNativeArgument(arguments, pos);
  if (Dart_IsError(result)) return result;

  result = Dart_IntegerToHexCString(result, &hex);
  if (Dart_IsError(result)) return result;

  // Assumes nerfResult.mpz is initialized by the caller
  if (mpz_set_str(nerfResult.mpz, hex, 0) != 0) {
    char msg[256];
    sprintf(msg, "could not convert value %s to mpz_t\n", hex);
    return Dart_NewApiError(msg);
  }

  return Dart_Null();
}

Dart_Handle Nerf_GetNativeStringArgument(Dart_NativeArguments arguments, int pos) {
  Dart_Handle result;
  void *peer;

  result = Dart_GetNativeStringArgument(arguments, pos, &peer);
  if (Dart_IsError(result)) return result;
  // what to do with peer?
  result = Dart_StringToCString(result, &nerfResult.str);
  if (Dart_IsError(result)) return result;
  return Dart_Null();
}

#endif //NERF_H