//
//  Copyright 2016 Lionheart Software LLC
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
//

import Foundation

public extension Array {
    func chunks(_ size: Int) -> AnyIterator<[Element]> {
        if size == 0 {
            return AnyIterator {
                return nil
            }
        }

        let indices = stride(from: startIndex, to: count, by: size)
        var generator = indices.makeIterator()

        return AnyIterator {
            guard let i = generator.next() else {
                return nil
            }

            // MARK: TODO. There used to be a `limit` here.
            guard let j = self.index(i, offsetBy: size, limitedBy: self.endIndex) else {
                return nil
            }

            return self[i..<j].map { $0 }
        }
    }
}
