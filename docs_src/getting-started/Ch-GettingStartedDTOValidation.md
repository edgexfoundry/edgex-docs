# DTO Validation

The [go-mod-core-contracts](https://github.com/edgexfoundry/go-mod-core-contracts/) leverage the  [go-playground/validator](https://github.com/go-playground/validator/) as DTO validator because it provide common validation function and custom mechanism.

## Tag usage
EdgeX verify the struct fields by using go-playground/validator validation tags or custom validation tags, for [example](https://github.com/edgexfoundry/go-mod-core-contracts/blob/main/dtos/device.go):
```
type Device struct {
	DBTimestamp    `json:",inline"`
	Id             string                        `json:"id,omitempty" validate:"omitempty,uuid"`
	Name           string                        `json:"name" validate:"required,edgex-dto-none-empty-string,edgex-dto-rfc3986-unreserved-chars"`
	Description    string                        `json:"description,omitempty"`
	AdminState     string                        `json:"adminState" validate:"oneof='LOCKED' 'UNLOCKED'"`
	OperatingState string                        `json:"operatingState" validate:"oneof='UP' 'DOWN' 'UNKNOWN'"`
	...
}
```
The device name field contains the following validation:

- **required** validation tag checks the value that is not zero value, empty string, or nil
- **edgex-dto-none-empty-string** validation tag trim white spaces and checks the value that is not the empty string
- **edgex-dto-rfc3986-unreserved-chars** validation tag checks the value that does not contain reserved chars

You can find more validations in the [go-playground/validator](https://pkg.go.dev/github.com/go-playground/validator/v10) and EdgeX custom validations in the [go-mod-core-contracts](https://github.com/edgexfoundry/go-mod-core-contracts/blob/main/common/validator.go).

## Character restriction
The EdgeX uses the custom validation **edgex-dto-rfc3986-unreserved-chars** to prevent the user input the reserved characters.

This validation allows the following kind of characters:

- alphabet: a-z, A-Z
- digital number: 0-9
- special character: - _ ~ : ; =

!!! note
    We need to reduce the character restriction for some use cases:

     - In BACNet protocol, the user might combine object type and property as the resourceName, for example, analog_input_0:present-value
     - In OPC_UA protocol, the user might use NodeId as the resourceName, for example, ns=10;s=Hello:World

## How to add new validation
To add a new validation, we need to create the **validation function** and register to validator with specified **tag** in the [**init function**](https://github.com/edgexfoundry/go-mod-core-contracts/blob/adffc7ef9ef0bd2f646481272fdfdab5b72de8fe/common/validator.go#L46):
```
func init() {
	val = validator.New()
	_ = val.RegisterValidation(dtoDurationTag, ValidateDuration)
	_ = val.RegisterValidation(dtoUuidTag, ValidateDtoUuid)
	_ = val.RegisterValidation(dtoNoneEmptyStringTag, ValidateDtoNoneEmptyString)
	_ = val.RegisterValidation(dtoValueType, ValidateValueType)
	_ = val.RegisterValidation(dtoRFC3986UnreservedCharTag, ValidateDtoRFC3986UnreservedChars)
	_ = val.RegisterValidation(dtoInterDatetimeTag, ValidateIntervalDatetime)
	_ = val.RegisterValidation(dtoNoReservedCharTag, ValidateDtoNoReservedChars)
}
```
