
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
    function _assertDeepEqual(value1, value2, message, isForwardPass, path = "", level = 0) {
        local cleanPath = @(p) p.len() == 0 ? p : p.slice(1);

        if (level > 32) 
            throw "Possible cyclic reference at " + cleanPath(path);

        switch (typeof(value1)) {
            case "table":
            case "array":
            case "class":
            
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

            case "blob":
                this._assertDeepEqual(value1.tostring(), value2.tostring(), message, isForwardPass, path, level + 1);
                break;

            case "null":
                break;

            default:
                if (value2 != value1) 
                    throw format(message, cleanPath(path), value1 + "", value2 + "");
                break;
        }
    }

    function _assertLengthEqual(value1, value2, path){
        if (value1.len() != value2.len())
            throw format("Comparison failed on '%s': value1.len() == %d but value2.len() == %d.", path, value1.len(), value2.len());
    }

    function assertDeepEqual2(expected, actual, maxLevels=32) {
        this.assertions++;
        this._assertDeepEqual2(expected, actual, maxLevels, true); // forward pass
        this._assertDeepEqual2(actual, expected, maxLevels, false); // backwards pass
    }

    function _assertDeepEqual2(value1, value2, maxLevels, isForwardPass, path = "obj", level = 0) {

        if (level > maxLevels) 
            throw "Possible cyclic reference at " + path;

        local type1 = typeof(value1);
        local type2 = typeof(value2);
        if (type1 != type2)
            throw format("Comparison failed on '%s': value1 is of type %s but value2 is of type %s.", path, type1, type2);

        switch (type1) {
            
            case "table":
                this._assertLengthEqual(value1, value2, path);
            case "class":
                foreach (k, v in value1) {
                    if (!(k in value2)) 
                        throw format("Comparison failed on '%s': expected %s, got %s", path, isForwardPass ? v + "" : "none", isForwardPass ? "none" : v + "");

                    this._assertDeepEqual2(value1[k], value2[k], maxLevels, isForwardPass, path + format(".%s", k), level + 1);
                }
                break;

            case "array":
            case "blob":
                this._assertLengthEqual(value1, value2, path);

                foreach(i,v in value1)
                    this._assertDeepEqual2(v, value2[i], maxLevels, isForwardPass, path + format("[%d]", i), level + 1);
                break;

            case "null":
                break;

            default:
                if (value2 != value1) 
                    throw format("Comparison failed on '%s': expected %s, got %s", path, value1 + "", value2 + "");
                break;
        }
    }
    
}
