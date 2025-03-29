--救世竜 セイヴァー・ドラゴン
--Majestic Dragon
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetValue(s.synlimit)
	c:RegisterEffect(e1)
end
s.listed_series={SET_MAJESTIC}
function s.synlimit(e,c)
	if not c then return false end
	return not c:IsSetCard(SET_MAJESTIC)
end