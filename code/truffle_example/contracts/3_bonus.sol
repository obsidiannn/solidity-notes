// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

// 质押记录type
struct BonusItem {
    // 质押币种
    address tokenId;
    uint stamp;
    uint256 amount;
}

struct BonusWaitItem {
    address tokenId;
    uint stamp;
    uint256 amount;
    address walletAddr;
}
// 奖金池
struct BonusPoolItem {
    address tokenId;
    uint amount;
    uint lastStamp;
}

struct CalculateItem{
    address userAddr;
    uint score;
}

contract BonusContract is Ownable {
    uint32 constant public WAIT_SECOND = 20;
    // uint32 constant public WAIT_SECOND = 172800;
    
    // 支持的结算货币 USDT-ERC20
    address public currencyToken;
    // 单次最小质押数
    uint public mixCapital;
    string private _name;
    string private _symbol;
    mapping (address=>uint) public _support_tokens;

    // 当前质押
    mapping(address=>BonusItem) _current_stake;
    // 追加队列
    BonusWaitItem[] public  _stake_in_queue;
    // 撤回队列
    BonusWaitItem[] public _draw_queue;

    // 当前存有质押的用户address set，单元素唯一
    using EnumerableSet for EnumerableSet.AddressSet;
    EnumerableSet.AddressSet private _stake_users;
    // 当前撤回申请额
    mapping (address => uint) _draw_amount_mapping;

    // 奖金池
    mapping(address => BonusPoolItem) public _bonus_pool;

    constructor(string memory name,string memory symbol) Ownable(msg.sender){
        _name = name;
        _symbol = symbol;
    }

    // 设置可用token，用于质押准入
    function addSupportTokens(address[] memory tokens,uint [] memory amounts) public {
        _checkOwner();
        for (uint32 i = 0; i<tokens.length; i++) 
        {
            _support_tokens[tokens[i]] = amounts[i];
        }
    }

    // 追加质押队列
    function stakeApply(address token,uint amount) external {
        require(amount > 0, "Amount must be greater than zero");
        require(_support_tokens[token] > 0,"unsupport token");
        BonusItem memory current = _current_stake[msg.sender];
        if(current.stamp > 0){
            // 如果存在质押，则追加的必须一致
            require(current.tokenId == token,"different token type");
        }
        require(IERC20(token).transferFrom(msg.sender, address(this), amount), "Transfer failed");
        
        BonusWaitItem memory item = BonusWaitItem(token, block.timestamp, amount,msg.sender);
        _stake_in_queue.push(item);
    }

    // 加入当前质押
    function doStake() public  {
        _checkOwner();
        if(_stake_in_queue.length > 0){
            uint currentStamp = block.timestamp;
            uint  popCount = 0;
            for (uint256 i = 0; i < _stake_in_queue.length; i++) {
                BonusWaitItem memory waitItem = _stake_in_queue[i];
                if(waitItem.stamp + WAIT_SECOND <= currentStamp){
                    BonusItem memory item =  _current_stake[waitItem.walletAddr];
                    if(item.stamp > 0){
                        item.amount = item.amount + waitItem.amount;
                        _current_stake[waitItem.walletAddr] = item;
                    }else{
                        _current_stake[waitItem.walletAddr] = BonusItem(waitItem.tokenId, currentStamp, waitItem.amount);
                        // 加入到质押者列表
                        _stake_users.add(waitItem.walletAddr);
                    }
                    popCount++;
                }else{
                    break ;
                }
            }
            for (uint j = 0;j<popCount;j++){
                _stake_in_queue.pop();
            }
        }
    }

    // 撤回申请
    function drawApply(address token,uint amount) external {
        require(amount > 0, "Amount must be greater than zero");
        require(_support_tokens[token] > 0,"unsupport token");
        BonusItem memory current = _current_stake[msg.sender];
        if(current.stamp > 0) {
            // 如果存在质押，则撤回的必须一致
            require(current.tokenId == token,"different token type");
             // 检查总数一致性
            require((_draw_amount_mapping[msg.sender] + amount) <= current.amount,"over total stake amount");
        }
        // 加入撤回队列
        _draw_queue.push(BonusWaitItem(token, block.timestamp, amount,msg.sender));
        _draw_amount_mapping[msg.sender] +=amount;
    }

    // 发起撤回
    function doDraw() public  {
        _checkOwner();
        if(_draw_queue.length > 0){
            uint currentStamp = block.timestamp;
            uint popCount = 0;

            for (uint256 i = 0; i < _draw_queue.length; i++) {
                BonusWaitItem memory waitItem = _draw_queue[i];
                if(waitItem.stamp + WAIT_SECOND <= currentStamp){
                    BonusItem memory item =  _current_stake[waitItem.walletAddr];
                    if(item.stamp > 0){
                        require(IERC20(waitItem.tokenId).transferFrom(address(this), waitItem.walletAddr, waitItem.amount), "draw Transfer failed");
                        _draw_amount_mapping[waitItem.walletAddr] -= waitItem.amount;
                        // 更新当前账户质押额度
                        uint currentAmount = item.amount - waitItem.amount;
                        _current_stake[waitItem.walletAddr].amount = currentAmount;
                        if(currentAmount == 0 ){
                            _current_stake[waitItem.walletAddr].stamp = 0;
                            // 若质押额度为0，则移除质押人
                            _stake_users.remove(waitItem.walletAddr);
                        }
                    }
                    popCount++;
                }else{
                    break ;
                }
            }
            for (uint j = 0;j<popCount;j++){
                _draw_queue.pop();
            }
        }
    }


    /**
     红利计算  + 更新用户红利池子
    */
    function bonusCalculate(uint amount) public {
         _checkOwner();
        uint currentStamp = block.timestamp;
        uint total = 0;
        uint calLen = _stake_users.length();
        CalculateItem[]  memory calculateArray = new CalculateItem[](calLen);            
        for (uint i = 0; i < _stake_users.length(); i++) 
        {    
            address userAddr = EnumerableSet.at(_stake_users,i);
            BonusItem memory current = _current_stake[userAddr];
            // 总分数
            uint baseScore = _support_tokens[current.tokenId];
            require(baseScore != 0,"error support token " );
            uint userScore = current.amount * baseScore;
            total += userScore;
            CalculateItem memory calItem = CalculateItem(userAddr,userScore);
            calculateArray[i] = calItem;
        }
        
        for (uint c = 0; c < calculateArray.length; c++) 
        {
            CalculateItem memory item = calculateArray[c];
            uint userBonusAmount = amount * (item.score/total);
            if(_bonus_pool[item.userAddr].lastStamp > 0 ){
                _bonus_pool[item.userAddr].amount += userBonusAmount;
                _bonus_pool[item.userAddr].lastStamp = currentStamp;
            }else{
                _bonus_pool[item.userAddr] = BonusPoolItem(currencyToken,userBonusAmount,currentStamp);
            }
        }      
    }
    
    // 红利领取
    function bonusWithDraw() external {
        BonusPoolItem memory bonusPoolItem = _bonus_pool[msg.sender];
        require(bonusPoolItem.lastStamp >0, "no bonus");
        require(bonusPoolItem.amount >0, "no enough bonus");
        require(IERC20(bonusPoolItem.tokenId).transferFrom(address(this), msg.sender, bonusPoolItem.amount), "bonus draw failed");
        _bonus_pool[msg.sender].amount = 0;
        _bonus_pool[msg.sender].lastStamp = block.timestamp;
    }

}