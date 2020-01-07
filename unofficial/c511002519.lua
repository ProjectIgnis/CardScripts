--星墜つる地に立つ閃珖
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local at=Duel.GetAttacker()
	return at:GetControler()~=tp and at:IsOnField() and at:GetSummonType()&SUMMON_TYPE_SPECIAL==SUMMON_TYPE_SPECIAL 
		and Duel.GetAttackTarget()==nil
end
function s.filter(c,e,tp)
	if not c:IsCanBeSpecialSummoned(e,0,tp,false,false) or not c:IsSetCard(0xa3) then return false end
	if c:IsLocation(LOCATION_EXTRA) then
		return Duel.GetLocationCountFromEx(tp)>0
	else
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
		if c:IsLocation(LOCATION_HAND) then
			return c:IsControler(tp) or c:IsPublic()
		elseif c:IsLocation(LOCATION_REMOVED) then
			return c:IsFaceup()
		else
			return true
		end
	end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) 
		and Duel.IsExistingMatchingCard(s.filter,tp,0x73,0x32,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0x73)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.Draw(tp,1,REASON_EFFECT)~=0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,0x73,0x32,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
