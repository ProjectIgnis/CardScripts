--寄生蠢動
--Parasite Maneuver
--Fixed by MLD
local s,id=GetID()
function s.initial_effect(c)
	--During the Battle Phase, if 1 monster equipped with "Fusion Parasite" attacked: That monster can make a second attack.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_BATTLE_PHASE)
	e1:SetCondition(function() return Duel.IsBattlePhase() end)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={6205579} --"Fusion Parasite"
function s.exatkfilter(c)
	return c:IsFaceup() and c:GetEquipGroup():IsExists(Card.IsCode,1,nil,6205579) and c:GetAttackedCount()==1
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.exatkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectMatchingCard(tp,s.exatkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	local tc=g:GetFirst()
	if tc and tc:IsFaceup() then
		--Can make a second attack
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3201)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_BATTLE)
		tc:RegisterEffect(e1)
	end
end
