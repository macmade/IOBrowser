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
    @objc private dynamic var loading        = true
    @objc private dynamic var items          = [ IODisplayItem ]()
    @objc private dynamic var selectedObject:  IODisplayItem?

    @objc private dynamic var searchText: String?
    {
        didSet
        {
            self.filter( text: self.searchText )
        }
    }

    @objc private dynamic var searchInProperties = true
    {
        didSet
        {
            self.filter( text: self.searchText )
        }
    }
    
    @IBOutlet private var treeController: NSTreeController!
    @IBOutlet private var outlineView:    NSOutlineView!
    @IBOutlet private var propertiesView: NSView!
    @IBOutlet private var searchField:    NSSearchField!
    @IBOutlet private var searchOptions:  NSMenu!
    
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
            [ weak self ] o, c in self?.selectionDidChange()
        }
        
        self.load()
    }
    
    private func load()
    {
        DispatchQueue.global( qos: .userInitiated ).async
        {
            let items = IODisplayItem.all
            
            DispatchQueue.main.async
            {
                self.items = items
                
                DispatchQueue.main.async
                {
                    self.expandFirstLevel()
                    
                    self.loading = false
                }
            }
        }
    }
    
    private func selectionDidChange()
    {
        self.selectedObject?.properties.forEach { $0.predicate = nil }
        
        self.selectedObject = self.treeController.selectedObjects.first as? IODisplayItem
        
        self.propertiesView.subviews.forEach { $0.removeFromSuperview() }
        
        if let selected = self.selectedObject
        {
            let controller                                            = PropertiesViewController( item: selected )
            controller.view.translatesAutoresizingMaskIntoConstraints = false
            controller.view.frame                                     = self.propertiesView.bounds
            self.propertiesViewController                             = controller
            
            self.propertiesView.addSubview( controller.view )
            self.propertiesView.addConstraint( NSLayoutConstraint( item: controller.view, attribute: .centerX, relatedBy: .equal, toItem: self.propertiesView, attribute: .centerX, multiplier: 1, constant: 0 ) )
            self.propertiesView.addConstraint( NSLayoutConstraint( item: controller.view, attribute: .centerY, relatedBy: .equal, toItem: self.propertiesView, attribute: .centerY, multiplier: 1, constant: 0 ) )
            self.propertiesView.addConstraint( NSLayoutConstraint( item: controller.view, attribute: .width,   relatedBy: .equal, toItem: self.propertiesView, attribute: .width,   multiplier: 1, constant: 0 ) )
            self.propertiesView.addConstraint( NSLayoutConstraint( item: controller.view, attribute: .height,  relatedBy: .equal, toItem: self.propertiesView, attribute: .height,  multiplier: 1, constant: 0 ) )
            
            self.searchField.nextKeyView       = controller.searchField
            controller.searchField.nextKeyView = self.searchField
        }
        else
        {
            self.propertiesViewController = nil
            self.searchField.nextKeyView  = nil
        }
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

            if self.searchInProperties
            {
                return NSPredicate( format: "name contains[c] %@ OR index contains[c] %@", text, text )
            }

            return NSPredicate( format: "name contains[c] %@", text )
        }()
        
        self.items.forEach { $0.predicate = predicate }
        
        if predicate == nil
        {
            self.expandFirstLevel()
        }
        else
        {
            self.expandAll()
        }
    }
    
    @objc private func expandFirstLevel()
    {
        self.outlineView.collapseItem( nil, collapseChildren: true )
        
        var items = [ Any ]()
        
        for i in 0 ..< self.items.count
        {
            if let item = self.outlineView.item( atRow: i )
            {
                items.append( item )
            }
        }
        
        items.forEach { self.outlineView.expandItem( $0 ) }
    }
    
    @objc private func expandAll()
    {
        self.outlineView.expandItem( nil, expandChildren: true )
    }
    
    @objc private func collapseAll()
    {
        self.outlineView.collapseItem( nil, collapseChildren: true )
    }
    
    @objc public func performFindPanelAction( _ sender: Any? )
    {
        self.window?.makeFirstResponder( self.searchField )
    }

    @IBAction private func toggleSearchInProperties( _ sender: Any? )
    {
        self.searchInProperties = self.searchInProperties == false
    }

    @IBAction private func showSearchOptions( _ sender: Any? )
    {
        guard let view = sender as? NSView, let event = NSApp.currentEvent
        else
        {
            NSSound.beep()

            return
        }

        NSMenu.popUpContextMenu( self.searchOptions, with: event, for: view )
    }
}
