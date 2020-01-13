/* Copyright (c) INRIA and Microsoft Corporation. All rights reserved.
   Licensed under the Apache 2.0 License. */

#include "Prims.h"
#include "FStar_Int32.h"

Prims_string Prims_string_of_int(krml_checked_int_t i) {
  return FStar_Int32_to_string(i);
}

Prims_string Prims_strcat(Prims_string s0, Prims_string s1) {
  size_t len = strlen(s0) + strlen(s1) + 1;
  char *dest = KRML_HOST_CALLOC(len, 1);
#ifdef _MSC_VER
  strcat_s(dest, len, s0);
  strcat_s(dest, len, s1);
#else
  strcat(dest, s0);
  strcat(dest, s1);
#endif
  return (Prims_string)dest;
}

bool __eq__Prims_string(Prims_string s1, Prims_string s2) {
  return (strcmp(s1, s2) == 0);
}

inline Prims_string Prims_string_of_bool(bool b) {
  if (b) {
    return "true";
  } else {
    return "false";
  }
}

bool Prims_op_GreaterThanOrEqual(int64_t x, int64_t y) {
  return x >= y;
}

bool Prims_op_LessThanOrEqual(int64_t x, int64_t y) {
  return x <= y;
}

bool Prims_op_GreaterThan(int64_t x, int64_t y) {
  return x > y;
}

bool Prims_op_LessThan(int64_t x, int64_t y) {
  return x < y;
}

int64_t Prims_pow2(int64_t x) {
  /* FIXME incorrect bounds check here */
  RETURN_OR((uint64_t)1 << (uint64_t)x);
}

int64_t Prims_op_Multiply(int64_t x, int64_t y) {
  RETURN_OR((int64_t)x * (int64_t)y);
}

int64_t Prims_op_Addition(int64_t x, int64_t y) {
  RETURN_OR((int64_t)x + (int64_t)y);
}

int64_t Prims_op_Subtraction(int64_t x, int64_t y) {
  RETURN_OR((int64_t)x - (int64_t)y);
}

int64_t Prims_op_Division(int64_t x, int64_t y) {
  RETURN_OR((int64_t)x / (int64_t)y);
}

int64_t Prims_op_Modulus(int64_t x, int64_t y) {
  RETURN_OR((int64_t)x % (int64_t)y);
}
