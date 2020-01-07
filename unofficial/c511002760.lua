--H・C ダブル・ランス
local s,id=GetID()
function s.initial_effect(c)
	--
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(511001225)
	e2:SetOperation(s.tgval)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
function s.tgval(e,c)
	return c:IsSetCard(0x206f)
end
