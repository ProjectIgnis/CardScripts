--Cocoon of Ultra Evolution (Skill Card)
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop)	
	
	
end

function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	--opd check
	if Duel.GetFlagEffect(ep,id)==0 then return end
	--condition
	return aux.CanActivateSkill(tp) 
	and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil)
end
function s.cfilter(c)
	return (
			(Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,loc,1,nil) and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,e,tp))
		or
			(Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE,0,1,nil) and Duel.IsPlayerCanDraw(tp,1))
		)
end
function s.thfilter(c,code)
	return c:IsCode(code) and c:IsAbleToHand()
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,0,id|(1<<32))
	Duel.Hint(HINT_CARD,0,id)
	--opt register
	Duel.RegisterFlagEffect(ep,id,RESET_PHASE+PHASE_END,0,0)
	
	local b1=(Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,loc,1,nil) and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,e,tp))
    local b2=(Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE,0,1,nil) and Duel.IsPlayerCanDraw(tp,1))
    local p=0
    if b1 and b2 then
        p=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2),aux.Stringid(id,3))
    elseif b1 then
        p=Duel.SelectOption(tp,aux.Stringid(id,1))
    else
        p=Duel.SelectOption(tp,aux.Stringid(id,2))+1
    end
	if p==0
		local loc=LOCATION_MZONE
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then loc=0 end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_MZONE,loc,1,1,nil)
		if #g>0 and Duel.Release(g,REASON_EFFECT)>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sg=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
			if #sg>0 then
				Duel.SpecialSummon(sg,0,tp,tp,true,false,POS_FACEUP)
			end
		end
	elseif p==1
		local g=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
		if Duel.SendtoDeck(g2,nil,0,REASON_EFFECT)~=0
		and tc:IsLocation(LOCATION_DECK+LOCATION_EXTRA) then
		if tc:IsLocation(LOCATION_DECK) then Duel.ShuffleDeck(tc:GetControler()) end
		Duel.BreakEffect()
		Duel.Draw(tp,1,REASON_EFFECT)
		end
	
	else
		local loc=LOCATION_MZONE
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then loc=0 end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_MZONE,loc,1,1,nil)
		if #g>0 and Duel.Release(g,REASON_EFFECT)>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sg=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
			if #sg>0 then
				Duel.SpecialSummon(sg,0,tp,tp,true,false,POS_FACEUP)
			end
		end
		local g2=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
		if Duel.SendtoDeck(g2,nil,0,REASON_EFFECT)~=0
		and tc:IsLocation(LOCATION_DECK+LOCATION_EXTRA) then
		if tc:IsLocation(LOCATION_DECK) then Duel.ShuffleDeck(tc:GetControler()) end
		Duel.BreakEffect()
		Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end

function s.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_INSECT) and c:IsReleasableByEffect()
		and c:GetEquipCount()>0
end
function s.filter(c,e,tp)
	return c:IsRace(RACE_INSECT) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function s.tdfilter(c)
	return c:IsRace(RACE_INSECT) and c:IsAbleToDeck()
end