# EdgeX Unit of Measure for Device Resources

## Status
Proposed (as of 5/25/21)
Per [Monthly Architect's meeting of 5/17/21](https://wiki.edgexfoundry.org/display/FA/Monthly+Architects%27+Meeting)
Proposed for Jakarta or later release

## Context
Unit of measurement (or measure for short) is defined as "a standard amount of a physical quantity, such as length, mass, energy, etc, specified multiples of which are used to express magnitudes of that physical quantity" (see https://www.collinsdictionary.com/us/dictionary/english/unit-of-measurement).  In EdgeX, data collected from sensors are physical quantities which should be associated to some unit of measure to express magnitude of that physical quantity.  For example, if EdgeX collected a temperature reading from a thermostat as 45, the user of that sensor reading would want to know if the unit of measure for the 45 quantity was Celcius or Farenheit.

Since the founding of the project, there has been concensus that a unit of measure must be associated to any sensor or metric quantity collected by EdgeX.  Also since the founding of the project, a unit of measure has therefore been specified (directly or indirectly) to each device resource (found in Device Profiles) and associated Reading values collected as part of Event/Readings.

The unit of measure was, however, in all cases just a string reference to some non-standard unit of measure to be interpreted by the consumer of EdgeX data.  The reporting sensor/device (if provided by the sensor/device) or programmer of the device service could choose what string was associated to the device resources (and Readings produced by the device service) as the unit of measure for any piece of data.  Per the temperature example above, the unit of measure could have been "F" or "C", "Celcius" or "Farenheit", or any other representation.  In other words, the associated unit of measure for all data in EdgeX was left to agreement and interpretation by the data provider/producer and EdgeX data consumer.

There are various specifications and standards around unit of measure.  Specifically, there are several options to choose from as it relates to the exchange of data in electronic communications - and units of measure associated in that exchange.  As examples, two big competing standards around EDI (electronic data exchange) that both have associated unit of measure codes are:

- [ANSI X12: EDI standard used mostly in the US](https://ediacademy.com/blog/x12-unit-of-measurement-codes/)
- [EDIFACT: UN EDI standard used mostly in Europe and Asia](https://unece.org/fileadmin/DAM/cefact/recommendations/rec20/rec20_rev3_Annex2e.pdf)

The [Unified Code for Units of Measure](https://en.wikipedia.org/wiki/Unified_Code_for_Units_of_Measure) provides an alternative list (not a standard) that is used by various organizations like OSGI and the Eclipse Foundatin.

While standards exist, use by various open source projects (especially IoT/edge projects) is inconsistent and haphazard.   Groups like oneM2M seem to define their own selection of units in specifications per vertical (home for example) while Kura doesn't even appear to use the UoM JSR (a Java related unit of measure specification for Java applications like Kura).

## Decision
It would be speculative and inappropriate for EdgeX to select a unit of measure which is not widely adopted in the industry or choose a static unit of measure list that is incomplete with regard to possible IoT / edge use case needs.

Therefore, EdgeX chooses not to select or adopt a unit of measure specification, standard, or code list to apply across the platform.  Instead, EdgeX adopters will be allowed to optionally specify which unit of measure specification, standard, or unit of measure code list they would like applied and understood to be represented by values in EdgeX.

### Specifying Unit of Measure per Device Resource
Currently, units is a string on [ResourceProperties](https://github.com/edgexfoundry/go-mod-core-contracts/blob/352324e9c8b8d76ffd6147dc5ec2da6dd8f275fd/v2/dtos/resourceproperties.go#L15).  Going forward, and to assist in backward compatiblity, the units property would remain in place and specify the unit of measure value.  A new optional EdgeX property will be optionally associated to each device resource to stipulate which unit of measure standard (or specification, code list, etc.) is applied to the unit of measure of the device resource.

For example, if the device resource for temperature was specified in a device profile as show below, the unit of measure would still be specified by the units property (specifying the Cel as the unit of measure) and adding the optional units_standard (to specify that the unit of measure is from the Unified Code for Units of Measure).

``` YAML
-
  name: "RoomTemperature"
  isHidden: false
  description: "Room Temperature x10 °C (Read Only)"
  attributes:
    { primaryTable: "INPUT_REGISTERS", startingAddress: 3 }
  properties:
    valueType: "Float32"
    readWrite: "R"
    scale: "1"
  units: "Cel"
  units_standard: "UCUM"
```
   
The unit of measure standard would be specified as a string in the device profile.  Note each device resource could specify a different unit of measure standard.  

### Validation

Initially, EdgeX would not validate the existence of the specification or standard used to specify the unit of measures.  Nor would EdgeX validate that the unit of measure value is a valid unit of measure per that specification.  The unit of measure specification is provided as additional (and optional) information which can be utilized in a way seen fit by the adopter.

EdgeX may, in the future, provide a means to trigger validation of the unit of measure specification and of the unit of measures per that specification.  Doing so would require that EdgeX also have information about where to validate the specification's existence and valid units of measure (presumably a REST URL or other such confirmation site).

In theory, the unit of measure could be validated on the "indbound" collection of the data (likely in a device service), on the "outbound" export of the data from EdgeX (likely in an application service), or in multiple locations if warranted.

## Considersations

It has been suggested that EdgeX borrow from the Open [Geospatial Consortium SensorThings](https://www.ogc.org/standards/sensorthings) standard and include a JSON object to provide more information about the UoM for the field.  An optional  unitOfMeasurement field would replace the optional units_standard in above (allowing for either standard or non-standard definitions but with more information).

A JSON Object containing three key-value pairs. The name property presents the full name of the unitOfMeasurement; the symbol property shows the textual form of the unit symbol; and the definition contains the URI defining the unitOfMeasurement.

From Example 4: A Datastream entity example:

"unitOfMeasurement": {
    "name": "degree Celsius",
    "symbol": "°C",
    "definition": "http://unitsofmeasure.org/ucum.html#para-30"
}

See https://docs.ogc.org/is/18-088/18-088.html#datastream

## Consequences
- Any validation could impact performance.
- As with most validation, it should be configured to turn on or off by use case circumstances or trust of data providers.
- Some unit of measures may need to be linked to some sort of group affilation or geo local.  For example, if an EdgeX instance was operating in the US, someone might want all distance measurements done in feet/inches, temperatures in Farenheit, and volume in gallons.  The concept of group or affiliation will be not part of the initial efforts to satisfy UoM association.

## References

### UoM Standards

- https://ediacademy.com/blog/x12-unit-of-measurement-codes/
- https://unece.org/fileadmin/DAM/cefact/recommendations/rec20/rec20_rev3_Annex2e.pdf
- https://en.wikipedia.org/wiki/Unified_Code_for_Units_of_Measure
- https://www.ogc.org/standards/sensorthings

### UoM Tools and Databases
- https://ucum.nlm.nih.gov/ucum-lhc/demo.html
- https://project-haystack.org/doc/Units
- https://github.com/fantom-lang/fantom/blob/master/etc/sys/units.txt
- https://gs1.github.io/UnitConverterUNECERec20/