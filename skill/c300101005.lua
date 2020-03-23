--Tomb of the Pharaoh
--Skill activation
--At the start of the Duel, place this card in your Field Zone and flip it over.
--Effect
--This card's name is always treated as "Necrovalley".
--All "Gravekeeper's" monsters on the field gain 200 ATK/DEF.
local s,id=GetID()
function s.initial_effect(c)
	aux.AddFieldSkillProcedure(c,2,false)
	--Activate
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_ACTIVATE)
	e3:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e3)
	--Atk&Def
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x2e))
	e2:SetValue(200)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	--change name
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e6:SetCode(EFFECT_CHANGE_CODE)
	e6:SetRange(0xff)
	e6:SetValue(47355498)
	c:RegisterEffect(e6)
end
