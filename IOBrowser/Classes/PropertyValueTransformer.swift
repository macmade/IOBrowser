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

@objc( PropertyValueTransformer )
public class PropertyValueTransformer: ValueTransformer
{
    public override class func transformedValueClass() -> AnyClass
    {
        NSString.self
    }

    public override func transformedValue( _ value: Any? ) -> Any?
    {
        guard let value = value as? PropertyListNode
        else
        {
            return nil
        }

        if let number = value.propertyList as? NSNumber
        {
            if Preferences.shared.numberDisplayMode == 0
            {
                return number.description
            }
            else if Preferences.shared.numberDisplayMode == 1
            {
                return String( format: "0x%llX", number.int64Value )
            }
        }

        if let data = value.propertyList as? Data, data.count > 0
        {
            if Preferences.shared.detectNumbersInData, let number = data.number()
            {
                return PropertyValueTransformer().transformedValue( PropertyListNode( key: value.key, propertyList: NSNumber( value: number ) ) )
            }
            else if Preferences.shared.dataDisplayMode == 0
            {
                return data.base64EncodedString()
            }
            else if Preferences.shared.dataDisplayMode == 1
            {
                return data.hexadecimalString()
            }
        }

        return value.value
    }

    public override class func allowsReverseTransformation() -> Bool
    {
        false
    }
}
