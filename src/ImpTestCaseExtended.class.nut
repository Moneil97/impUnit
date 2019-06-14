
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
