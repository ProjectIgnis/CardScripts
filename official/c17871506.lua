--真紅眼の凶星竜－メテオ・ドラゴン
local s,id=GetID()
function s.initial_effect(c)
	aux.EnableGeminiAttribute(c)
	--indes
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.indtg)
	e1:SetValue(1)
	e1:SetCondition(aux.IsGeminiState)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e2)
end
s.listed_series={0x3b}
function s.indtg(e,c)
	return c:IsSetCard(0x3b) and c~=e:GetHandler()
end
