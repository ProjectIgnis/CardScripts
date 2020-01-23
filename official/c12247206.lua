--地獄の暴走召喚
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return #eg==1 and tc:IsLocation(LOCATION_MZONE) and tc:IsControler(tp)
		and tc:IsFaceup() and tc:IsAttackBelow(1500)
		and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil)
end
function s.nfilter(c,tc)
	return c:IsCode(tc:GetCode())
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=eg:GetFirst()
	if chk==0 then
		local g=Duel.GetMatchingGroup(s.nfilter,tp,0x13,0,nil,tc)
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and #g>0 and #g==g:FilterCount(Card.IsCanBeSpecialSummoned,nil,e,0,tp,false,false)
	end
	tc:CreateEffectRelation(e)
	local g=Duel.GetMatchingGroup(s.filter,tp,0x13,0,nil,tc,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,#g,PLAYER_ALL,0x13)
end
function s.filter(c,tc,e,tp)
	return s.nfilter(c,tc) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.selfilter(c,e,tp)
	return c:IsFaceup() and Duel.IsExistingMatchingCard(s.filter,tp,0x13,0,1,nil,c,e,tp)
end
function s.sp(g,tp,pos)
	local sc=g:GetFirst()
	for sc in aux.Next(g) do
		Duel.SpecialSummonStep(sc,0,tp,tp,false,false,pos)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft1>1 and Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft1=1 end
	local gg=Group.CreateGroup()
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.filter),tp,0x13,0,nil,tc,e,tp)
	if ft1>0 and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		if #g<=ft1 then s.sp(g,tp,POS_FACEUP_ATTACK)
		else
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local fg=g:Select(tp,ft1,ft1,nil)
			s.sp(fg,tp,POS_FACEUP_ATTACK)
			g:Sub(fg)
			gg:Merge(g)
		end
	end
	local ft2=Duel.GetLocationCount(1-tp,LOCATION_MZONE)
	if ft2>1 and Duel.IsPlayerAffectedByEffect(1-tp,CARD_BLUEEYES_SPIRIT) then ft2=1 end
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_FACEUP)
	local sg=Duel.SelectMatchingCard(1-tp,s.selfilter,1-tp,LOCATION_MZONE,0,1,1,nil,e,1-tp)
	if ft2>0 and #sg>0 then
		local g2=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.filter),1-tp,0x13,0,nil,sg:GetFirst(),e,1-tp)
		if #g2>0 then
			if #g2<=ft2 then
				s.sp(g2,1-tp,POS_FACEUP)
			else
				Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)
				local fg=g2:Select(1-tp,ft2,ft2,nil)
				s.sp(fg,1-tp,POS_FACEUP)
				g2:Sub(fg)
				gg:Merge(g2)
			end
		end
	end
	Duel.SpecialSummonComplete()
	Duel.SendtoGrave(gg,REASON_EFFECT)
end
