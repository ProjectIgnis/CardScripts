--プロト・サイバー・ドラゴン (Rush)
--Proto-Cyber Dragon (Rush)
local s,id=GetID()
function s.initial_effect(c)
	--Name becomes "Cyber Dragon"
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(CARD_CYBER_DRAGON)
	c:RegisterEffect(e1)
end
s.listes_names={CARD_CYBER_DRAGON}