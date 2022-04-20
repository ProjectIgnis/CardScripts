--マジシャン・オブ・ダークセブンス
--Magician of Dark Sevens
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,CARD_SEVENS_ROAD_MAGICIAN,160428006)
	--Increase ATK
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	--No battle damage from your other monsters
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.efilter)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
function s.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_SPELLCASTER)
end
function s.atkval(e,c)
	local ct=Duel.GetMatchingGroupCount(s.cfilter,e:GetHandlerPlayer(),LOCATION_GRAVE,0,nil)
	return ct*300
end
function s.efilter(e,c)
	return c~=e:GetHandler()
end