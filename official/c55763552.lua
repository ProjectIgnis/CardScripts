--壺魔人
local s,id=GetID()
function s.initial_effect(c)
	--flip
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_names={50045299}
function s.filter(c)
	return c:IsFaceup() and c:IsCode(50045299)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_SZONE,LOCATION_SZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.pfilter(c)
	return c:IsPosition(POS_FACEUP_DEFENSE) and c:IsRace(RACE_DRAGON)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_SZONE,LOCATION_SZONE,nil)
	if Duel.Destroy(g,REASON_EFFECT)>0 then
		local pg=Duel.GetMatchingGroup(s.pfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		Duel.ChangePosition(pg,POS_FACEUP_ATTACK)
	end
end
