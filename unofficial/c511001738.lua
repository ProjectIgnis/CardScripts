--Blizzard Egg Level 5
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(10000080,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_DAMAGE)
	e1:SetCondition(s.condition1)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetDescription(aux.Stringid(10000080,1))
	e2:SetCondition(s.condition2)
	c:RegisterEffect(e2)
end
function s.condition1(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and (r&REASON_EFFECT)~=0
end
function s.condition2(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and (r&REASON_EFFECT)~=0
end
function s.filter(c,e,tp)
	return c:GetLevel()==5 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(ep,LOCATION_MZONE)>0 
		and Duel.IsPlayerCanSpecialSummonMonster(ep,0,0,TYPE_MONSTER,0,0,5,0,0) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,ep,LOCATION_HAND)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,ep,500)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsPlayerCanSpecialSummonMonster(ep,0,0,TYPE_MONSTER,0,0,5,0,0) then return end
	local g=Duel.GetMatchingGroup(s.filter,ep,LOCATION_HAND,0,nil,e,ep)
	if Duel.GetLocationCount(ep,LOCATION_MZONE)>0 and #g>0 and Duel.SelectYesNo(ep,aux.Stringid(20758643,1)) then
		Duel.Hint(HINT_SELECTMSG,ep,HINTMSG_SPSUMMON)
		local sg=g:Select(ep,1,1,nil)
		Duel.SpecialSummon(sg,0,ep,ep,false,false,POS_FACEUP)
	else
		Duel.Damage(ep,500,REASON_EFFECT)
	end
end
