--火麺胸焼け背脂の術
--The Noodle Art of Savory

--Substitute ID
local s,id=GetID()
function s.initial_effect(c)
	--Make 1 of opponent's monsters lose 400 ATK per pyro monster you control
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.filter(c)
	return c:IsFaceup() and c:IsAttackPos() and c:IsNotMaximumModeSide()
end
--Activation legality
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsRace,RACE_PYRO),tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_MZONE,1,nil)
	end
end
--Make 1 of opponent's monsters lose 400 ATK per pyro monster you control
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local ct=Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsRace,RACE_PYRO),c:GetControler(),LOCATION_MZONE,0,nil)
	--Effect
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(ct*(-400))
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		g:GetFirst():RegisterEffect(e1)
	end
end