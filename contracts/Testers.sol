import "contracts/CallLib.sol";


contract owned {
    address public owner;

    function Owned() {
        owner = msg.sender;
    }
}


contract SchedulerAPI {
    function scheduleCall(address contractAddress, bytes4 abiSignature, uint targetBlock) public returns (address);
    //function scheduleCall(address contractAddress, bytes4 abiSignature, uint targetBlock, uint suggestedGas) public returns (address);
    //function scheduleCall(address contractAddress, bytes4 abiSignature, uint targetBlock, uint suggestedGas, uint8 gracePeriod) public returns (address);
    //function scheduleCall(address contractAddress, bytes4 abiSignature, uint targetBlock, uint suggestedGas, uint8 gracePeriod, uint basePayment) public returns (address);

    //function scheduleCall(address contractAddress, bytes4 abiSignature, uint targetBlock, uint suggestedGas, uint8 gracePeriod, uint basePayment, uint baseFee) public returns (address);
}


contract TestDataRegistry is owned {
        uint8 public wasSuccessful = 0;

        function reset() public {
            wasSuccessful = 0;
        }

        function registerBool(address to, bool v) public {
            bool result = to.call(bytes4(sha3("registerData()")), v);
            if (result) {
                wasSuccessful = 1;
            }
            else {
                wasSuccessful = 2;
            }
        }

        function registerUInt(address to, uint v) public {
            bool result = to.call(bytes4(sha3("registerData()")), v);
            if (result) {
                wasSuccessful = 1;
            }
            else {
                wasSuccessful = 2;
            }
        }

        function registerInt(address to, int v) public {
            bool result = to.call(bytes4(sha3("registerData()")), v);
            if (result) {
                wasSuccessful = 1;
            }
            else {
                wasSuccessful = 2;
            }
        }

        function registerBytes32(address to, bytes32 v) public {
            bool result = to.call(bytes4(sha3("registerData()")), v);
            if (result) {
                wasSuccessful = 1;
            }
            else {
                wasSuccessful = 2;
            }
        }

        function registerBytes(address to, bytes v) public {
            bool result = to.call(v);
            //bool result = to.call(v);
            if (result) {
                wasSuccessful = 1;
            }
            else {
                wasSuccessful = 2;
            }
        }

        function registerAddress(address to, address v) public {
            bool result = to.call(bytes4(sha3("registerData()")), v);
            if (result) {
                wasSuccessful = 1;
            }
            else {
                wasSuccessful = 2;
            }
        }

        function registerMany(address to, uint a, int b, uint c, bytes20 d, address e, bytes f) public {
            bool result = to.call(bytes4(sha3("registerData()")), a, b, c, d, e, f.length, f);
            if (result) {
                wasSuccessful = 1;
            }
            else {
                wasSuccessful = 2;
            }
        }

        function registerData(address to, int arg1, bytes32 arg2, address arg3) public {
            // 0xb0f07e44 == bytes4(sha3("registerData()"))
            bool result = to.call(0xb0f07e44, arg1, arg2, arg3);
            if (result) {
                wasSuccessful = 1;
            }
            else {
                wasSuccessful = 2;
            }
        }
}


contract TestCallExecution is TestDataRegistry {
        uint8 public wasSuccessful;

        function reset() public {
            v_bool = false;
            v_uint = 0;
            v_int = 0;
            v_bytes32 = 0x0;
            v_address = 0x0;
            v_bytes.length = 0;

            vm_a = 0;
            vm_b = 0;
            vm_c = 0;
            vm_d = 0x0;
            vm_e = 0x0;
            vm_f.length = 0;
        }

        function noop() {
        }

        function doExecution(address to) {
            bool result = to.call(bytes4(sha3("execute()")));
            if (result) {
                wasSuccessful = 1;
            }
            else {
                wasSuccessful = 2;
            }
        }

        function doLoops(uint iterations) {
            for (uint i = 0; i < iterations; i++) {
                address(this).send(1);
            }
        }

        bool public v_bool;

        function scheduleSetBool(address to, uint targetBlock, bool v) public {
            SchedulerAPI arst = SchedulerAPI(to);
            address call_address = arst.scheduleCall.value(this.balance)(address(this), bytes4(sha3("setBool()")), targetBlock);
            call_address.call(bytes4(sha3("registerData()")), v);
        }

        function setBool() public {
            v_bool = true;
        }

        uint public v_uint;

        function scheduleSetUInt(address to, uint targetBlock, uint v) public {
            SchedulerAPI arst = SchedulerAPI(to);
            address call_address = arst.scheduleCall.value(this.balance)(address(this), bytes4(sha3("setUInt(uint256)")), targetBlock);
            call_address.call(bytes4(sha3("registerData()")), v);
        }

        function setUInt(uint v) public {
            v_uint = v;
        }

        int public v_int;

        function setInt(int v) public {
            v_int = v;
        }

        address public v_address;

        function setAddress(address v) public {
            v_address = v;
        }

        bytes32 public v_bytes32;

        function setBytes32(bytes32 v) public {
            v_bytes32 = v;
        }

        bytes public v_bytes;

        function setBytes(bytes v) public {
            v_bytes = v;
            wasSuccessful = 1;
        }

        function setCallData() public {
            v_bytes = msg.data;
        }

        uint public vm_a;
        int public vm_b;
        uint public vm_c;
        bytes20 public vm_d;
        address public vm_e;
        bytes public vm_f;

        function setMany(uint a, int b, uint c, bytes20 d, address e, bytes f) public {
            vm_a = a;
            vm_b = b;
            vm_c = c;
            vm_d = d;
            vm_e = e;
            vm_f = f;
        }
}


contract TestErrors is owned {
    bool public value;

    function reset() public {
        value = false;
    }

    function doFail() public {
        throw;
        value = true;
    }

    function doInfinite() public {
        while (true) {
                tx.origin.send(1);
        }
        value = true;
    }

    address public callAddress;

    function setCallAddress(address _callAddress) {
        callAddress = _callAddress;
    }

    uint public d;

    function proxyCall(uint depth) public returns (bool) {
        if (depth == 0) {
            return callAddress.call(bytes4(sha3("execute()")));
        }
        else if (msg.sender == address(this)) {
            return address(this).callcode(bytes4(sha3("proxyCall(uint256)")), depth - 1);
        }
        else {
            return address(this).call(bytes4(sha3("proxyCall(uint256)")), depth - 1);
        }
    }

    uint constant GAS_PER_DEPTH = 700;

    function __dig(uint n) constant returns (bool) {
        if (n == 0) return true;
        if (!address(this).callcode(bytes4(sha3("__dig(uint256)")), n - 1)) throw;
    }

    function doStackExtension(uint depth) public {
        if (!CallLib.checkDepth(depth)) throw;
        value = true;
    }
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return 12345;
    }
}
