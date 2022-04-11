// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract SupplyChain {
    // The payable address of the company
    address payable public company;

    constructor() {
        company = payable(msg.sender);
    }

    // The details of an user Account.
    struct AccountDetails {
        address accountAddress; // The unique account address of the user - from the metamask wallet.
        uint256 accountId; // The unique account id - we generate it.
        bool isPaymentDone; // The boolian variable to check if the payment is done or not.
        uint256 amountPaid; // The amount (ETH) payed by the user.
        uint256 planExpiresAt; // The time stamp at which the plan expires.
        OwnerDetails[] owners; // The owner for the application.
        SupplierDetails[] suppliers; // The list of suppliers for the application.
        ProductDetails[] products; // The list of products for the application.
    }

    // The details of an owner Account.
    struct OwnerDetails {
        string name;
        uint256 ownerId;
    }

    // The details of a supplier Account.
    struct SupplierDetails {
        string name;
        uint256 supplierId;
    }

    // The details of a product.
    struct ProductDetails {
        string name;
        uint256 productId;
    }

    mapping(uint256 => ProductStatusDeails[]) productStatus;

    ProductStatusDeails[] productStatusDeailsList;

    // The details of a product status.
    struct ProductStatusDeails {
        uint256 productId;
        uint256 time;
        string message;
        uint256 supplierId;
    }

    // To check if the user is present.
    mapping(address => bool) public isAccountPresent;

    // To get the user from the account Address.
    mapping(address => AccountDetails) public accountsByAddress;

    // To get the owner from the account Address.
    mapping(uint256 => OwnerDetails) public ownersById;

    // To get the supplier from the account Address.
    mapping(uint256 => SupplierDetails) public suppliersById;

    // The functions that will be called by The Application (Using APIs):
    // The Owner Application - OA
    // The Supplier Application - SP

    // The modifier that allows only the owners to access the functions.
    modifier onlyOwner(address _accountAddress, uint256 _ownerId) {
        //require(msg.sender == company,"Only The Company can access this function");
        _;
    }

    // The modifier that allows only the suppliers to access the functions.
    modifier onlySupplier(address _accountAddress, uint256 _supplierId) {
        //require(msg.sender == company,"Only The Company can access this function");
        _;
    }

    // OA-1 : The function to add an owner.
    function addOwner(
        address _accountAddress,
        string memory _name,
        uint256 _ownerId
    ) public onlyOwner(_accountAddress, _ownerId) {
        require(isAccountPresent[_accountAddress], "Invalid Account");
        accountsByAddress[_accountAddress].owners.push(
            OwnerDetails(_name, _ownerId)
        );
    }

    // OA-2 : The function to get the number of products.
    function getNoProduct(address _accountAddress, uint256 _ownerId)
        public
        view
        onlyOwner(_accountAddress, _ownerId)
        returns (uint256)
    {
        return accountsByAddress[_accountAddress].products.length;
    }

    // OA-3 : The function to get the list of products.
    function getProductGeneralDetails1(
        address _accountAddress,
        uint256 _ownerId
    )
        public
        view
        onlyOwner(_accountAddress, _ownerId)
        returns (ProductDetails[] memory)
    {
        return accountsByAddress[_accountAddress].products;
    }

    // OA-4 : The function to get a specific product's status details.
    function getProductStatusDetails(
        address _accountAddress,
        uint256 _ownerId,
        uint256 _productId
    )
        public
        view
        onlyOwner(_accountAddress, _ownerId)
        returns (ProductStatusDeails[] memory)
    {
        return productStatus[_productId];
    }

    // OA-5 : The function to add a product.
    function addProduct(
        address _accountAddress,
        uint256 _ownerId,
        string memory _name,
        uint256 _productId
    ) public onlyOwner(_accountAddress, _ownerId) {
        accountsByAddress[_accountAddress].products.push(
            ProductDetails(_name, _productId)
        );
        ProductStatusDeails memory productStatusDeails = ProductStatusDeails(
            _productId,
            block.timestamp,
            "message",
            11
        );
        productStatus[_productId].push(productStatusDeails);
    }

    // SP-1 : The function to add an supplier.
    function addSupplier(
        address _accountAddress,
        string memory _name,
        uint256 _supplierId
    ) public onlySupplier(_accountAddress, _supplierId) {
        require(isAccountPresent[_accountAddress], "Invalid Account");
        accountsByAddress[_accountAddress].suppliers.push(
            SupplierDetails(_name, _supplierId)
        );
    }

    // OA-2 : The function to get the number of products.
    function getNoProduct2(address _accountAddress, uint256 _supplierId)
        public
        view
        onlySupplier(_accountAddress, _supplierId)
        returns (uint256)
    {
        return accountsByAddress[_accountAddress].products.length;
    }

    // SP-3 : The function to get the list of products.
    function getProductGeneralDetails2(
        address _accountAddress,
        uint256 _supplierId
    )
        public
        view
        onlySupplier(_accountAddress, _supplierId)
        returns (ProductDetails[] memory)
    {
        return accountsByAddress[_accountAddress].products;
    }

    // SP-4 : The function to add a supply detail about the product.
    function addProductStaus(
        address _accountAddress,
        uint256 _supplierId,
        string memory _message,
        uint256 _productId
    ) public onlySupplier(_accountAddress, _supplierId) {
        ProductStatusDeails memory productStatusDeails = ProductStatusDeails(
            _productId,
            block.timestamp,
            _message,
            _supplierId
        );
        productStatus[_productId].push(productStatusDeails);
    }

    // The functions that will by called by The Company Website:  C - 1 to 5

    // The modifier that allows only The Company access the functions.
    modifier onlyCompany() {
        require(
            msg.sender == company,
            "Only The Company can access this function"
        );
        _;
    }

    // C-1 :  The function to check if the Account is present. Returns - True / False.
    function checkIfAccountPresent(address _accountAddress)
        public
        view
        onlyCompany
        returns (bool)
    {
        if (isAccountPresent[_accountAddress]) {
            return true;
        } else {
            return false;
        }
    }

    // C-2 : The function to careate an account. Called - checkIfAccountPresent returns False.
    function createAccount(address _accountAddress) public onlyCompany {
        isAccountPresent[_accountAddress] = true;
        accountsByAddress[_accountAddress].accountAddress = _accountAddress;
        accountsByAddress[_accountAddress].accountId = uint256(
            keccak256(
                abi.encodePacked(
                    block.difficulty,
                    block.number,
                    _accountAddress
                )
            )
        );
    }

    // C-3 : The function to check if the payment is done. Returns - True / False. Called - checkIfAccountPresent returns True.
    function checkIfPaymentDone(address _accountAddress)
        public
        view
        onlyCompany
        returns (bool)
    {
        if (accountsByAddress[_accountAddress].isPaymentDone) {
            return true;
        } else {
            return false;
        }
    }

    // C-4 : The function to select a plan. Called - checkIfPaymentDone returns False.
    function selectPlan(
        address _accountAddress,
        uint256 _amountPaid,
        uint256 _planExpiresAt
    ) public payable onlyCompany {
        accountsByAddress[_accountAddress].isPaymentDone = true;
        accountsByAddress[_accountAddress].amountPaid = _amountPaid;
        accountsByAddress[_accountAddress].planExpiresAt = _planExpiresAt;
    }

    // C-5 : The function to check if the plan is expired. Returns - True / False.
    function checkIfPlanExpired(address _accountAddress)
        public
        view
        onlyCompany
        returns (bool)
    {
        if (
            accountsByAddress[_accountAddress].planExpiresAt < block.timestamp
        ) {
            return true;
        } else {
            return false;
        }
    }
}
