--マジシャン・オブ・ブラックカオス
--Magician of Black Chaos
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Ritual
	c:EnableReviveLimit()
	--Name becomes "Dark Magician" while in the GY
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetValue(CARD_DARK_MAGICIAN)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_DARK_MAGICIAN}