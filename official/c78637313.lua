--闇からの呼び声
--Call of Darkness
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Send monsters Special Summoned by "Monster Reborn" to the GY
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EVENT_ADJUST)
	e2:SetRange(LOCATION_SZONE)
	e2:SetOperation(s.adjustop)
	c:RegisterEffect(e2)
	--Cannot set "Monster Reborn"
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EFFECT_CANNOT_SSET)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(0,1)
	e3:SetTarget(function(_,c)return c:IsCode(CARD_MONSTER_REBORN)end)
	c:RegisterEffect(e3)
	--Cannot activate "Monster Reborn"
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_SZONE)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EFFECT_CANNOT_ACTIVATE)
	e4:SetTargetRange(0,1)
	e4:SetValue(function(_,re)return re:GetHandler():IsCode(CARD_MONSTER_REBORN)end)
	c:RegisterEffect(e4)
end
s.listed_names={CARD_MONSTER_REBORN}
function s.adjustop(e,tp,eg,ep,ev,re,r,rp)
	local phase=Duel.GetCurrentPhase()
	if (phase==PHASE_DAMAGE and not Duel.IsDamageCalculated()) or phase==PHASE_DAMAGE_CAL then return end
	local g=Duel.GetMatchingGroup(Card.IsSummonType,0,LOCATION_MZONE,LOCATION_MZONE,nil,SUMMON_TYPE_SPECIAL+SUMMON_WITH_MONSTER_REBORN)
	if Duel.SendtoGrave(g,REASON_EFFECT)>0 then
		Duel.Readjust()
	end
end