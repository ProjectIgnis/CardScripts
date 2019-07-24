--Cubic Rebirth (movie)
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ev,ep,re,r,rp)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	return a and a:IsControler(1-tp) and d==nil
end
function s.filter1(c,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xe3) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SPECIAL,tp,true,false)
end
function s.filter2(c,e,tp,a)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SPECIAL,tp,true,false) and c:IsCode(a:GetCode())
end
function s.target(e,tp,eg,ev,ep,re,r,rp,chk)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	if chk==0 then return a and a:GetControler() and d==nil and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>1 and Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_HAND,0,1,nil,e,tp) and Duel.IsExistingMatchingCard(s.filter2,tp,0,0x13,1,nil,e,tp,a) and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) end
	Duel.SetTargetCard(a)
end
function s.operation(e,tp,eg,ev,ep,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	local tg=Group.CreateGroup()
	tg:AddCard(tc)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or Duel.GetLocationCount(1-tp,LOCATION_MZONE)<=1 or Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
	local sg1=Duel.GetMatchingGroup(s.filter1,tp,LOCATION_HAND,0,nil,e,tp)
	local sg2=Duel.GetMatchingGroup(s.filter2,tp,0,0x13,nil,e,tp,tc)
	if #sg1==0 or #sg2<=1 then return end
	Duel.ConfirmCards(tp,sg2)
	sg1=sg1:Select(tp,1,1,nil)
	sg2=sg2:Select(tp,2,2,nil)
	Duel.SpecialSummon(sg1,SUMMON_TYPE_SPECIAL,tp,tp,true,false,POS_FACEUP)
	Duel.SpecialSummon(sg2,SUMMON_TYPE_SPECIAL,tp,1-tp,true,false,POS_FACEUP)
	tg:Merge(sg2)
	tc=tg:GetFirst()
	while tc do
		tc:AddCounter(0x1038,1)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetCondition(s.conditions)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE)
		tc:RegisterEffect(e2)
		local e3=e1:Clone()
		e3:SetCode(EFFECT_SET_ATTACK)
		e3:SetValue(0)
		tc:RegisterEffect(e3)
		tc=tg:GetNext()
	end
end
function s.conditions(e)
	return e:GetHandler():GetCounter(0x1038)>0
end