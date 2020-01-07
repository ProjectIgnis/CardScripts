--Action Card - Quiz Action - Trivia for 1000
function c150000059.initial_effect(c)
	--Activate/Answer
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c150000059.target)
	e1:SetOperation(c150000059.activate)
	c:RegisterEffect(e1)
end
function c150000059.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local op=Duel.SelectOption(tp,aux.Stringid(150000059,0),aux.Stringid(150000059,1))
	e:SetLabel(op)
end
function c150000059.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
	Duel.Damage(tp,1000,REASON_EFFECT)
	elseif e:GetLabel()==1 then
	Duel.Recover(tp,1000,REASON_EFFECT)
	end
end