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
    @objc private dynamic var root:           IOObject?
    @objc private dynamic var selectedObject: IOObject?
    
    @IBOutlet private var objectsController:    NSTreeController!
    @IBOutlet private var propertiesController: NSTreeController!
    @IBOutlet private var objectsView:          NSOutlineView!
    @IBOutlet private var propertiesView:       NSOutlineView!
    
    private var selectionObserver: NSKeyValueObservation?
    
    public override var windowNibName: NSNib.Name?
    {
        "MainWindowController"
    }
    
    public override func windowDidLoad()
    {
        super.windowDidLoad()
        
        self.objectsController.sortDescriptors =
        [
            NSSortDescriptor( key: "name", ascending: true, selector: #selector( NSString.localizedCaseInsensitiveCompare( _: ) ) )
        ]
        
        self.selectionObserver = self.objectsController.observe( \.selectedObjects )
        {
            o, c in self.selectedObject = self.objectsController.selectedObjects.first as? IOObject
        }
        
        IOObject.root
        {
            object in DispatchQueue.main.asyncAfter( deadline: .now() + .seconds( 1 ) )
            {
                self.loading = false
                self.root    = object
                
                DispatchQueue.main.async
                {
                    guard let item = self.objectsView.item( atRow: 0 ) as? NSTreeNode else
                    {
                        return
                    }
                    
                    self.objectsView.expandItem( item )
                    item.children?.forEach
                    {
                        self.objectsView.expandItem( $0 )
                    }
                }
            }
        }
    }
}
