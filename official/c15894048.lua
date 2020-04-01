--究極恐獣
local s,id=GetID()
function s.initial_effect(c)
	--attack
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.catg)
	e1:SetCondition(s.cacon)
	c:RegisterEffect(e1)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_ATTACK_ALL)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
s.listed_names={id}
function s.catg(e,c)
	return not c:IsCode(id)
end
function s.cfilter(c)
	if not c:IsFaceup() or not c:IsCode(id) or not c:CanAttack() then return false end
	local ag,direct=c:GetAttackableTarget()
	return #ag>0 or direct
end
function s.cacon(e)
	return Duel.GetCurrentPhase()>PHASE_MAIN1 and Duel.GetCurrentPhase()<PHASE_MAIN2
		and Duel.IsExistingMatchingCard(s.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
