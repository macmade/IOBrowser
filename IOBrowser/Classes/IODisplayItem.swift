/*******************************************************************************
 * The MIT License (MIT)
 * 
 * Copyright (c) 2021 Jean-David Gadina - www.xs-labs.com
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 ******************************************************************************/

import Cocoa

public class IODisplayItem: NSObject
{
    @objc public private( set ) dynamic var object:     IOObject
    @objc public private( set ) dynamic var name:       String
    @objc public private( set ) dynamic var icon:       NSImage?
    @objc public private( set ) dynamic var children:   [ IODisplayItem ]
    @objc public private( set ) dynamic var properties: [ PropertyListNode ]
    
    public static var all: [ IODisplayItem ]
    {
        [
            IODisplayItem( object: IOObject( plane: kIOServicePlane    ), name: "Service",     icon: NSImage( named: "StackTemplate" ) ),
            IODisplayItem( object: IOObject( plane: kIOPowerPlane      ), name: "Power",       icon: NSImage( named: "StackTemplate" ) ),
            IODisplayItem( object: IOObject( plane: kIODeviceTreePlane ), name: "Device Tree", icon: NSImage( named: "StackTemplate" ) ),
            IODisplayItem( object: IOObject( plane: kIOAudioPlane      ), name: "Audio",       icon: NSImage( named: "StackTemplate" ) ),
            IODisplayItem( object: IOObject( plane: kIOFireWirePlane   ), name: "FireWire",    icon: NSImage( named: "StackTemplate" ) ),
            IODisplayItem( object: IOObject( plane: kIOUSBPlane        ), name: "USB",         icon: NSImage( named: "StackTemplate" ) )
        ]
        .compactMap { $0 }
    }
    
    public convenience init?( object: IOObject? )
    {
        guard let object = object else
        {
            return nil
        }
        
        self.init( object: object, name: object.name, icon: NSImage( named: object.children.count == 0 ? "DocumentTemplate" : "FolderTemplate" ) )
    }
    
    public init?( object: IOObject?, name: String, icon: NSImage? )
    {
        guard let object = object else
        {
            return nil
        }
        
        self.object     = object
        self.name       = name
        self.icon       = icon
        self.children   = object.children.compactMap { IODisplayItem( object: $0 ) }
        self.properties = object.properties.map { PropertyListNode( key: $0.key, propertyList: $0.value ) }
    }
}
