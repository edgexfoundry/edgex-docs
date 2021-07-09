# Pipeline Function Error Handling

Each transform returns a `true` or `false` as part of the return signature. This is called the `continuePipeline` flag and indicates whether the SDK should continue calling successive transforms in the pipeline.

- `return false, nil` will stop the pipeline and stop processing the event. This is useful, for example, when filtering on values and nothing matches the criteria you've filtered on. 
- `return false, error`, will stop the pipeline as well and the SDK will log the error you have returned.
- `return true, nil` tells the SDK to continue, and will call the next function in the pipeline with your result.

The SDK will return control back to main when receiving a SIGTERM/SIGINT event to allow for custom clean up.

