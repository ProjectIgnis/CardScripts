--クイズ： 数学の５０００
--Quiz Action - Math 5000
local s,id=GetID()
function s.initial_effect(c)
	--Activate/Answer
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_COIN+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.CallCoin(tp) then
		Duel.Recover(tp,5000,REASON_EFFECT)
	else
		Duel.Damage(tp,1000,REASON_EFFECT)
	end
end