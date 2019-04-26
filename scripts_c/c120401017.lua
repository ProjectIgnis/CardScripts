--湿地草原からの宝札
--Cards From the Wetlands
--Scritped by Eerie Code
function c120401017.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c120401017.cost)
	e1:SetTarget(c120401017.target)
	e1:SetOperation(c120401017.activate)
	c:RegisterEffect(e1)
end
function c120401017.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x12) and c:IsDiscardable()
end
function c120401017.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c120401017.filter,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,c120401017.filter,1,1,REASON_COST+REASON_DISCARD)
end
function c120401017.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(2)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
function c120401017.activate(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end
