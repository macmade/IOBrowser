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

public extension Data
{
    func hexadecimalString() -> String
    {
        self.reduce( "0x" )
        {
            $0.appending( String( format: "%02X", $1  ) )
        }
    }

    func number() -> UInt64?
    {
        if self.count == 1
        {
            return UInt64( self[ 0 ] )
        }
        else if self.count == 2
        {
            let n1 = UInt64( self[ 0 ] ) << 8
            let n2 = UInt64( self[ 1 ] )

            return n1 | n2
        }
        else if self.count == 4
        {
            let n1 = UInt64( self[ 0 ] ) << 24
            let n2 = UInt64( self[ 1 ] ) << 16
            let n3 = UInt64( self[ 2 ] ) <<  8
            let n4 = UInt64( self[ 3 ] )

            return n1 | n2 | n3 | n4
        }
        else if self.count == 8
        {
            let n1 = UInt64( self[ 0 ] ) << 56
            let n2 = UInt64( self[ 1 ] ) << 48
            let n3 = UInt64( self[ 2 ] ) << 40
            let n4 = UInt64( self[ 3 ] ) << 32
            let n5 = UInt64( self[ 4 ] ) << 24
            let n6 = UInt64( self[ 5 ] ) << 16
            let n7 = UInt64( self[ 6 ] ) <<  8
            let n8 = UInt64( self[ 7 ] )

            return n1 | n2 | n3 | n4 | n5 | n6 | n7 | n8
        }

        return nil
    }
}
