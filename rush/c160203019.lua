--超越進化
-- Transcendental Evolution
local s,id=GetID()
function s.initial_effect(c)
	--Increase ATK
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.filter1(c,e,tp)
	return c:IsSummonPlayer(1-tp) and c:IsLocation(LOCATION_MZONE) and c:IsLevelAbove(7)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.filter1,1,nil,e,tp)
end
	--Activation legality
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsRace,RACE_DINOSAUR),tp,LOCATION_MZONE,0,1,nil) end
end
	--Make 1 dino monster you control gain ATK
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	--Effect
	local g=Duel.SelectMatchingCard(tp,aux.FilterFaceupFunction(Card.IsRace,RACE_DINOSAUR),tp,LOCATION_MZONE,0,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		local tc=g:GetFirst()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffectRush(e1)
		--Cannot be destroyed by opponent's card effects
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(3060)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e1:SetValue(aux.indoval)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end