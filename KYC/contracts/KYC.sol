// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract KYC{

    // The structure of a user.
    struct User{
        address id; // The unique address of the user. 
        string name; // The name of the user. 
        string documentsLocation; // The url/location of the documents stored in a database.
        bytes32 documentHash; // The hash of the uploaded documents.
        bool isDocumentsAvailable; // The boolian variable to check if there are documents available or not.
        FinancialInstitution submitedInstitution; // The institution to whihc the documents have been submited.
        bool isDocumentsSubmited; // The boolian variable to check if the documents are submited to verify or not.
        bytes32 approvedHash; // The hash that is uploaded by the instituion after verifying.  
        bool isApproved; // The boolian variable to check if the documents are approved or not.
        bool isHashsVerified; // The boolian variable to check if the document hash and uproved hash are same.
    }

    // The structure of a financial institution.
    struct FinancialInstitution{
        address id; // The unique address of the institution. 
        string name; // The name of the institution. 
        address [] submitedUsers; // The users who have submited to verify.
    }

    // To check if the user / institution is present.
    mapping (address => bool) public isUserPresent;
    mapping (address => bool) public isInstitutionPresent;

    // To get the user / institution from the id.
    mapping (address => User) public indexedUsers;
    mapping (address => FinancialInstitution) public indexedInstitutions;

    modifier onlyUser(){
        address userId = msg.sender;
        require(isUserPresent[userId], "Only registered users can access this.");
        _;
    }

    modifier onlyInstitutions(address _userId){
        address institutionId = msg.sender;
        require(isInstitutionPresent[institutionId], "Only registered institutions can access this.");
        require(isElementPresent(indexedInstitutions[institutionId].submitedUsers, _userId), "You do not have permiton to access this data."); 
        _;
    }

    function isElementPresent(address [] memory submitedUsers, address findThis) private pure returns(bool){
        uint index = 0;
        uint length = submitedUsers.length;
        while(length != 0){
            if(submitedUsers[index]==findThis){
                return true;
            }
            index++;
            length--;
        }
        return false;
    }

    // The function to create a user account. (Anyone)
    function createUserAccount(string memory _name) public {
        address userId = msg.sender;
        require(!isUserPresent[userId], "Account has already been created.");
        isUserPresent[userId] = true;
        indexedUsers[userId].id = userId;
        indexedUsers[userId].name = _name;
    }

    // The function to create an institution account. (Anyone with institution access)
    function createInstitutionAccount(string memory _name) public {
        address institutionId = msg.sender;
        require(!isInstitutionPresent[institutionId], "Account has already been created.");
        isInstitutionPresent[institutionId] = true;
        indexedInstitutions[institutionId].id = institutionId;
        indexedInstitutions[institutionId].name =_name;
    }

    // The function to upload / update documens by the user. [The list of document urls and the document hash]  (only user)
    function userUploadDocuments(string memory _documentsLocation, bytes32 _documentHash) public onlyUser{
        address userId = msg.sender;
        indexedUsers[userId].documentsLocation = _documentsLocation;
        indexedUsers[userId].documentHash = _documentHash;
        indexedUsers[userId].isDocumentsAvailable = true;
    }

    // The function to give the permition to an institution, asking them to verify.  (only user)
    function userSubmitsToInstitution(address _institutionId) public onlyUser{
        address userId = msg.sender;
        require(!indexedUsers[userId].isDocumentsSubmited, "The KYC process is already started by another Financial Institution. Please Wait till they verify.");
        require(indexedUsers[userId].isDocumentsAvailable, "The documents have not been uploaded. Please upload the documents.");
        require(isInstitutionPresent[_institutionId], "Financial Institution address is not present or not valid.");
        indexedUsers[userId].submitedInstitution = indexedInstitutions[_institutionId];
        indexedUsers[userId].isDocumentsSubmited = true;
        indexedInstitutions[_institutionId].submitedUsers.push(userId);
    }

    // The function to get the documents for the institution. (only institution with permition)
    function getDocumentsForinstitution(address _userId) public view onlyInstitutions(_userId) returns(string memory){
        return indexedUsers[_userId].documentsLocation;
    }

    // The function check if the user is approved or not. (Return - true / false) (only user)
    function checkIsApproved() public view onlyUser returns(bool){
        address userId = msg.sender;
        return indexedUsers[userId].isApproved;
    }
    
    // The function check if the user is approved or not. (Return - true / false) (only institution with permition)
    function checkIsUserApproved(address _userId) public view onlyInstitutions(_userId) returns(bool){
        return indexedUsers[_userId].isApproved;
    }

    // The function to verify the documents, if the user is not approved (false).  (only institution with permition)
    function institutionVerifiesDocuments(address _userId, bytes32 _approvedHash) public onlyInstitutions(_userId){
            if(indexedUsers[_userId].documentHash == _approvedHash){
                indexedUsers[_userId].approvedHash = _approvedHash;
                indexedUsers[_userId].isApproved = true;
                indexedUsers[_userId].isDocumentsSubmited = false;
            }else{
                indexedUsers[_userId].isDocumentsSubmited = false;
                revert("The documents have been updated. Submit again.");
            }
    }

    // The function to verify the hashs and set the isHashsVerified, if the user is approved (true - 1).  (only institution with permition)
    function institutionVerifiesHashs(address _userId) public onlyInstitutions(_userId){
            if(indexedUsers[_userId].documentHash == indexedUsers[_userId].approvedHash){
               indexedUsers[_userId].isHashsVerified = true;
            }else{
                indexedUsers[_userId].isApproved = false;
                indexedUsers[_userId].isHashsVerified = false;
            }
    }

    // The function to check if the hashs match, if the user is approved (true - 2). (Return - true (Done) / false) (only institution with permition)
    function checkIsHashsVerified(address _userId) public view onlyInstitutions(_userId) returns(bool){
        return indexedUsers[_userId].isHashsVerified;
    }

}
