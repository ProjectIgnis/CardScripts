--エルフェンノーツ～再邂のテルチェット～
--Elvennotes ~Reunion Tercet~
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Your opponent cannot target the monster in your center Main Monster Zone with card effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(function(e,c) return c:IsSequence(2) end)
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	--● FIRE/EARTH: If your Synchro Monster attacks a Defense Position monster, inflict piercing battle damage to your opponent
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_PIERCE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(function(e,c) return c:IsSynchroMonster() end)
	e2:SetCondition(s.effcon)
	e2:SetLabel(ATTRIBUTE_FIRE|ATTRIBUTE_EARTH)
	c:RegisterEffect(e2)
	--● WATER/WIND: Other face-up Spells/Traps you control cannot be destroyed by your opponent's card effects
	local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetTargetRange(LOCATION_ONFIELD,0)
	e3:SetTarget(function(e,c) return c:IsSpellTrap() and c~=e:GetHandler() end)
	e3:SetValue(aux.indoval)
	e3:SetLabel(ATTRIBUTE_WATER|ATTRIBUTE_WIND)
	c:RegisterEffect(e3)
	--● LIGHT/DARK: You take no battle damage
	local e4=e2:Clone()
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e4:SetTargetRange(1,0)
	e4:SetTarget(aux.TRUE)
	e4:SetLabel(ATTRIBUTE_LIGHT|ATTRIBUTE_DARK)
	c:RegisterEffect(e4)
end
function s.effconfilter(c,attr)
	return c:IsSequence(2) and c:IsAttribute(attr) and c:IsFaceup()
end
function s.effcon(e)
	return Duel.IsExistingMatchingCard(s.effconfilter,e:GetHandlerPlayer(),LOCATION_MMZONE,0,1,nil,e:GetLabel())
end