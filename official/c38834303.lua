--カウンタークリーナー
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
function s.filter(c)
	return c:GetCounter(0)~=0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	local tc=sg:GetFirst()
	local count=0
	for tc in aux.Next(sg) do
		count=count+tc:GetCounter(0x100e)
		tc:RemoveCounter(tp,0,0,0)
	end
	if count>0 then
		Duel.RaiseEvent(e:GetHandler(),EVENT_REMOVE_COUNTER+0x100e,e,REASON_EFFECT,tp,tp,count)
	end
end
