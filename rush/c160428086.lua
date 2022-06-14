--呪い猫の皿勘定
--The Cursed Cat Counting Dishes
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Negate opponent monster's attack
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.zfilter(c)
	return c:IsRace(RACE_ZOMBIE) and c:IsLevelAbove(7) and c:IsFaceup()
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttacker()
	return tc:IsControler(1-tp) and tc:IsLevelBelow(9) and Duel.IsExistingMatchingCard(s.zfilter,tp,LOCATION_MZONE,0,1,nil) 
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateAttack()
end