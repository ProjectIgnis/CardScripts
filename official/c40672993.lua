--避雷神
--Lightning Rod Lord
local s,id=GetID()
function s.initial_effect(c)
	--actlimit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(1,1)
	e1:SetValue(s.actlimit)
	c:RegisterEffect(e1)
end
function s.actlimit(e,te,tp)
	return Duel.IsPhase(PHASE_MAIN1)
		and te:IsHasType(EFFECT_TYPE_ACTIVATE) and te:IsSpellEffect()
end