GGPromote
============

GGPromote makes it very easy to retrieve accurate information on yours, or your 
friends, apps and games in order to display them in your own as a way of cross
promotion. GGPromote does not do any of the display as I decided to leave that
up to you but it would be very easy.

Sample apps and data can be seen here: http://www.glitchgames.co.uk/ggPromote/


Basic Usage
-------------------------

##### Require the code
```lua
local GGPromote = require( "GGPromote" )
```

##### Create your promotion object
```lua
local promote = GGPromote:new( "http://www.glitchgames.co.uk/ggPromote/", "appData.json" )
```

##### Refresh the locally stored data from the web
```lua
local onComplete = function( isError ) 
	if not isError then
		print( "Apps loaded" )
	end
end

promote:refresh( onComplete )
```

##### Get a specific app
```lua
local app = promote:getApp( 23 )	
print( app.name )
```

##### Get all apps
```lua
local apps = promote:getApps()
for i = 1, #apps, 1 do
	print( apps[ i ].name )
end
```

##### Load an apps icon
```lua
local onIconDownload = function( image, filename )
	image.x = display.contentCenterX
	image.y = display.contentCenterY
end

promote:loadAppIcon( 1, "114", onIconDownload )
```

##### Get some urls from the app
```lua
local itunes = promote:getAppUrl( 1, "appStore" )
local google = promote:getAppUrl( 1, "googlePlay" )
local website = promote:getAppUrl( 1, "website" )
```

##### Destroy the promotion object
```lua
promote:destroy()
promote = nil
```

Update History
-------------------------

##### 0.1
Initial release