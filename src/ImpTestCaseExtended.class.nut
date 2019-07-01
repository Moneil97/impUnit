
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

    
    // Override parent _assertDeepEqual to add blob support
    // Slightly modified from: https://github.com/electricimp/impUnit/pull/11/files
    function _assertDeepEqual(value1, value2, message, isForwardPass, path = "", level = 0) {
        local cleanPath = @(p) p.len() == 0 ? p : p.slice(1);

        if (level > 32) {
            throw "Possible cyclic reference at " + cleanPath(path);
        }

        switch (type(value1)) {
            case "table":
            case "class":
            case "array":

                foreach (k, v in value1) {
                    path += "." + k;

                    if (!(k in value2)) {
                        throw format(message, cleanPath(path),
                        isForwardPass ? v + "" : "none",
                        isForwardPass ? "none" : v + "");
                    }

                    this._assertDeepEqual(value1[k], value2[k], message, isForwardPass, path, level + 1);
                }
                break;

            case "meta":
                this._deepEqualMeta(value1, value2, message, isForwardPass, path, level);
                break;

            case "null":
                break;

            default:
                if (value2 != value1) {
                    throw format(message, cleanPath(path), value1 + "", value2 + "");
                }
                break;
        }
    }

    // Deep equal blob
    function _deepEqualMeta(value1, value2, message, isForwardPass, path, level){
        switch(typeof value1) {
            case "blob":

                if (value1.len() != value2.len()) {
                    throw format("Blob lengths unequal, lhs.len() == %d, rhs.len() == %d", value1.len(), value2.len());
                }

                if (value1.len() > 0) {
                    foreach (k, v in value1) {
                        path += "." + k;

                        if (!(k in value2)) {
                            throw format("%s slot [%s] in actual value",
                            isForwardPass ? "Missing" : "Extra", cleanPath(path));
                        }

                        this._assertDeepEqual(value1[k], value2[k], message, isForwardPass, path, level + 1);
                    }
                }

                break;

            default:

                if (value2 != value1) {
                    throw format(message, cleanPath(path), value1 + "", value2 + "");
                }

                break;
        }
    }
    
}
