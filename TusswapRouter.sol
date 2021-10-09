pragma solidity >=0.6.12;


import './libraries/TusswapLibrary.sol';
import './libraries/SafeMath.sol';
import './libraries/TransferHelper.sol';
import './interfaces/ITusswapFactory.sol';
import './interfaces/IERC20.sol';


contract TusswapRouter {
    using SafeMathTusswap for uint;

    address public immutable  factory;
    address public immutable  WTUS;

    modifier ensure(uint deadline) {
        require(deadline >= block.timestamp, 'TusswapRouter: EXPIRED');
        _;
    }

    constructor(address _factory, address _WTUS) public {
        factory = _factory;
        WTUS = _WTUS;
    }

    // **** ADD LIQUIDITY ****
    function _addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin
    ) internal virtual returns (uint amountA, uint amountB) {
        // create the pair if it doesn't exist yet
        if (ITusswapFactory(factory).getPair(tokenA, tokenB) == address(0)) {
            ITusswapFactory(factory).createPair(tokenA, tokenB);
        }
        (uint reserveA, uint reserveB, ) = getReserves(factory, tokenA, tokenB);
        if (reserveA == 0 && reserveB == 0) {
            (amountA, amountB) = (amountADesired, amountBDesired);
        } else {
            uint amountBOptimal = TusswapLibrary.quote(amountADesired, reserveA, reserveB);
            if (amountBOptimal <= amountBDesired) {
                require(amountBOptimal >= amountBMin, 'TusswapRouter: INSUFFICIENT_B_AMOUNT');
                (amountA, amountB) = (amountADesired, amountBOptimal);
            } else {
                uint amountAOptimal = TusswapLibrary.quote(amountBDesired, reserveB, reserveA);
                assert(amountAOptimal <= amountADesired);
                require(amountAOptimal >= amountAMin, 'TusswapRouter: INSUFFICIENT_A_AMOUNT');
                (amountA, amountB) = (amountAOptimal, amountBDesired);
            }
        }
    }
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external virtual ensure(deadline) returns (uint amountA, uint amountB, uint liquidity) {
        require(tokenB == WTUS, 'TusswapRouter: only tus address');
        (amountA, amountB) = _addLiquidity(tokenA, tokenB, amountADesired, amountBDesired, amountAMin, amountBMin);
        address pair = pairFor(factory, tokenA, tokenB);
        TransferHelper.safeTransferFrom(tokenA, msg.sender, pair, amountA);
        TransferHelper.safeTransferFrom(tokenB, msg.sender, pair, amountB);
        uint mint0 = amountBDesired;
        liquidity = ITusswapPair(pair).mint(to,mint0);
    }
    // **** REMOVE LIQUIDITY ****
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) public virtual ensure(deadline) returns (uint amountA, uint amountB) {
        address pair = pairFor(factory, tokenA, tokenB);
        ITusswapPair(pair).transferFrom(msg.sender, pair, liquidity); // send liquidity to pair
        (uint amount0, uint amount1) = ITusswapPair(pair).burn(to);
        (address token0,) = TusswapLibrary.sortTokens(tokenA, tokenB);
        (amountA, amountB) = tokenA == token0 ? (amount0, amount1) : (amount1, amount0);
        require(amountA >= amountAMin, 'TusswapRouter: INSUFFICIENT_A_AMOUNT');
        require(amountB >= amountBMin, 'TusswapRouter: INSUFFICIENT_B_AMOUNT');
    }

    // **** SWAP ****
    // requires the initial amount to have already been sent to the first pair
    function _swap(uint[] memory amounts, address[] memory path, address _to) internal virtual {
        for (uint i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0,) = TusswapLibrary.sortTokens(input, output);
            uint amountOut = amounts[i + 1];
            (uint amount0Out, uint amount1Out) = input == token0 ? (uint(0), amountOut) : (amountOut, uint(0));
            address to = i < path.length - 2 ? pairFor(factory, output, path[i + 2]) : _to;
            ITusswapPair(pairFor(factory, input, output)).swap(
                amount0Out, amount1Out, to
            );
        }
    }
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external virtual ensure(deadline) returns (uint[] memory amounts) {
        amounts = getAmountsOut(factory, amountIn, path);
        require(amounts[amounts.length - 1] >= amountOutMin, 'TusswapRouter: INSUFFICIENT_OUTPUT_AMOUNT');
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, pairFor(factory, path[0], path[1]), amounts[0]
        );
        _swap(amounts, path, to);
    }
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external virtual ensure(deadline) returns (uint[] memory amounts) {
        amounts = getAmountsIn(factory, amountOut, path);
        require(amounts[0] <= amountInMax, 'TusswapRouter: EXCESSIVE_INPUT_AMOUNT');
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, pairFor(factory, path[0], path[1]), amounts[0]
        );
        _swap(amounts, path, to);
    }

    // **** LIBRARY FUNCTIONS ****
    function pairFor(address factory, address tokenA, address tokenB) internal view returns (address pair) {
        (address token0, address token1) = TusswapLibrary.sortTokens(tokenA, tokenB);
        return ITusswapFactory(factory).getPair(token0, token1);
    }
    function getReserves(address factory, address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB, uint8 fee) {
        (address token0,) = TusswapLibrary.sortTokens(tokenA, tokenB);
        (uint reserve0, uint reserve1,) = ITusswapPair(pairFor(factory, tokenA, tokenB)).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
        fee = ITusswapPair(pairFor(factory, tokenA, tokenB)).fee();
    }
    function quote(uint amountA, uint reserveA, uint reserveB) public pure virtual returns (uint amountB) {
        return TusswapLibrary.quote(amountA, reserveA, reserveB);
    }

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut, uint8 fee)
        public
        pure
        virtual
        returns (uint amountOut)
    {
        return TusswapLibrary.getAmountOut(amountIn, reserveIn, reserveOut, fee);
    }

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut, uint8 fee)
        public
        pure
        virtual
        returns (uint amountIn)
    {
        return TusswapLibrary.getAmountIn(amountOut, reserveIn, reserveOut, fee);
    }

    function getAmountsOut(address factory,uint amountIn, address[] memory path)
        public
        view
        virtual
        returns (uint[] memory amounts)
    {
        require(path.length >= 2, 'TusswapRouter: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[0] = amountIn;
        for (uint i; i < path.length - 1; i++) {
            (uint reserveIn, uint reserveOut, uint8 fee) = getReserves(factory, path[i], path[i + 1]);
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut, fee);
        }
    }

    function getAmountsIn(address factory,uint amountOut, address[] memory path)
        public
        view
        virtual
        returns (uint[] memory amounts)
    {
        require(path.length >= 2, 'TusswapRouter: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint i = path.length - 1; i > 0; i--) {
            (uint reserveIn, uint reserveOut, uint8 fee) = getReserves(factory, path[i - 1], path[i]);
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut, fee);
        }
    }
}
