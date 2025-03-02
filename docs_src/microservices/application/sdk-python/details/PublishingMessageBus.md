---
title: App SDK - Publishing data to EdgeX MessageBus
---

# App Functions SDK for Python - Publishing data to EdgeX MessageBus

The Background Publishing capability has been deprecated in EdgeX 3.1 and will be removed in the next major release, so the app_functions_sdk_py doesn't support the deprecated Background Publishing.  Instead, use either [Service publish/publish_with_topic](../api/ApplicationServiceAPI.md#publish) or [Context publish/publish_with_topic](../api/AppFunctionContextAPI.md#publish) APIs:

```python
from typing import Any, Tuple
from app_functions_sdk_py.contracts import errors
from app_functions_sdk_py.interfaces import AppFunctionContext

def sample_publisher(ctx: AppFunctionContext) -> Tuple[bool, Any]:
    """
    sample code to use AppFunctionContext.publish and publish_with_topic APIs to publish json message to message bus
    """
    try:
        # publish json message to message bus through the topic as configured in Trigger/PublishTopic 
        ctx.publish('{ "test" : "hello world" }', "application/json")
        # publish json message to message bus through the topic "edgex/test"
        ctx.publish_with_topic("test", '{ "foo" : "bar" }', "application/json")
    except Exception as e:
        return False, errors.new_common_edgex(errors.ErrKind.CONTRACT_INVALID,f"sample_publisher: {e}")
    return True, None
```

!!! note
    As all messages published to the EdgeX MessageBus needs to be wrapped in a MessageEnvelope, use Service or Context publish/publish_with_topic APIs will also wrap the data as MessageEnvelope.
