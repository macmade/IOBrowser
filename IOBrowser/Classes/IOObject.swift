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

import Foundation
import CoreFoundation
import IOKit

@objc public class IOObject: NSObject
{
    public static func root( completion: @escaping ( IOObject? ) -> Void )
    {
        DispatchQueue.global( qos: .userInitiated ).async
        {
            var port: mach_port_t = 0
            
            if IOMasterPort( UInt32( MACH_PORT_NULL ), &port ) != KERN_SUCCESS
            {
                completion( nil )
                
                return
            }
            
            let service = IORegistryGetRootEntry( port )
            
            if service == MACH_PORT_NULL
            {
                completion( nil )
                
                return
            }
            
            let object = IOObject( entry: service, plane: kIOServicePlane )
            
            IOObjectRelease( service )
            completion( object )
        }
    }
    
    @objc public private( set ) dynamic var name:       String
    @objc public private( set ) dynamic var children:   [ IOObject ]     = []
    @objc public private( set ) dynamic var properties: [ String : Any ] = [:]
    
    private init?( entry: io_registry_entry_t, plane: String )
    {
        let name = UnsafeMutablePointer< CChar >.allocate( capacity: 128 )
        
        if IORegistryEntryGetNameInPlane( entry, plane, name ) != KERN_SUCCESS
        {
            return nil
        }
        
        self.name = String( cString: name )
        
        var properties: Unmanaged< CFMutableDictionary >?
        
        if IORegistryEntryCreateCFProperties( entry, &properties, kCFAllocatorDefault, 0 ) == KERN_SUCCESS
        {
            if let properties = properties?.takeRetainedValue()
            {
                self.properties = properties as? [ String : Any ] ?? [:]
            }
        }
        
        var children: io_iterator_t = 0
        
        if IORegistryEntryGetChildIterator( entry, plane, &children ) == KERN_SUCCESS
        {
            var next = IOIteratorNext( children )
            
            while next != 0
            {
                if let child = IOObject( entry: next, plane: plane )
                {
                    self.children.append( child )
                }
                
                IOObjectRelease( next )
                
                next = IOIteratorNext( children )
            }
            
            IOObjectRelease( children )
        }
    }
    
    public override var description: String
    {
        "\( super.description ): \( self.name )"
    }
}
