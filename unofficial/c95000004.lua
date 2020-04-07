--Darkness/Trap B (Infinity)
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.mark=0
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id+1)>0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetChainLimit(s.climit)
end
function s.climit(e,lp,tp)
	return lp==tp or not e:IsHasType(EFFECT_TYPE_ACTIVATE)
end
function s.filter(c,code)
	return c:GetCode()==code and c:IsFacedown()
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g1=Duel.GetFirstMatchingCard(s.filter,tp,LOCATION_SZONE,0,nil,95000006)
	local g2=Duel.GetFirstMatchingCard(s.filter,tp,LOCATION_SZONE,0,nil,95000007)
	local g3=Duel.GetFirstMatchingCard(s.filter,tp,LOCATION_SZONE,0,nil,95000008)
	if g1 then
		Duel.ChangePosition(g1,POS_FACEUP)
		g1:SetStatus(STATUS_EFFECT_ENABLED,true)
		g1:SetStatus(STATUS_CHAINING,true)
	end
	if g2 then
		Duel.ChangePosition(g2,POS_FACEUP)
		g2:SetStatus(STATUS_EFFECT_ENABLED,true)
		g2:SetStatus(STATUS_CHAINING,true)
	end
	if g3 then
		Duel.ChangePosition(g3,POS_FACEUP)
		g3:SetStatus(STATUS_EFFECT_ENABLED,true)
		g3:SetStatus(STATUS_CHAINING,true)
	end
end
