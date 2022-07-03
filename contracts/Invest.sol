// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "./Ownable.sol";
import "./Context.sol";
import "./IBEP20.sol";

struct SaleEvent {
    bool paused;
    uint256 minBusd;
    uint256 maxBusd;
    uint256 buyRate;
    uint256 buybackRate;
}

contract Invest is Ownable {
    IBEP20 private _dlpContract = IBEP20(0xD7ACd2a9FD159E69Bb102A1ca21C9a3e3A5F771B);
    IBEP20 private _busdContract = IBEP20(0x7EF2e0048f5bAeDe046f6BF797943daF4ED8CB47);
    SaleEvent private _event;
    mapping(address => uint256) private _invests;
    uint256 private _frozenDlp = 0;

    function _withdraw() private {
        uint256 busdBalance = _busdContract.balanceOf(address(this));
        require(busdBalance > 0, "Insufficient busd");

        _busdContract.transfer(_msgSender(), busdBalance);
    }

    function _withdrawDlp(address recipient) private {
        _dlpContract.transfer(recipient, _freeDlpAmount());
    }

    function _createEvent(SaleEvent memory ev) private returns (SaleEvent storage) {
        require(_event.minBusd == 0, "Event already started");

        _event = ev;

        return _event;
    }

    function _freeDlpAmount() private view returns (uint256) {
        return _dlpContract.balanceOf(address(this)) - _frozenDlp;
    }

    function _invest(address investor, uint256 busdAmount) private {
        require(_event.paused == false, "Event is paused");
        require(_event.buyRate > 0, "Rate not specified");

        uint256 allowedBalance = _busdContract.allowance(investor, address(this));
        uint256 wantDlpAmount = busdAmount / _event.buyRate;

        require(allowedBalance >= busdAmount, "Insufficient allowed balance");
        require(_freeDlpAmount() >= wantDlpAmount, "No free DLP amount");

        _busdContract.transferFrom(investor, address(this), busdAmount);
        _invests[investor] += wantDlpAmount;
        _frozenDlp += wantDlpAmount;
    }

    function _investBalance(address investor) private view returns (uint256 dlp, uint256 busd) {
        dlp = _invests[investor];
        busd = _invests[investor] * _event.buybackRate;

        return (dlp, busd);
    }

    function createEvent(
        uint256 minBusd,
        uint256 maxBusd,
        uint256 buyRate,
        uint256 buybackRate
    ) public onlyOwner returns (SaleEvent memory) {
        return _createEvent(SaleEvent({
            paused: false,
            minBusd: minBusd,
            maxBusd: maxBusd,
            buyRate: buyRate,
            buybackRate: buybackRate
        }));
    }

    function invest(uint256 busdAmount) public {
        _invest(_msgSender(), busdAmount);
    }

    function withdraw() public onlyOwner {
        _withdraw();
    }

    function withdrawDlp() public onlyOwner {
        _withdrawDlp(_msgSender());
    }

    function currentEvent() public view returns  (SaleEvent memory) {
        return _event;
    }

    function contracts() public view returns (address dlp, address busd) {
        return (address(_busdContract), address(_dlpContract));
    }

    function balance() public view returns (uint256 dlp, uint256 busd, uint256 frozen, uint256 free) {
        dlp = _dlpContract.balanceOf(address(this));
        busd = _busdContract.balanceOf(address(this));
        frozen = _frozenDlp;
        free = dlp - frozen;

        return (dlp, busd, frozen, free);
    }

    function investBalanceOf(address investor) public view returns (uint256 dlp) {
        return (_invests[investor]);
    }
}