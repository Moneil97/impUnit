// MIT License
//
// Copyright 2016 Electric Imp
//
// SPDX-License-Identifier: MIT
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies o`r substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO
// EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES
// OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
// ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.

/**
 * Base for test cases
 * @package ImpUnit
 */
class ImpTestCaseExtended extends ImpTestCase{

   /**
   * Assert that two values are within a certain float range
   * @param {number|*} expected
   * @param {number|*} actual
   * @param {number|*} maxDiff
   * @param {string} message
   */
  function assertCloseFloat(expected, actual, maxDiff, message = "Expected value: %s±%s, got: %s") {
    this.assertions++;
    if (math.fabs(expected - actual) > maxDiff) {
      throw format(message, expected + "", maxDiff + "", actual + "");
    }
  }


  function assertNotDeepEqual(expected, actual, message = "Expected objects to differ") {
        this.assertions++;

        try {
            this._assertDeepEqual(expected, actual, message, true); // forward pass
            this._assertDeepEqual(actual, expected, message, false); // backwards pass
        } catch (e) {
            return;
        }

        throw message;
    }


  function assertThrowsErrorContains(fn, ctx, args = [], errStrs = [], checkType = "any"){

        this.assertions++;
        args.insert(0, ctx)

        try {
            fn.pacall(args);
        } 
        catch (e) {
            switch (checkType){
                case "any":
                    foreach (err in errStrs){
                        if (e.find(err) != null){
                            return e;
                        }
                    }
                    throw "Function threw but did not contain any string in errStrs. Error was: " + e;
                case "all":
                    foreach (err in errStrs){
                        if (e.find(err) == null){
                            throw "Function threw but did not contain string: " + err + ". Error was: " + e;
                        }
                    }
                    return e;
                default:
                    throw "checkType was expected to be either 'any' or 'all' but got : '" + checkType + "'";
            }
        }

        throw "Function was expected to throw an error";
    }
    
}
