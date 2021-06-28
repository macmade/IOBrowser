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

public class MainWindowController: NSWindowController
{
    @objc private dynamic var loading       = true
    @objc private dynamic var objects       = [ IOObject ]()
    @objc private dynamic var selectedObject: IOObject?
    @objc private dynamic var searchText:     String?
    {
        didSet
        {
            print( self.searchText ?? "<nil>" )
        }
    }
    
    @IBOutlet private var treeController: NSTreeController!
    @IBOutlet private var outlineView:    NSOutlineView!
    @IBOutlet private var propertiesView: NSView!
    @IBOutlet private var searchField:    NSSearchField!
    
    private var selectionObserver:        NSKeyValueObservation?
    private var propertiesViewController: PropertiesViewController?
    
    public override var windowNibName: NSNib.Name?
    {
        "MainWindowController"
    }
    
    public override func windowDidLoad()
    {
        super.windowDidLoad()
        
        self.treeController.sortDescriptors =
        [
            NSSortDescriptor( key: "name", ascending: true, selector: #selector( NSString.localizedCaseInsensitiveCompare( _: ) ) )
        ]
        
        self.selectionObserver = self.treeController.observe( \.selectedObjects )
        {
            o, c in
            
            self.selectedObject = self.treeController.selectedObjects.first as? IOObject
            
            self.propertiesView.subviews.forEach { $0.removeFromSuperview() }
            
            if let selected = self.selectedObject
            {
                let controller                                            = PropertiesViewController( object: selected )
                controller.view.translatesAutoresizingMaskIntoConstraints = false
                controller.view.frame                                     = self.propertiesView.bounds
                self.propertiesViewController                             = controller
                
                self.propertiesView.addSubview( controller.view )
                self.propertiesView.addConstraint( NSLayoutConstraint( item: controller.view, attribute: .centerX, relatedBy: .equal, toItem: self.propertiesView, attribute: .centerX, multiplier: 1, constant: 0 ) )
                self.propertiesView.addConstraint( NSLayoutConstraint( item: controller.view, attribute: .centerY, relatedBy: .equal, toItem: self.propertiesView, attribute: .centerY, multiplier: 1, constant: 0 ) )
                self.propertiesView.addConstraint( NSLayoutConstraint( item: controller.view, attribute: .width,   relatedBy: .equal, toItem: self.propertiesView, attribute: .width,   multiplier: 1, constant: 0 ) )
                self.propertiesView.addConstraint( NSLayoutConstraint( item: controller.view, attribute: .height,  relatedBy: .equal, toItem: self.propertiesView, attribute: .height,  multiplier: 1, constant: 0 ) )
            }
            else
            {
                self.propertiesViewController = nil
            }
        }
        
        IOObject.all
        {
            objects in DispatchQueue.main.asyncAfter( deadline: .now() + .seconds( 1 ) )
            {
                self.loading = false
                self.objects = objects
                
                DispatchQueue.main.async
                {
                    self.outlineView.collapseItem( nil, collapseChildren: true )
                    
                    var items = [ Any ]()
                    
                    for i in 0 ..< objects.count
                    {
                        if let item = self.outlineView.item( atRow: i )
                        {
                            items.append( item )
                        }
                    }
                    
                    items.forEach { self.outlineView.expandItem( $0 ) }
                }
            }
        }
    }
    
    @objc public func performFindPanelAction( _ sender: Any? )
    {
        self.window?.makeFirstResponder( self.searchField )
    }
}
