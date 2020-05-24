pragma solidity >=0.4.22 <0.7.0;

interface Erc20 {
    function approve(address, uint256) external returns (bool);

    function transfer(address, uint256) external returns (bool);
}


interface CErc20 {
    function mint(uint256) external returns (uint256);

    function borrow(uint256) external returns (uint256);

    function borrowRatePerBlock() external view returns (uint256);

    function borrowBalanceCurrent(address) external returns (uint256);

    function repayBorrow(uint256) external returns (uint256);
}


interface CEth {
    function mint() external payable;

    function borrow(uint256) external returns (uint256);

    function repayBorrow() external payable;

    function borrowBalanceCurrent(address) external returns (uint256);
}


interface Comptroller {
    function markets(address) external returns (bool, uint256);

    function enterMarkets(address[] calldata)
        external
        returns (uint256[] memory);

    function getAccountLiquidity(address)
        external
        view
        returns (uint256, uint256, uint256);
}


interface PriceOracle {
    function getUnderlyingPrice(address) external view returns (uint256);
}


contract CompoundBorrow {
    event Log(string, uint256);

    function borrowErc20 (
        address payable _cEtherAddress,
        address _comptrollerAddress,
        address _priceOracleAddress,
        address _cDaiAddress
    ) public payable returns (uint256) {
        CEth cEth = CEth(_cEtherAddress);
        Comptroller comptroller = Comptroller(_comptrollerAddress);
        PriceOracle priceOracle = PriceOracle(_priceOracleAddress);
        CErc20 cDai = CErc20(_cDaiAddress);

        // Supply ETH as collateral, get cETH in return
        cEth.mint.value(msg.value)();

        // Enter the ETH market so you can borrow another type of asset
        address[] memory cTokens = new address[](1);
        cTokens[0] = _cEtherAddress;
        uint256[] memory errors = comptroller.enterMarkets(cTokens);
        if (errors[0] != 0) {
            revert("Comptroller.enterMarkets failed.");
        }

        // Get my account's total liquidity value in Compound
        (uint256 error, uint256 liquidity, uint256 shortfall) = comptroller
            .getAccountLiquidity(address(this));
        if (error != 0) {
            revert("Comptroller.getAccountLiquidity failed.");
        }
        require(shortfall == 0, "account underwater");
        require(liquidity > 0, "account has excess collateral");

        // Get the collateral factor for our collateral
        // (
        //   bool isListed,
        //   uint collateralFactorMantissa
        // ) = comptroller.markets(_cEthAddress);
        // emit Log('ETH Collateral Factor', collateralFactorMantissa);

        // Get the amount of DAI added to your borrow each block
        // uint borrowRateMantissa = cDai.borrowRatePerBlock();
        // emit Log('Current DAI Borrow Rate', borrowRateMantissa);

        // Get the DAI price in ETH from the Price Oracle,
        // so we can find out the maximum amount of DAI we can borrow.
        uint256 daiPriceInWei = priceOracle.getUnderlyingPrice(_cDaiAddress);
        uint256 maxBorrowDaiInWei = liquidity / daiPriceInWei;

        // Borrowing near the max amount will result
        // in your account being liquidated instantly
        emit Log("Maximum DAI Borrow (borrow far less!)", maxBorrowDaiInWei);

        // Borrow DAI
        uint256 numDaiToBorrow = 10;

        // Borrow DAI, check the DAI balance for this contract's address
        cDai.borrow(numDaiToBorrow * 1e18);

        // Get the borrow balance
        uint256 borrows = cDai.borrowBalanceCurrent(address(this));
        emit Log("Current DAI borrow amount", borrows);

        return borrows;
    }

    function myErc20RepayBorrow(
        address _erc20Address,
        address _cErc20Address,
        uint256 amount
    ) public returns (bool) {
        Erc20 dai = Erc20(_erc20Address);
        CErc20 cDai = CErc20(_cErc20Address);

        dai.approve(_cErc20Address, amount);
        uint256 error = cDai.repayBorrow(amount);

        require(error == 0, "CErc20.repayBorrow Error");
        return true;
    }

    // Need this to receive ETH when `borrowEthExample` executes
    fallback() external payable {}
}
