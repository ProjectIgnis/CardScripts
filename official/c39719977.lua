--デルタ・アタッカー
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.filter(c,tp)
	local tpe=c:GetType()
	return c:IsFaceup() and (tpe&TYPE_NORMAL)~=0 and (tpe&TYPE_TOKEN)==0
		and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_MZONE,0,2,c,c:GetCode())
end
function s.filter2(c,code)
	local tpe=c:GetType()
	return c:IsFaceup() and (tpe&TYPE_NORMAL)~=0 and (tpe&TYPE_TOKEN)==0 and c:IsCode(code)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,3,nil,tp) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil,tp)
	local tc=g:GetFirst()
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DIRECT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
