--方界輪廻
--Cubic Rebirth
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_CUBIC}
s.counter_place_list={0x1038}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker():IsControler(1-tp) and Duel.GetAttackTarget()==nil
end
function s.spfilter1(c,e,tp)
	return c:IsSetCard(SET_CUBIC) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local at=Duel.GetAttacker()
	if chkc then return chkc==at end
	if chk==0 then return at:IsOnField() and at:IsCanBeEffectTarget(e)
		and Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetTargetCard(at)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.spfilter2(c,e,tp,tc)
	return c:IsCode(tc:GetCode()) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local tg=Group.FromCards(tc)
		local ft=Duel.GetLocationCount(1-tp,LOCATION_MZONE)
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter2),1-tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,nil,e,1-tp,tc)
		if ft>0 and #g>0 then
			if Duel.IsPlayerAffectedByEffect(1-tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
			local sg=g:Clone()
			if #g>ft then
				Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)
				sg=g:Select(1-tp,ft,ft,nil)
				g:Remove(Card.IsLocation,nil,LOCATION_MZONE|LOCATION_GRAVE)
				Duel.SendtoGrave(g,REASON_EFFECT)
			end
			local sc=sg:GetFirst()
			for sc in aux.Next(sg) do
				Duel.SpecialSummonStep(sc,0,1-tp,1-tp,false,false,POS_FACEUP_ATTACK)
			end
			Duel.SpecialSummonComplete()
			local og=Duel.GetOperatedGroup()
			tg:Merge(og)
		end
		local tc=tg:GetFirst()
		for tc in aux.Next(tg) do
			s.counter(tc,c)
		end
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g2=Duel.SelectMatchingCard(tp,s.spfilter1,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		if #g2>0 then
			Duel.SpecialSummon(g2,0,tp,tp,true,false,POS_FACEUP)
		end
	end
end
function s.disable(e)
	return e:GetHandler():GetCounter(0x1038)>0
end
function s.counter(tc,ec)
	local e1=Effect.CreateEffect(ec)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1:SetValue(0)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD)
	tc:RegisterEffect(e1)
	--
	tc:AddCounter(0x1038,1)
	local e2=Effect.CreateEffect(ec)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetCondition(s.disable)
	e2:SetReset(RESET_EVENT|RESETS_STANDARD)
	tc:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_DISABLE)
	tc:RegisterEffect(e3)
end