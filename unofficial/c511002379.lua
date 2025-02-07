--摩天楼 －スカイスクレイパー－ (Anime)
--Skyscraper (Anime)
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--That battling "Elemental HERO" monster gains 1000 ATK during damage calculation only
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetCondition(s.atkcon)
	e2:SetTarget(s.atktg)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
end
s.listed_series={SET_ELEMENTAL_HERO}
function s.atkcon(e)
	s[0]=false
	return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL and Duel.GetAttackTarget() and Duel.GetAttacker()
end
function s.atktg(e,c)
	return (c==Duel.GetAttacker() and c:IsSetCard(SET_ELEMENTAL_HERO)) or (c==Duel.GetAttackTarget() and c:IsSetCard(SET_ELEMENTAL_HERO))
end
function s.atkval(e,c)
	local d=Duel.GetAttackTarget()
	if d==c then d=Duel.GetAttacker() end
	if s[0] or (c:GetAttack()<d:GetAttack() and d:IsControler(1-e:GetHandlerPlayer())) then
		s[0]=true
		return 1000
	else return 0 end
end
