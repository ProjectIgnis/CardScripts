--トランザム・プライム・マスターノヴァ
--Transam Praime Master Nova
--scripted by Cybercatman
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion Materials: "Transam Praime Armor Nova" + 1 Level 8 or lower LIGHT Attribute monster
	Fusion.AddProcMixN(c,true,true,160016008,1,s.matfilter,1)
	--Monsters on your field cannot be returned to the hand/Deck/Extra Deck by card effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_TO_DECK)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(function(e,c) return c:IsMonster() end)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetCondition(s.noreturncondition)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_TO_HAND)
	c:RegisterEffect(e2)
	--Face-up monsters on your opponent's field become LIGHT Attribute
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetCode(EFFECT_CHANGE_ATTRIBUTE)
	e3:SetValue(ATTRIBUTE_LIGHT)
	c:RegisterEffect(e3)
end
s.named_material={160016008} --"Transam Praime Armor Nova"
function s.matfilter(c,scard,sumtype,tp)
	return c:IsAttribute(ATTRIBUTE_LIGHT,scard,sumtype,tp) and c:IsLevelBelow(8)
end
function s.noreturncondition(e)
	local source_eff=Duel.GetReasonEffect()
	return source_eff and (source_eff:IsActivated() or not source_eff:GetCode()==EFFECT_SPSUMMON_PROC)
end