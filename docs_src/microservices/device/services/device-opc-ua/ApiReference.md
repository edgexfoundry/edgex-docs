---
title: Device OPC-UA - API Reference
---

# Device OPC-UA - API Reference

This service inherits the [Common Device Service APIs](../../ApiReference.md) from the SDK.

Read and write of a device resource go through core command. The browse route below is served by this device service.

## Browse one level

```text
GET /api/v3/opcua/device/{deviceName}/browse
```

`{deviceName}` is the EdgeX device name. One call returns the direct children of a single OPC UA node. The service does not walk further and does not store the tree. The caller keeps each response and sends the next object node's `nodeId`.

The default start node is the `Objects` folder, `i=85`. The browse follows forward `HierarchicalReferences` and subtypes. With `includeProperties` left at its default, `HasProperty` references are omitted.

The route does not require a JWT. Device command GET and PUT on the same port still do. Limit who can reach the device service port.

Browse uses the same OPC UA session as read and write, including `SecretName`. The call times out after 15 seconds.

### Query

| Name | Default | Description |
| ---- | ------- | ----------- |
| `nodeId` | `i=85` | Node to browse. |
| `maxNodes` | `200` | Maximum references in this response. An integer from 1 to 1000. |
| `includeProperties` | `false` | `true` keeps `HasProperty` references. |
| `nodeClass` | all classes | Comma-separated list of `Object`, `Variable`, `Method`, and `View`. |
| `continuationToken` | empty | Standard base64 of the OPC UA continuation point from the previous response for this same `nodeId`. URL-encode it. |
| `depth` | | Rejected with `400`. |

### Response

`200` returns one level:

| Field | Description |
| ----- | ----------- |
| `deviceName` | EdgeX device name. |
| `startNodeId` | Node that was browsed. |
| `namespaces` | Server namespace array. Index 0 is the OPC UA namespace. |
| `truncated` | `true` when more siblings remain. |
| `continuationToken` | Present when `truncated` is `true`. Empty when the level is complete. |
| `references` | Direct children that passed the filters. |

Each entry in `references`:

| Field | Description |
| ----- | ----------- |
| `parentNodeId` | Requested node. |
| `nodeId` | Child node. Send this as `nodeId` to open the next level. |
| `browseName` | `namespaceIndex:name`. |
| `namespaceUri` | URI for that namespace index, when the namespace array contains it. |
| `displayName` | Display name text. |
| `nodeClass` | `Object`, `Variable`, `Method`, `View`, or another OPC UA node class. |
| `referenceType` | Reference type name, for example `Organizes` or `HasComponent`. |
| `typeDefinition` | Type-definition node id, when the server provided one. |
| `dataType` | Variable data type name. |
| `dataTypeId` | Variable data type node id. |
| `valueRank` | OPC UA value rank. `-1` is a scalar. `0` or greater is an array. |
| `accessLevel` | `R`, `W`, or `RW` from the current read and write bits. |
| `edgexValueType` | Hint for a device profile `properties.valueType`. |

`edgexValueType` is set only for a scalar built-in type:

| OPC UA type | `edgexValueType` |
| ----------- | ---------------- |
| Boolean | Bool |
| SByte | Int8 |
| Byte | Uint8 |
| Int16 | Int16 |
| UInt16 | Uint16 |
| Int32 | Int32 |
| UInt32 | Uint32 |
| Int64 | Int64 |
| UInt64 | Uint64 |
| Float | Float32 |
| Double | Float64 |
| String | String |
| ByteString | Binary |

Structures, enumerations, and arrays omit `edgexValueType`.

When `truncated` is `true`, repeat the same `nodeId` with `continuationToken` before opening a child. An object is requested again to list its children. A variable is a leaf for this walk.

If the shared session is replaced, a `continuationToken` from the previous session returns `409`. Repeat the same `nodeId` without the token.

### Errors

Errors use the EdgeX `BaseResponse` body.

| Status | When |
| ------ | ---- |
| `400` | `depth` is set, `nodeId` or `maxNodes` or `nodeClass` or `continuationToken` is invalid, or a protocol property is present and not a string. |
| `404` | The device is unknown, or the device has no OPC UA endpoint. |
| `409` | The continuation point is unknown, or it belongs to a session that is no longer current. |
| `502` | The OPC UA call failed, including a transport error. A transport error drops the shared session. |

### Example

The pre-defined device in `cmd/res/devices/Simple-Devices.yaml` is `SimulationServer`. `Constant` in `cmd/res/profiles/OpcuaServer.yaml` is `ns=3;i=1001`.

```shell
curl -fsS "http://localhost:59997/api/v3/opcua/device/SimulationServer/browse"
curl -fsS --get "http://localhost:59997/api/v3/opcua/device/SimulationServer/browse" \
  --data-urlencode "nodeId=ns=3;i=1001"
```

A response has this shape. Node ids come from the server being browsed.

```json
{
  "deviceName": "SimulationServer",
  "startNodeId": "i=85",
  "namespaces": [
    "http://opcfoundation.org/UA/"
  ],
  "truncated": false,
  "continuationToken": "",
  "references": [
    {
      "parentNodeId": "i=85",
      "nodeId": "ns=3;i=1001",
      "browseName": "3:Constant",
      "displayName": "Constant",
      "nodeClass": "Variable",
      "referenceType": "HasComponent",
      "dataType": "Double",
      "dataTypeId": "i=11",
      "valueRank": -1,
      "accessLevel": "R",
      "edgexValueType": "Float64"
    }
  ]
}
```
