@include once __PATH__ + "/../src/ImpTestCaseExtended.class.nut"

class testImpTestCase extends ImpTestCaseExtended{

    function test01(){

        this.assertDeepEqual2(blob(9), blob(9));

        this.assertThrowsErrorContains(this.assertDeepEqual2, this, [blob(8), blob(9)], ["Comparison failed", "value1.len()"], ALL);
        this.assertThrowsErrorContains(this.assertDeepEqual2, this, [blob(9), blob(8)], ["Comparison failed", "value1.len()"], ALL);

        this.assertDeepEqual2([1,[2,3,4],[5, [6]]], [1,[2,3,4],[5, [6]]]);
        this.assertThrowsErrorContains(this.assertDeepEqual2, this, [[1,[2,3,4],[5, [6]]], [1,[2,3,4],[5, [7]]]], ["Comparison failed", "expected"], ALL);

        local b = blob(8);
        b[7] = 1;

        this.assertThrowsErrorContains(this.assertDeepEqual2, this, [[1,2,b,3], [1,2,blob(8),3]], ["Comparison failed", "expected"], ALL);
        
    }

    function test02(){


        local t = {
            a = {
                b = 7
            },
            c = {
                d = {
                    e = 8
                }
            },
            f = {
                g = {
                    h = {
                        i = {
                            j = [1,2,3,[3.5, 4],5]
                        }
                    }
                }
            }
        }

        local t2 = {
            a = {
                b = 7
            },
            c = {
                d = {
                    e = 8
                }
            },
            f = {
                g = {
                    h = {
                        i = {
                            j = [1,2,3,[3.5, 8],5]
                        }
                    }
                }
            }
        }

        this.assertDeepEqual2(t,t);

        this.assertThrowsErrorContains(this.assertDeepEqual2, this, [t, t2], ["Comparison failed", "expected"], ALL);

    }

    function test02(){
        this.assertThrowsErrorContains(this.assertDeepEqual2, this, [5, "5"], ["Comparison failed", "value1 is of type"], ALL);
        this.assertThrowsErrorContains(this.assertDeepEqual2, this, [[1], {"1":1}], ["Comparison failed", "value1 is of type"], ALL);
    }

}
