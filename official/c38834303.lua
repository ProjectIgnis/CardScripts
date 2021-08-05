--カウンタークリーナー
--Counter Cleaner
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	Duel.PayLPCost(tp,500)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.HasCounters,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local count=0
	for tc in Duel.GetMatchingGroup(Card.HasCounters,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil):Iter() do
		count=count+tc:GetCounter(COUNTER_A)
		tc:RemoveAllCounters()
	end
	if count>0 then
		Duel.RaiseEvent(e:GetHandler(),EVENT_REMOVE_COUNTER+COUNTER_A,e,REASON_EFFECT,tp,tp,count)
	end
end
