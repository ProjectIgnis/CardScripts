--深海王デビルシャーク
local s,id=GetID()
function s.initial_effect(c)
	--battle indes
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e1:SetCountLimit(1)
	e1:SetValue(s.valcon)
	c:RegisterEffect(e1)
end
function s.valcon(e,re,r,rp)
	return (r&REASON_EFFECT)~=0 and not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET)
end
