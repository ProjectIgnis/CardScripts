--運命の分かれ道
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_COIN)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.toss_coin=true
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,PLAYER_ALL,2)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local res=Duel.TossCoin(tp,1)
	if res==1 then Duel.Recover(tp,2000,REASON_EFFECT)
	else Duel.Damage(tp,2000,REASON_EFFECT) end
	res=Duel.TossCoin(1-tp,1)
	if res==1 then Duel.Recover(1-tp,2000,REASON_EFFECT)
	else Duel.Damage(1-tp,2000,REASON_EFFECT) end
end
