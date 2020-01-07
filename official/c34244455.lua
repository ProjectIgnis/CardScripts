--星向鳥
--Which Starling
--Scripted by AlphaKretin
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetCondition(s.lvcon)
	e1:SetValue(s.lvval)
	c:RegisterEffect(e1)
end
s.levels={4,1,2,1,3}
function s.lvcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSequence()<5
end
function s.lvval(e,tp,eg,ep,ev,re,r,rp)
	return s.levels[e:GetHandler():GetSequence()+1]
end
