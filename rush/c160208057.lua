--幻壊壁礫
--Demolition Barricade
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Negate opponent monster's attack
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.zfilter(c)
	return c:IsRace(RACE_WYRM) and c:IsLevelAbove(7) and c:IsFaceup()
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttacker()
	return tc:IsControler(1-tp) and tc:IsLevelBelow(8) and Duel.IsExistingMatchingCard(s.zfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateAttack()
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetTarget(function(e,c) return c:IsLevelBelow(7) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end