--クイズ： 数学の１００
--Quiz Action - Math for 100
local s,id=GetID()
function s.initial_effect(c)
	--Activate/Answer
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local op=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2),aux.Stringid(id,3))
	e:SetLabel(op)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
	Duel.Damage(tp,100,REASON_EFFECT)
	elseif e:GetLabel()==1 then
	Duel.Recover(tp,100,REASON_EFFECT)
	elseif e:GetLabel()==2 then
	Duel.Damage(tp,100,REASON_EFFECT)
	elseif e:GetLabel()==3 then
	Duel.Damage(tp,100,REASON_EFFECT)
	end
end