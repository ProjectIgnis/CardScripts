--ブラック・マジシャン・ガール
--Dark Magician Girl
local s,id=GetID()
function s.initial_effect(c)
	--Gains 300 ATK for every "Dark Magician" or "Magician of Black Chaos" in the GYs
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_DARK_MAGICIAN,30208479} --"Magician of Black Chaos"
function s.atkval(e,c)
	return 300*Duel.GetMatchingGroupCount(Card.IsCode,0,LOCATION_GRAVE,LOCATION_GRAVE,nil,CARD_DARK_MAGICIAN,30208479)
end