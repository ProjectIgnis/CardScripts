--ギャラクティカ・カオス・オブリビオン
--Galactica Chaos Oblivion
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,CARD_GALACTICA_OBLIVION,160010025)
	--Cannot be destroyed
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(3001)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE|EFFECT_FLAG_CLIENT_HINT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--Gain ATK
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
end
function s.atkfilter(c)
	return c:IsRace(RACE_GALAXY) and c:IsType(TYPE_NORMAL)
end
function s.atkval(e)
	local atk=0
	if not Duel.IsExistingMatchingCard(Card.IsSpellTrap,e:GetHandlerPlayer(),0,LOCATION_ONFIELD,1,nil) then
		atk=1500
	end
	return atk+Duel.GetMatchingGroupCount(s.atkfilter,e:GetHandlerPlayer(),LOCATION_GRAVE,0,nil)*300
end