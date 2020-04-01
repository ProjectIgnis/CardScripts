--Cocoon of Ultra Evolution (Skill Card)
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop)	
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	local b1=(Duel.GetFlagEffect(ep,id)==0 and s.sumtg(e,tp,eg,ep,ev,re,r,rp,0))
	local b2=(Duel.GetFlagEffect(ep,id+1)==0 and s.tdtg(e,tp,eg,ep,ev,re,r,rp,0))
	--condition
	return aux.CanActivateSkill(tp) and (b1 or b2)
end
--effect 1
function s.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_INSECT) and c:IsReleasableByEffect()
		and c:GetEquipCount()>0
end
function s.sumfilter(c,e,tp)
	return c:IsRace(RACE_INSECT) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local loc=LOCATION_MZONE
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then loc=0 end
		return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,loc,1,nil)
			and Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.tdfilter(c)
	return c:IsRace(RACE_INSECT) and c:IsAbleToDeck()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.tdfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE,0,1,nil)
		and Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	local b1=(Duel.GetFlagEffect(ep,id)==0 and s.sumtg(e,tp,eg,ep,ev,re,r,rp,0))
	local b2=(Duel.GetFlagEffect(ep,id+1)==0 and s.tdtg(e,tp,eg,ep,ev,re,r,rp,0))
	if b1 and b2 then
		p=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2))
	elseif b1 then
		p=Duel.SelectOption(tp,aux.Stringid(id,0))
	elseif b2 then
		p=Duel.SelectOption(tp,aux.Stringid(id,1))+1
	end
	if p==0 then
		Duel.RegisterFlagEffect(ep,id,0,0,0)
		local loc=LOCATION_MZONE
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then loc=0 end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_MZONE,loc,1,1,nil)
		if #g>0 and Duel.Release(g,REASON_EFFECT)>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sg=Duel.SelectMatchingCard(tp,s.sumfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
			if #sg>0 then
				Duel.SpecialSummon(sg,0,tp,tp,true,false,POS_FACEUP)
			end
	end
	elseif p==1 then
		Duel.RegisterFlagEffect(ep,id+1,0,0,0)
		local tc=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil):GetFirst()
		if Duel.SendtoDeck(tc,nil,0,REASON_EFFECT)~=0 
		and tc:IsLocation(LOCATION_DECK+LOCATION_EXTRA) then
			if tc:IsLocation(LOCATION_DECK) then Duel.ShuffleDeck(tc:GetControler()) end
			Duel.BreakEffect()
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	else
		Duel.RegisterFlagEffect(ep,id,0,0,0)
		Duel.RegisterFlagEffect(ep,id+1,0,0,0)
		local loc=LOCATION_MZONE
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then loc=0 end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_MZONE,loc,1,1,nil)
		if #g>0 and Duel.Release(g,REASON_EFFECT)>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sg=Duel.SelectMatchingCard(tp,s.sumfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
			if #sg>0 then
				Duel.SpecialSummon(sg,0,tp,tp,true,false,POS_FACEUP)
			end
		end
		
		local tc=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil):GetFirst()
		if Duel.SendtoDeck(tc,nil,0,REASON_EFFECT)~=0 
		and tc:IsLocation(LOCATION_DECK+LOCATION_EXTRA) then
			if tc:IsLocation(LOCATION_DECK) then Duel.ShuffleDeck(tc:GetControler()) end
			Duel.BreakEffect()
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end
