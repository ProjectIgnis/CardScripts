--Gouki Shout
--fixed by MLD
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--atk up
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(s.atkcon)
	e2:SetTarget(s.atktg)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
end
s.listed_series={0xfc}
function s.atkcon(e)
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_DAMAGE or ph==PHASE_DAMAGE_CAL
end
function s.atktg(e,c)
	return c==Duel.GetAttacker() and c:IsSetCard(0xfc)
end
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xfc)
end
function s.atkval(e,c)
	local sg=Duel.GetMatchingGroup(s.filter,c:GetControler(),LOCATION_MZONE,0,nil)
	return #sg*300
end
