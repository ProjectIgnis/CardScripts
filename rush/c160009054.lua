--ストレンジ・ウォール
--Strange Wall
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Decrease ATK
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.condition)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp,chk)
	return Duel.GetAttacker():IsControler(1-tp) and Duel.IsExistingMatchingCard(Card.IsRace,tp,LOCATION_GRAVE,0,1,nil,RACE_GALAXY)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local bc=Duel.GetAttacker()
	if bc:IsRelateToBattle() and bc:IsFaceup() then
		--Decrease ATK
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(-500)
		bc:RegisterEffect(e1)
	end
end