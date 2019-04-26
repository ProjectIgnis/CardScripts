--破壊剣士－マスター・ブレイダー
--Master Destruction Swordsman
--Scripted by Eerie Code
function c120401010.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,c120401010.matfilter,1)
	--fusion linking
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_BECOME_LINKED_ZONE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetValue(31)
	e1:SetCondition(c120401010.condition)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(1,0)
	e2:SetCondition(c120401010.condition)
	e2:SetTarget(c120401010.splimit)
	c:RegisterEffect(e2)
end
function c120401010.matfilter(c,lc,sumtype,tp)
	return c:IsRace(RACE_WARRIOR,lc,sumtype,tp) and c:IsAttribute(ATTRIBUTE_EARTH,lc,sumtype,tp) and c:GetLevel()==7
end
function c120401010.filter(c)
	return c:IsFaceup() and c:IsCode(11790356)
end
function c120401010.condition(e)
	local lg=e:GetHandler():GetLinkedGroup()
	return lg and lg:IsExists(c120401010.filter,1,nil)
end
function c120401010.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA) and bit.band(sumtype,SUMMON_TYPE_FUSION)~=SUMMON_TYPE_FUSION
end
