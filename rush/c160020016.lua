--昆遁忍虫 紅蓮天刀のナナホシ
--Evasive Chaos Ninsect Crimson Blade Nanahoshi
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Gains 500 ATK per each Insect monster on the field
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.val)
	c:RegisterEffect(e1)
end
function s.val(e,c)
	return Duel.GetMatchingGroupCountRush(aux.FaceupFilter(Card.IsRace,RACE_INSECT),c:GetControler(),LOCATION_MZONE,LOCATION_MZONE,nil)*500
end