--幻壊双姫オー・ド・ショース
--Demolition Twin Princesses Haut-de-Chausses
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,160021014,160021015)
	--Spells/Traps cannot be returned
	local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_TO_DECK)
    e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(s.indcond)
    e1:SetTargetRange(LOCATION_ONFIELD,0)
    e1:SetValue(s.indtg)
    c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_TO_HAND)
	c:RegisterEffect(e2)
end
function s.indcond(e)
	return Duel.IsTurnPlayer(1-e:GetHandlerPlayer())
end
function s.indtg(e,c,rp,reason,re)
    return reason==REASON_EFFECT and c:IsSpellTrap()
end