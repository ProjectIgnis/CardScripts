--グレイヴ・キーパー
local s,id=GetID()
function s.initial_effect(c)
	--todeck
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(s.rmtarget)
	e1:SetValue(LOCATION_DECKSHF)
	c:RegisterEffect(e1)
end
function s.rmtarget(e,c)
	return c:IsReason(REASON_BATTLE)
end
