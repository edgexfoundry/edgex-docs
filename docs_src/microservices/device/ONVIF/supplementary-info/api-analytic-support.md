# Analytic Support

The device-onvif-camera implement the Analytic function according to `Onvif Profile M` to manage the Analytics Module and Rule configuration.

The spec can refer to 
- https://www.onvif.org/specs/srv/analytics/ONVIF-Analytics-Service-Spec.pdf 
- https://www.onvif.org/ver20/analytics/wsdl/analytics.wsdl

## Overview
This page uses the `BOSCH DINION IP starlight 6000 HD` as the test camera and used the `BOSCH Configuration Manager` as the camera viewer.
- The product page refer to https://commerce.boschsecurity.com/tw/en/DINION-IP-starlight-6000-HD/p/20827877387/
- The configuration manager can download from https://downloadstore.boschsecurity.com/index.php?type=CM

In the scope of profile M, the device-onvif-camera should be able to manage the `Analytics Module` and `Rule` configuration, we can illustrate the APIs scope as following example:

![api-analytic-support-example](images/api-analytic-support-example.jpg)

For more information, please refer to the Annex D. Radiometry https://www.onvif.org/specs/srv/analytics/ONVIF-Analytics-Service-Spec.pdf

## Manage the Analytics Module Configuration

### Query the Analytics Module

```shell
curl --request GET 'http://0.0.0.0:59882/api/v2/device/name/Camera003/AnalyticsModules?jsonObject=eyJDb25maWd1cmF0aW9uVG9rZW4iOiIxIn0=' | jq .
{
   "apiVersion" : "v2",
   "event" : {
      ...
      "profileName" : "onvif-camera",
      "readings" : [
         {
            ...
            "objectValue" : {
               "AnalyticsModule" : [
                  {
                     "Name" : "Viproc",
                     "Parameters" : {
                        "SimpleItem" : [
                           {
                              "Name" : "Mode",
                              "Value" : "Profile 1"
                           },
                           {
                              "Name" : "AnalysisType",
                              "Value" : "Intelligent Video Analytics"
                           }
                        ]
                     },
                     "Type" : "tt:Viproc"
                  }
               ]
            },
         }
      ],
      "sourceName" : "AnalyticsModules"
   },
   "statusCode" : 200
}
```

**Note**: The jsonObject parameter is encoded from `{"ConfigurationToken": "{ANALYTIC_CONFIG_TOKEN}"}`

![query-analytics-module](images/api-analytic-support-query-analytics-module.jpg)

### Query the Supported Analytics Module and Options

```shell
curl --request GET 'http://0.0.0.0:59882/api/v2/device/name/Camera003/GetSupportedAnalyticsModules' | jq .
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   692  100   692    0     0   2134      0 --:--:-- --:--:-- --:--:--  2217
{
   "apiVersion" : "v2",
   "event" : {
      ...
      "readings" : [
         {
            "deviceName" : "Camera003",
            "id" : "70545263-30e7-4c03-9741-0011300f2f9c",
            "objectValue" : {
               "SupportedAnalyticsModules" : {
                  "AnalyticsModuleDescription" : [
                     {
                        "Fixed" : true,
                        "MaxInstances" : 1,
                        "Name" : "tt:Viproc",
                        "Parameters" : {
                           "SimpleItemDescription" : [
                              {
                                 "Name" : "Mode",
                                 "Type" : "xs:string"
                              },
                              {
                                 "Name" : "AnalysisType",
                                 "Type" : "xs:string"
                              }
                           ]
                        }
                     }
                  ]
               }
            },
         }
      ],
      "sourceName" : "GetSupportedAnalyticsModules"
   },
   "statusCode" : 200
}
```
```shell
curl --request GET 'http://0.0.0.0:59882/api/v2/device/name/Camera003/GetAnalyticsModuleOptions?jsonObject=eyJDb25maWd1cmF0aW9uVG9rZW4iOiIxIn0=' | jq .
{
   "apiVersion" : "v2",
   "event" : {
      "deviceName" : "Camera003",
      "profileName" : "onvif-camera",
      ...
      "readings" : [
         {
            "deviceName" : "Camera003",
            "id" : "43f0e59b-6f3e-4119-978e-299ccd59049d",
            "objectValue" : {
               "Options" : [
                  {
                     "AnalyticsModule" : "tt:Viproc",
                     "Name" : "Mode",
                     "StringItems" : {
                        "Item" : [
                           "Off",
                           "Silent VCA",
                           "Profile 1",
                           "Profile 2",
                           "Scheduled",
                           "Event Triggered"
                        ]
                     }
                  },
                  {
                     "AnalyticsModule" : "tt:Viproc",
                     "Name" : "AnalysisType",
                     "StringItems" : {
                        "Item" : [
                           "MOTION+",
                           "Intelligent Video Analytics"
                        ]
                     }
                  }
               ]
            },
            ...
            "resourceName" : "GetAnalyticsModuleOptions",
            "valueType" : "Object"
         }
      ],
      "sourceName" : "GetAnalyticsModuleOptions"
   },
   "statusCode" : 200
}
```
**Note**: The jsonObject parameter is encoded from `{"ConfigurationToken": "{ANALYTIC_CONFIG_TOKEN}"}`

![query-analytics-module](images/api-analytic-support-query-analytics-module-options-1.jpg)
![query-analytics-module](images/api-analytic-support-query-analytics-module-options-2.jpg)

### Modify the Analytics Module Options

```shell
curl --request PUT 'http://0.0.0.0:59882/api/v2/device/name/Camera003/AnalyticsModules' \
--header 'Content-Type: application/json' \
--data-raw '{
     "AnalyticsModules": {
         "ConfigurationToken": "1",
         "AnalyticsModule": [
                         {
                             "Name": "Viproc",
                             "Type": "tt:Viproc",
                             "Parameters": {
                                 "SimpleItem": [
                                     {
                                         "Name": "Mode",
                                         "Value": "Profile 1"
                                     },
                                     {
                                         "Name": "AnalysisType",
                                         "Value": "Intelligent Video Analytics"
                                     }
                                 ]
                             }
                             
                         }
                     ]
     }
}'
```

## Manage the Rule Configuration

### Query the Rules

```shell
curl --request GET 'http://0.0.0.0:59882/api/v2/device/name/Camera003/Rules?jsonObject=eyJDb25maWd1cmF0aW9uVG9rZW4iOiIxIn0=' | jq .
{
   "apiVersion" : "v2",
   "event" : {
      "apiVersion" : "v2",
      "deviceName" : "Camera003",
      "profileName" : "onvif-camera",
      ...
      "readings" : [
         {
            "deviceName" : "Camera003",
            "id" : "1abea901-ad51-4a55-b9bb-0b00271307df",
            "objectValue" : {
               "Rule" : [
                  {
                     "Name" : "Detect any object",
                     "Parameters" : {
                        "SimpleItem" : [
                           {
                              "Name" : "Armed",
                              "Value" : "true"
                           }
                        ]
                     },
                     "Type" : "tt:ObjectInField"
                  }
               ]
            },
            "origin" : 1639480270526564000,
            "profileName" : "onvif-camera",
            "resourceName" : "Rules",
            "valueType" : "Object"
         }
      ],
      "sourceName" : "Rules"
   },
   "statusCode" : 200
}
```
**Note**: The jsonObject parameter is encoded from `{"ConfigurationToken": "{ANALYTIC_CONFIG_TOKEN}"}`

![query-analytics-module](images/api-analytic-support-query-rules.jpg)

### Query the Supported Rule and Options
```shell
curl --request GET 'http://0.0.0.0:59882/api/v2/device/name/Camera003/GetSupportedRules?jsonObject=eyJDb25maWd1cmF0aW9uVG9rZW4iOiIxIn0=' | jq .
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  9799    0  9799    0     0   9605      0 --:--:--  0:00:01 --:--:--  9740
{
   "apiVersion" : "v2",
   "event" : {
      "apiVersion" : "v2",
      "deviceName" : "Camera003",
      "id" : "07f7b42e-835b-4ecc-97b1-fe4d5f52575b",
      "origin" : 1639482296788863000,
      "profileName" : "onvif-camera",
      "readings" : [
         {
            "deviceName" : "Camera003",
            "id" : "6fca707b-3c52-4694-be37-2e23ecf65de1",
            "objectValue" : {
               "SupportedRules" : {
                  "RuleDescription" : [
                     ....
                     {
                        "MaxInstances" : 16,
                        "Messages" : {
                           "Data" : {
                              "SimpleItemDescription" : [
                                 {
                                    "Name" : "Count",
                                    "Type" : "xs:int"
                                 }
                              ]
                           },
                           "IsProperty" : true,
                           "ParentTopic" : "tns1:RuleEngine/CountAggregation/Counter",
                           "Source" : {
                              "SimpleItemDescription" : [
                                 {
                                    "Name" : "VideoSource",
                                    "Type" : "tt:ReferenceToken"
                                 },
                                 {
                                    "Name" : "Rule",
                                    "Type" : "xs:string"
                                 }
                              ]
                           }
                        },
                        "Name" : "tt:LineCounting",
                        "Parameters" : {
                           "ElementItemDescription" : [
                              {
                                 "Name" : "Segments"
                              }
                           ],
                           "SimpleItemDescription" : [
                              {
                                 "Name" : "Armed",
                                 "Type" : "xs:boolean"
                              },
                              {
                                 "Name" : "Direction",
                                 "Type" : "tt:Direction"
                              },
                              {
                                 "Name" : "MinObjectHeight",
                                 "Type" : "xs:int"
                              },
                              ...
                              {
                                 "Name" : "ClassFilter",
                                 "Type" : "tt:StringList"
                              }
                           ]
                        }
                     }
                  ]
               }
            },
            "origin" : 1639482296788863000,
            "profileName" : "onvif-camera",
            "resourceName" : "GetSupportedRules",
            "valueType" : "Object"
         }
      ],
      "sourceName" : "GetSupportedRules"
   },
   "statusCode" : 200
}
```

```shell
curl --request GET 'http://0.0.0.0:59882/api/v2/device/name/Camera003/GetRuleOptions?jsonObject=eyJDb25maWd1cmF0aW9uVG9rZW4iOiIxIn0=' | jq .
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  1168  100  1168    0     0    755      0  0:00:01  0:00:01 --:--:--   759
{
   "apiVersion" : "v2",
   "event" : {
      "apiVersion" : "v2",
      "deviceName" : "Camera003",
      "id" : "3ac81a5c-48f2-46d7-a3f9-d4919f97ae8d",
      "origin" : 1639482979553667000,
      "profileName" : "onvif-camera",
      "readings" : [
         {
            "deviceName" : "Camera003",
            "id" : "6eae2e16-71f7-4b92-95b6-32e398be25ca",
            "objectValue" : {
               "RuleOptions" : [
                  ...
                  {
                     "MaxOccurs" : "3",
                     "MinOccurs" : "0",
                     "Name" : "Field",
                     "PolygonOptions" : {
                        "VertexLimits" : {
                           "Max" : 16,
                           "Min" : 3
                        }
                     }
                  },
                  {
                     "IntRange" : {
                        "Max" : 16,
                        "Min" : 2
                     },
                     "MaxOccurs" : "3",
                     "MinOccurs" : "1",
                     "Name" : "Segments"
                  },
                  {
                     "Name" : "Direction",
                     "StringList" : "Any Right Left"
                  },
                  {
                     "Name" : "ClassFilter",
                     "StringList" : "Person Bike Car Truck"
                  }
               ]
            },
            "origin" : 1639482979553667000,
            "profileName" : "onvif-camera",
            "resourceName" : "GetRuleOptions",
            "valueType" : "Object"
         }
      ],
      "sourceName" : "GetRuleOptions"
   },
   "statusCode" : 200
}
```

### Add the Rule

```shell
curl --location --request PUT 'http://0.0.0.0:59882/api/v2/device/name/Camera003/CreateRules' \
--header 'Content-Type: application/json' \
--data-raw '{
    "CreateRules": {
        "ConfigurationToken": "1",
        "Rule": [
            {
                "Name": "Object Counting",
                "Type": "tt:LineCounting",
                "Parameters": {
                    "SimpleItem": [
                        {
                            "Name":"Armed", 
                            "Value":"true"
                        }
                    ],
                    "ElementItem": [
                        {
                            "Name":"Segments", 
                            "Polyline": {
                                "Point": [
                                    {
                                        "x":"0.16",
                                        "y": "0.5"
                                    },
                                    {
                                        "x":"0.16",
                                        "y": "-0.5"
                                    }
                                ]
                            }
                        }
                    ]
                }
                    
            }
        ]
    }
}'
```

![add-rule](images/api-analytic-support-add-rule.png)
