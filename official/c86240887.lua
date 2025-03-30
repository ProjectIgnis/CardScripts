--竜破壊の剣士－バスター・ブレイダー
--Buster Blader, the Dragon Destroyer Swordsman
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,CARD_BUSTER_BLADER,aux.FilterBoolFunctionEx(Card.IsRace,RACE_DRAGON))
	--cannot direct attack
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	c:RegisterEffect(e1)
	--ATK Gain
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.val)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	--spsummon condition
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e4:SetCode(EFFECT_SPSUMMON_CONDITION)
	e4:SetValue(aux.fuslimit)
	c:RegisterEffect(e4)
	--Pos Change
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_SET_POSITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTarget(s.target)
	e5:SetTargetRange(0,LOCATION_MZONE)
	e5:SetValue(POS_FACEUP_DEFENSE)
	c:RegisterEffect(e5)
	--Prevent Activation
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCode(EFFECT_CANNOT_ACTIVATE)
	e6:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e6:SetTargetRange(0,1)
	e6:SetValue(s.aclimit)
	c:RegisterEffect(e6)
	--pierce
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e7)
end
s.material_setcode=SET_BUSTER_BLADER
function s.val(e,c)
	return Duel.GetMatchingGroupCount(s.filter,c:GetControler(),0,LOCATION_GRAVE|LOCATION_MZONE,nil)*1000
end
function s.filter(c)
	return c:IsRace(RACE_DRAGON) and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
end
function s.target(e,c)
	return c:IsRace(RACE_DRAGON)
end
function s.aclimit(e,re,tp)
	return re:GetHandler():IsRace(RACE_DRAGON) and re:IsMonsterEffect()
end