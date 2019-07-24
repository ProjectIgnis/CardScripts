--Kuribabylon
local s,id=GetID()
function s.initial_effect(c)
	--ss success
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.atkcon)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
	--resummon (ignition)
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--resummon (on attack)
	local e3=e2:Clone()
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_ATTACK_DISABLED)
	e3:SetCondition(s.negcon)
	c:RegisterEffect(e3)
end
s.listed_names={511000153}
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:GetFirst()==e:GetHandler()
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	if not re then return false end
	local rc=re:GetHandler()
	return rc:IsCode(511000153)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=c:GetMaterial()
	local s1=0
	local s2=0
	local tc=g:GetFirst()
	while tc do
		local a1=tc:GetAttack()
		local a2=tc:GetPreviousAttackOnField()
		if a1<0 then a1=0 end
		if a2<0 then a2=0 end
		s1=s1+a1
		s2=s2+a2
		tc=g:GetNext()
	end
	local a=0
	if s1>s2 then
		a=s1
	else
		a=s2
	end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK)
	e1:SetValue(a)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
	c:RegisterEffect(e1)
end
function s.filter(c,e,tp,code)
	return c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if e:GetHandler():GetSequence()<5 then ft=ft+1 end
	if chk==0 then return ft>4 and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) 
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_REMOVED,0,1,nil,e,tp,40640057) 
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_REMOVED,0,1,nil,e,tp,511000153) 
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_REMOVED,0,1,nil,e,tp,id+1) 
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_REMOVED,0,1,nil,e,tp,511000152) 
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_REMOVED,0,1,nil,e,tp,511000154) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,5,tp,LOCATION_REMOVED)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=4 or Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
	local g1=Duel.GetMatchingGroup(s.filter,tp,LOCATION_REMOVED,0,nil,e,tp,40640057)
	local g2=Duel.GetMatchingGroup(s.filter,tp,LOCATION_REMOVED,0,nil,e,tp,511000153)
	local g3=Duel.GetMatchingGroup(s.filter,tp,LOCATION_REMOVED,0,nil,e,tp,id+1)
	local g4=Duel.GetMatchingGroup(s.filter,tp,LOCATION_REMOVED,0,nil,e,tp,511000152)
	local g5=Duel.GetMatchingGroup(s.filter,tp,LOCATION_REMOVED,0,nil,e,tp,511000154)
	if #g1>0 and #g2>0 and #g3>0 and #g4>0 and #g5>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg1=g1:Select(tp,1,1,nil)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg2=g2:Select(tp,1,1,nil)
		sg1:Merge(sg2)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg3=g3:Select(tp,1,1,nil)
		sg1:Merge(sg3)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg4=g4:Select(tp,1,1,nil)
		sg1:Merge(sg4)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg5=g5:Select(tp,1,1,nil)
		sg1:Merge(sg5)
		Duel.SpecialSummon(sg1,0,tp,tp,false,false,POS_FACEUP)
	end
end
