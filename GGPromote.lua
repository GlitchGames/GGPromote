-- Project: GGPromote
--
-- Date: October 26, 2012
--
-- Version: 0.1
--
-- File name: GGPromote.lua
--
-- Author: Graham Ranson of Glitch Games - www.glitchgames.co.uk
--
-- Update History:
--
-- 0.1 - Initial release
--
-- Comments: 
-- 
--		GGPromote makes it very easy to retrieve accurate information on yours, or your 
--		friends, apps and games in order to display them in your own as a way of cross
--		promotion. GGPromote does not do any of the display as I decided to leave that
--		up to you but it would be very easy.
--
--		Sample apps and data can be seen here: http://www.glitchgames.co.uk/ggPromote/
--		
--
-- Copyright (C) 2012 Graham Ranson, Glitch Games Ltd.
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy of this 
-- software and associated documentation files (the "Software"), to deal in the Software 
-- without restriction, including without limitation the rights to use, copy, modify, merge, 
-- publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons 
-- to whom the Software is furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all copies or 
-- substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
-- INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR 
-- PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE 
-- FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR 
-- OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
-- DEALINGS IN THE SOFTWARE.
--
----------------------------------------------------------------------------------------------------

local GGPromote = {}
local GGPromote_mt = { __index = GGPromote }

local open = io.open
local close = io.close

local json = require( "json" )
local decode = json.decode

--- Initiates a new GGPromote object.
-- @param url The url to where everything is stored.
-- @param dataFile The name of the file that contains all the app data.
-- @param baseDir The base directory for the file. Optional, defaults to system.DocumentsDirectory.
-- @return The new object.
function GGPromote:new( url, dataFile, baseDir )
    
    local self = {}
    
    setmetatable( self, GGPromote_mt )
    
    self.apps = {}
    self.url = url
    self.filename = dataFile
    self.loadedImages = {}
    self.baseDir = system.DocumentsDirectory or baseDir
    
    return self
    
end

--- Deletes all local data and reloads everything again.
-- @param onComplete Listener function to be called when the refresh is complete. Optional.
function GGPromote:refresh( onComplete )
	
	self:clear()
	
	-- Load apps from downloaded file
	local loadLocalFile = function()
	
		local path = system.pathForFile( self.filename, self.baseDir )
	
		local file = open( path, "r" )
		if file then
			self.apps = decode( file:read( "*a" ) )
			close( file )
		end
		
		if onComplete then
			onComplete( false )
		end
		
	end
	
	local downloadListener = function( event )
        if event.isError then
            if onComplete then
				onComplete( true )
			end  
        else
            loadLocalFile()
        end
	end

	if self.baseDir == system.ResourceDirectory then	
		loadLocalFile()
    else
    	-- Download the apps file
		network.download( self.url .. self.filename, "GET", downloadListener, self.filename, self.baseDir )
    end
    
end

--- Gets the list of all apps currently stored locally.
-- @return The apps list. Nil if none found.
function GGPromote:getApps()
	return self.apps
end

--- Gets the data for a specific app stored locally.
-- @param id The id of the app as declared in the data file.
-- @return The app data. Nil if none found.
function GGPromote:getApp( id )
	for i = 1, #self.apps, 1 do
		if self.apps[ i ].id == id then
			return self.apps[ i ]
		end
	end
end


--- Gets a named URL from an app.
-- @param idOrApp The id of the app as declared in the data file or the app data table itself.
-- @param name The name of the URL.
-- @return The URL. Nil if none found.
function GGPromote:getAppUrl( idOrApp, name )
	
	local app = idOrApp
	if type( app ) == "number" then
		app = self:getApp( app )
	end
	
	if app then
		if app.urls then
			return app.urls[ name ]
		end
	end
	
end

--- Gets a named price from an app.
-- @param idOrApp The id of the app as declared in the data file or the app data table itself.
-- @param name The country/name of the price.
-- @return The price. Nil if none found.
function GGPromote:getAppPrice( idOrApp, country )
	
	local app = idOrApp
	if type( app ) == "number" then
		app = self:getApp( app )
	end
	
	if app then
		if app.prices then
			return app.prices[ country ]
		end
	end
	
end

--- Downloads an icon and creates a display object.
-- @param idOrApp The id of the app as declared in the data file or the app data table itself.
-- @param size The size of the icon.
-- @param onComplete Listener function to be called when the download is complete, will be called with 2 params; the displayObject and the local filename. Optional.
function GGPromote:loadAppIcon( idOrApp, size, onComplete )
	
	local app = idOrApp
	if type( app ) == "number" then
		app = self:getApp( app )
	end
	
	if app then
		
		local icons = app.icons
		
		if icons and icons[ size ] then
			
			local filename = "app" .. app.id .. "-icon" .. size .. ".png"
			
			local downloadListener = function( event )
	
				if onComplete then
					onComplete( event.target, system.pathForFile( filename, self.baseDir ) )
				end
			
			end
		
			if self.baseDir == system.ResourceDirectory then
				onComplete( { target = display.newImage( icons[ size ], self.baseDir ) } )		
			else
				display.loadRemoteImage( self.url .. icons[ size ], "GET", downloadListener, filename, self.baseDir )
				self.loadedImages[ #self.loadedImages + 1 ] = filename
			end
			
		end
		
	end
	
end


--- Downloads an image and creates a display object.
-- @param idOrApp The id of the app as declared in the data file or the app data table itself.
-- @param size The name of the image.
-- @param onComplete Listener function to be called when the download is complete, will be called with 2 params; the displayObject and the local filename. Optional.
function GGPromote:loadAppImage( idOrApp, name, onComplete )

	local app = idOrApp
	if type( app ) == "number" then
		app = self:getApp( app )
	end
	
	if app then
		
		local images = app.images
		
		if images and images[ name ] then
			
			local filename = "app" .. app.id .. "-" .. name .. ".png"
			
			local downloadListener = function( event )
	
				if onComplete then
					onComplete( event.target, system.pathForFile( filename, self.baseDir ) )
				end
			
			end
		
			if self.baseDir == system.ResourceDirectory then
				onComplete( { target = display.newImage( images[ name ], self.baseDir ) } )		
			else
				display.loadRemoteImage( self.url .. images[ name ], "GET", downloadListener, filename, self.baseDir )
				self.loadedImages[ #self.loadedImages + 1 ] = filename
			end
			
		end
		
	end
	
end

--- Clears this GGPromote object and removes all local files.
function GGPromote:clear()
	
	if self.baseDir ~= system.ResourceDirectory then
		os.remove( system.pathForFile( self.filename, self.baseDir ) )
	end
	for i = 1, #self.loadedImages, 1 do
		os.remove( system.pathForFile( self.loadedImages[ i ], self.baseDir ) )
	end
	
	self.apps = {}
	self.loadedImages = {}
	
end

--- Destroys this GGPromote object.
function GGPromote:destroy()
	self.apps = nil
	self.loadedImages = nil
end

return GGPromote