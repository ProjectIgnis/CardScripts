--Plunder Decoy
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local d=Duel.GetAttackTarget()
	return d and d:IsControler(tp)
end
function s.filter(c)
	return c:IsControlerCanBeChanged() and c:IsFaceup() and c:IsLevelBelow(4)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_MZONE,1,Duel.GetAttacker()) end
	local g=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_MZONE,Duel.GetAttacker())
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,0,LOCATION_MZONE,1,1,Duel.GetAttacker())
	local tc=g:GetFirst()
	if tc then
		Duel.HintSelection(g)
		Duel.GetControl(tc,tp)
	end
end
