--黒刹の王 ゼイル
--Zeil the King of the Hollowed Grounds
--scripted by Cybercatman
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion Materials: "Doomed by the Blackblight" + "The Royal Crown of Zeil" + "The Royal Sword of Zeil"
	Fusion.AddProcMix(c,true,true,CARD_DOOMED_BY_THE_BLACKBLIGHT,160027021,160027022)
	Fusion.AddUnionFusionProc(c)
	--Face-up DARK Attribute Warrior Type monsters on your field inflict piercing battle damage
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_PIERCE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.target)
	c:RegisterEffect(e1)
	--Face-up DARK Attribute Warrior Type monsters on your field cannot be destroyed by card effects
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetTargetRange(LOCATION_ONFIELD,0)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(s.target)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
function s.target(e,c)
	return c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsFaceup()
end