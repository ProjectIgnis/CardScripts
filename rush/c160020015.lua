--昆遁忍虫 変妖魔笛のアゲハ
--Evasive Chaos Ninsect Bewitching Flute Ageha
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Change to Insect
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_RACE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(RACE_INSECT)
	c:RegisterEffect(e1)
end