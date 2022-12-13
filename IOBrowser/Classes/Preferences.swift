/*******************************************************************************
 * The MIT License (MIT)
 *
 * Copyright (c) 2022, Jean-David Gadina - www.xs-labs.com
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the Software), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED AS IS, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 ******************************************************************************/

import Foundation

public class Preferences: NSObject
{
    @objc public dynamic var lastStart: Date?
    {
        get
        {
            UserDefaults.standard.object( forKey: "LastStart" ) as? Date
        }

        set( value )
        {
            self.willChangeValue( for: \.lastStart )
            UserDefaults.standard.set( value, forKey: "LastStart" )
            self.didChangeValue( for: \.lastStart )
        }
    }

    @objc public dynamic var numberDisplayMode: Int
    {
        get
        {
            UserDefaults.standard.integer( forKey: "numberDisplayMode" )
        }

        set( value )
        {
            self.willChangeValue( for: \.lastStart )
            UserDefaults.standard.set( value, forKey: "numberDisplayMode" )
            self.didChangeValue( for: \.lastStart )
        }
    }

    @objc public dynamic var dataDisplayMode: Int
    {
        get
        {
            UserDefaults.standard.integer( forKey: "dataDisplayMode" )
        }

        set( value )
        {
            self.willChangeValue( for: \.lastStart )
            UserDefaults.standard.set( value, forKey: "dataDisplayMode" )
            self.didChangeValue( for: \.lastStart )
        }
    }

    @objc public dynamic var detectNumbersInData: Bool
    {
        get
        {
            UserDefaults.standard.bool( forKey: "detectNumbersInData" )
        }

        set( value )
        {
            self.willChangeValue( for: \.lastStart )
            UserDefaults.standard.set( value, forKey: "detectNumbersInData" )
            self.didChangeValue( for: \.lastStart )
        }
    }

    public static let shared = Preferences()

    private override init()
    {}
}
