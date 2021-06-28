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

public class PropertiesViewController: NSViewController
{
    @objc private dynamic var item:       IODisplayItem
    @objc private dynamic var properties: [ PropertyListNode ]
    @objc private dynamic var searchText: String?
    {
        didSet
        {
            self.filter( text: self.searchText )
        }
    }
    
    @IBOutlet private               var treeController: NSTreeController!
    @IBOutlet private               var outlineView:    NSOutlineView!
    @IBOutlet public private( set ) var searchField:    NSSearchField!
    
    init( item: IODisplayItem )
    {
        self.item       = item
        self.properties = item.properties
        
        super.init( nibName: nil, bundle: nil )
    }
    
    required init?( coder: NSCoder )
    {
        nil
    }
    
    public override var nibName: NSNib.Name?
    {
        "PropertiesViewController"
    }
    
    public override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.treeController.sortDescriptors =
        [
            NSSortDescriptor( key: "key", ascending: true, selector: #selector( NSString.localizedCaseInsensitiveCompare( _: ) ) )
        ]
    }
    
    @objc public func performFindPanelAction( _ sender: Any? )
    {
        self.view.window?.makeFirstResponder( self.searchField )
    }
    
    @objc private func expandAll()
    {
        self.outlineView.expandItem( nil, expandChildren: true )
    }
    
    @objc private func collapseAll()
    {
        self.outlineView.collapseItem( nil, collapseChildren: true )
    }
    
    private func filter( text: String? )
    {
        self.collapseAll()
        
        let predicate: NSPredicate? =
        {
            guard let text = text, text.count > 0 else
            {
                return nil
            }
            
            return NSPredicate( format: "key contains[c] %@", text )
        }()
        
        self.item.properties.forEach { $0.predicate = predicate }
        
        if let predicate = predicate
        {
            self.properties = self.item.properties.filter
            {
                $0.children.count > 0 || predicate.evaluate( with: $0 )
            }
            
            self.expandAll()
        }
        else
        {
            self.properties = self.item.properties
            
            self.collapseAll()
        }
    }
}
