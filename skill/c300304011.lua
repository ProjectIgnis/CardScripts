--Armed and Ready!
--Scripted by the Razgriz
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop)
end
s.listed_series={SET_LV}
function s.costfilter(c,e,tp)
	return c:IsSetCard(SET_LV) and c:IsAbleToGraveAsCost() and c:IsFaceup() and c.listed_names and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,c,e,tp)
end
function s.spfilter(c,class,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,2000,tp,false,false) and class.listed_names and c:IsCode(table.unpack(class.listed_names))
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return aux.CanActivateSkill(tp) and Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>-1 and Duel.GetFlagEffect(ep,id)==0
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--OPD Register
	Duel.RegisterFlagEffect(ep,id,0,0,0)
	--Send 1 "LV" monster you control
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp,class)
	if Duel.SendtoGrave(g,REASON_COST)>0 and g:GetFirst():IsLocation(LOCATION_GRAVE) then
		local code=g:GetFirst():GetOriginalCode()
		local class=Duel.GetMetatable(code)
		if class==nil or class.listed_names==nil then return end
		--Special Summon monster listed in sent monster's text as if it were Summoned by the effect of that monster
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,class,e,tp)
		local tc=sg:GetFirst()
		if tc and Duel.SpecialSummon(tc,2000,tp,tp,false,false,POS_FACEUP)>0 then
			tc:RegisterFlagEffect(tc:GetOriginalCode(),RESET_EVENT+RESETS_STANDARD_DISABLE,0,0)
			if tc:GetPreviousLocation()==LOCATION_DECK then Duel.ShuffleDeck(tp) end
		end
	end
end