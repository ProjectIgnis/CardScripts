--メテオ・スカル・デーモン
--Meteor Skull Archfiend
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Procedure
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,CARD_SUMMONED_SKULL,1,s.ffilter,1)
	--Monsters cannot be returned
	local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_TO_DECK)
    e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(s.indcond)
    e1:SetTargetRange(LOCATION_MZONE,0)
    e1:SetValue(s.indtg)
    c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_TO_HAND)
	c:RegisterEffect(e2)
end
function s.ffilter(c,fc,sumtype,tp)
	return c:IsAttribute(ATTRIBUTE_EARTH,fc,sumtype,tp) and c:IsRace(RACE_DRAGON,fc,sumtype,tp) and c:IsAttack(1800)
end
function s.indcond(e)
	return Duel.IsTurnPlayer(1-e:GetHandlerPlayer())
end
function s.indtg(e,c,rp,reason,re)
    return reason==REASON_EFFECT and c:IsMonster()
end