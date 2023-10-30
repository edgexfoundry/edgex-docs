---
title: Device Service SDK - C Utilities
---

# Device Service SDK - Using iot_data_t

## Introduction

The `iot_data_t` type is a holder for various types of data, and it is used in the SDK API to hold reading values and name-value collections (maps keyed by string). This chapter describes how to use `iot_data_t` in interactions with the SDK. It is not a complete guide to either the type or to the IOT utilities package which includes it

## Types

The type of data held in an `iot_data_t` object is represented by the `iot_typecode_t` type. This has a field `type`, which is an `iot_data_type_t`, and can take the following values:

- `IOT_DATA_INT8 IOT_DATA_INT16 IOT_DATA_INT32 IOT_DATA_INT64` for signed integers
- `IOT_DATA_UINT8 IOT_DATA_UINT16 IOT_DATA_UINT32 IOT_DATA_UINT64` for unsigned integers
- `IOT_DATA_FLOAT32 IOT_DATA_FLOAT64` for floating point values
- `IOT_DATA_BOOL` for booleans
- `IOT_DATA_STRING` for strings
- `IOT_DATA_ARRAY` for arrays
- `IOT_DATA_BINARY` for binary data
- `IOT_DATA_MAP` for maps (used for EdgeX Object type)

For the array case, the `iot_typecode_t` has an `element_type` field, also of type `iot_data_type_t` which indicates the type of the array elements - integers, floats and booleans are supported.

## Allocations

Instances of `iot_data_t` are created with the `iot_data_alloc_*` functions

### Primitive types

For primitive types, use

- `iot_data_alloc_i8 iot_data_alloc_i16 iot_data_alloc_i32 iot_data_alloc_i64` for signed integers
- `iot_data_alloc_ui8 iot_data_alloc_ui16 iot_data_alloc_ui32 iot_data_alloc_ui64` for unsigned integers
- `iot_data_alloc_f32 iot_data_alloc_f64` for floats
- `iot_data_alloc_bool` for booleans

Each takes a single parameter which is the value to hold

### Strings

Strings are allocated using `iot_data_alloc_string`. In addition to the `const char*` which specifies the string to hold, a further parameter of type `iot_data_ownership_t` must be provided. This sets the ownership semantics for the string, and can take the following values:

Ownership | Meaning
----------|--------
IOT_DATA_REF | The created object holds a pointer to the string, ownership remains the responsibility of the calling code. Useful in particular for string constants
IOT_DATA_TAKE | The created object takes ownership of the string. It will be freed when the `iot_data_t` object is freed
IOT_DATA_COPY | A copy will be made of the string. This copy will be freed when the `iot_data_t` object is freed, but the calling code remains responsible for the original

### Arrays

For array readings use `iot_data_alloc_array`

Parameter | Type | Description
----------|------|------------
data | void* | A C array of primitive types
length | uint32_t | The number of elements in the array
type | iot_data_type_t | The type of the data elements
ownership | iot_data_ownership_t | Ownership semantics for the data (see description in Strings section)

### Binary

For binary data use `iot_data_alloc_binary`

Parameter | Type | Description
----------|------|------------
data | void* | Pointer to the binary data
length | uint32_t | The length of the binary data, in bytes
ownership | iot_data_ownership_t | Ownership semantics for the data (see description in Strings section)

### Objects

Object-typed readings are represented by a map. Allocate it using

`iot_data_alloc_map (IOT_DATA_STRING)`

Values are added to the map using the `iot_data_string_map_add` function

Parameter | Type | Description
----------|------|------------
map | iot_data_t* | The map representing the Object
key | char* | The name of the field to add. This should be a string literal
val | iot_data_t* | The value of the field

## Accessing values

### Primitive types

The accessors for primitive types are

- `iot_data_i8 iot_data_i16 iot_data_i32 iot_data_i64`
- `iot_data_ui8 iot_data_ui16 iot_data_ui32 iot_data_ui64`
- `iot_data_f32 iot_data_f64`
- `iot_data_bool`

Each function takes an `iot_data_t*` as parameter and returns the value in the expected C type

### Strings

The `iot_data_string` function returns the `char*` held in the data object

### Arrays

- `iot_data_array_length` returns the length of an array
- `iot_data_address` returns a pointer to the first element
- `iot_data_array_type` returns the type of the elements (as `iot_data_type_t`)


## Binary

- `iot_data_address` returns a pointer to the binary data
- `iot_data_array_length` returns the length in bytes

### Objects

Use `iot_data_string_map_get` to obtain the `iot_data_t` instance representing a field

Parameter | Type | Description
----------|------|------------
map | iot_data_t* | The map representing the Object
key | char* | The name of the field to retrieve

## Deallocation

Instances of `iot_data_t` are freed using the `iot_data_free` function
