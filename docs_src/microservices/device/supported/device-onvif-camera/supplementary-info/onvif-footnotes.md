
## Command Support
### Tapo C200 - User Management
Tapo returns `200 OK` for all User Management commands, but none of them actually
do anything. The only way to modify the users is through the Tapo app.

### Tapo C200 - SetSystemDateAndTime
Tapo does not support setting the `DaylightSavings` field to `false`. Regardless of the setting, the camera will always use daylight savings time.

### Bosch - GetSnapshot
You must use `Digest Auth` or `Both` as the Auth-Mode in order for this to work.


