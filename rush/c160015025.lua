--真紅眼の月竜
--Red-Eyes Moon Dragon
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Name becomes "Red-Eyes Black Dragon" in the hand
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_CHANGE_CODE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetRange(LOCATION_HAND)
	e0:SetValue(CARD_REDEYES_B_DRAGON)
	c:RegisterEffect(e0)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_ADD_CODE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(CARD_REDEYES_B_DRAGON)
	e1:SetOperation(s.chngcon)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_REDEYES_B_DRAGON}
function s.chngcon(scard,sumtype,tp)
	return (sumtype&MATERIAL_FUSION)~=0 or (sumtype&SUMMON_TYPE_FUSION)~=0
end