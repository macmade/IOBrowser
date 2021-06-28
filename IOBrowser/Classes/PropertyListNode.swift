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

public class PropertyListNode: NSObject
{
    @objc public private( set ) dynamic var key:          String
    @objc public private( set ) dynamic var value:        String
    @objc public private( set ) dynamic var type:         String
    @objc public private( set ) dynamic var propertyList: Any?
    @objc public private( set ) dynamic var textColor:    NSColor
    @objc public private( set ) dynamic var allChildren = [ PropertyListNode ]()
    @objc public private( set ) dynamic var children    = [ PropertyListNode ]()
    
    private static var dateFormatter: DateFormatter
    {
        let formatter = DateFormatter()
        
        formatter.dateStyle                  = .full
        formatter.timeStyle                  = .medium
        formatter.doesRelativeDateFormatting = false
        
        return formatter
    }
    
    public init( key: String, propertyList: Any? )
    {
        let info          = PropertyListNode.info( for: propertyList )
        self.key          = key
        self.type         = info.type
        self.value        = info.value
        self.propertyList = propertyList
        self.textColor    = NSColor.controlTextColor
        
        super.init()
        
        if let array = propertyList as? NSArray
        {
            var i = 0
            
            array.forEach
            {
                self.addChild( key: "Item \( i )", propertyList: $0 )
                
                i += 1
            }
            
            self.textColor = NSColor.secondaryLabelColor
        }
        else if let set = propertyList as? NSOrderedSet
        {
            var i = 0
            
            set.forEach
            {
                self.addChild( key: "Item \( i )", propertyList: $0 )
                
                i += 1
            }
            
            self.textColor = NSColor.secondaryLabelColor
        }
        else if let set = propertyList as? NSSet
        {
            var i = 0
            
            set.forEach
            {
                self.addChild( key: "Item \( i )", propertyList: $0 )
                
                i += 1
            }
            
            self.textColor = NSColor.secondaryLabelColor
        }
        else if let dict = propertyList as? NSDictionary
        {
            dict.forEach { self.addChild( key: "\( $0.key )", propertyList: $0.value ) }
            
            self.textColor = NSColor.secondaryLabelColor
        }
        else if let tuple = propertyList as? ( Any, [ AnyHashable : Any ] )
        {
            let info   = PropertyListNode.info( for: tuple.0 )
            self.type  = info.type
            self.value = info.value
            
            tuple.1.forEach { self.addChild( key: "\( $0.key )", propertyList: $0.value ) }
            
            self.textColor = NSColor.secondaryLabelColor
        }
        else if let tuple = propertyList as? ( Any, [ Any ] )
        {
            let info   = PropertyListNode.info( for: tuple.0 )
            self.type  = info.type
            self.value = info.value
            var i      = 0
            
            tuple.1.forEach
            {
                self.addChild( key: "Item \( i )", propertyList: $0 )
                
                i += 1
            }
            
            self.textColor = NSColor.secondaryLabelColor
        }
    }
    
    private class func info( for propertyList: Any? ) -> ( type: String, value: String )
    {
        if let str = propertyList as? String
        {
            return (
                type:  "String",
                value: str
            )
        }
        else if let bool = propertyList as? Bool
        {
            return (
                type:  "Boolean",
                value: bool ? "True" : "False"
            )
        }
        else if let num = propertyList as? NSNumber
        {
            return (
                type:  "Number",
                value: num.stringValue
            )
        }
        else if let data = propertyList as? Data
        {
            return (
                type:  "Data",
                value: data.base64EncodedString()
            )
        }
        else if let date = propertyList as? Date
        {
            return (
                type:  "Date",
                value: PropertyListNode.dateFormatter.string( from: date )
            )
        }
        else if let url = propertyList as? URL
        {
            return (
                type:  "URL",
                value: url.absoluteString
            )
        }
        else if let uuid = propertyList as? UUID
        {
            return (
                type:  "UUID",
                value: uuid.uuidString
            )
        }
        else if let array = propertyList as? NSArray
        {
            return (
                type:  "Array",
                value: "\( array.count ) Items"
            )
        }
        else if let set = propertyList as? NSOrderedSet
        {
            return (
                type:  "Ordered Set",
                value: "\( set.count ) Items"
            )
        }
        else if let set = propertyList as? NSSet
        {
            return (
                type:  "Set",
                value: "\( set.count ) Items"
            )
        }
        else if let dict = propertyList as? NSDictionary
        {
            return (
                type:  "Dictionary",
                value: "\( dict.count ) Items"
            )
        }
        else if let unknown = propertyList
        {
            return (
                type:  "Unknown",
                value: "\( unknown )"
            )
        }
        else
        {
            return (
                type:  "Unknown",
                value: "<nil>"
            )
        }
    }
    
    public var predicate: NSPredicate?
    {
        didSet
        {
            self.filter( predicate: self.predicate )
        }
    }
    
    private func filter( predicate: NSPredicate? )
    {
        self.allChildren.forEach { $0.predicate = predicate }
        
        guard let predicate = predicate else
        {
            self.children = self.allChildren
            
            return
        }
        
        self.children = self.allChildren.compactMap
        {
            predicate.evaluate( with: $0 ) || $0.children.count > 0 ? $0 : nil
        }
    }
    
    @discardableResult
    private func addChild( key: String, propertyList: Any? ) -> PropertyListNode
    {
        let child = PropertyListNode( key: key, propertyList: propertyList )
        
        self.allChildren.append( child )
        self.children.append( child )
        
        return child
    }
}
