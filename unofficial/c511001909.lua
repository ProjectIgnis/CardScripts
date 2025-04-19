--ギャンブル天使バニー
--Gamble Angel Bunny
local s,id=GetID()
function s.initial_effect(c)
	--coin
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_COIN+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.damtg)
	e1:SetOperation(s.damop)
	c:RegisterEffect(e1)
end
s.toss_coin=true
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.CallCoin(tp) then
		Duel.Damage(1-tp,1000,REASON_EFFECT)
	else
		Duel.Damage(tp,1000,REASON_EFFECT)
	end
end