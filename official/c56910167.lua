--超弩級砲塔列車グスタフ・マックス
--Superdreadnought Rail Cannon Gustav Max
local s,id=GetID()
function s.initial_effect(c)
	--Xyz Summon
	Xyz.AddProcedure(c,nil,10,2)
	c:EnableReviveLimit()
	--Burn for 2000 LP
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(aux.dxmcostgen(1,1,nil))
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1,false,REGISTER_FLAG_DETACH_XMAT)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(2000)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,2000)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
end
