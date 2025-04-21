--竜騎士ブラック・マジシャン
--Dark Magician the Dragon Knight
local s,id=GetID()
function s.initial_effect(c)
	--Fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,CARD_DARK_MAGICIAN,aux.FilterBoolFunctionEx(Card.IsRace,RACE_DRAGON))
	--Change name
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e1:SetValue(CARD_DARK_MAGICIAN)
	c:RegisterEffect(e1)
	--Cannot be destroyed
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_ONFIELD,0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSpellTrap))
	e2:SetValue(aux.indoval)
	c:RegisterEffect(e2)
end
s.material_setcode=0x10a2
s.listed_names={CARD_DARK_MAGICIAN}
s.named_material={160301005}