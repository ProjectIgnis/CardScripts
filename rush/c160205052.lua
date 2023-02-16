--魔将ヤメルーラ－武槍
--Yamiruler the Dark Delayer - Supreme Soldier Spear
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Indestructable
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.indtg)
	e1:SetValue(s.efilter)
	c:RegisterEffect(e1)
end
function s.indtg(e,c)
	return c:IsLevelAbove(7) and c:IsRace(RACE_WARRIOR|RACE_CELESTIALWARRIOR)
end
function s.efilter(e,re,rp)
	return re:IsTrapEffect() and aux.indoval(e,re,rp)
end