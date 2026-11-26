--高速詠唱
--High Speed Aria
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Send 1 card from your hand to the GY, then activate 1 of these effects;
	--● Target 1 monster in either GY; Special Summon it to your field.
	--● Fusion Summon 1 Fusion Monster from your Extra Deck, using monsters from your hand or field.
	--● Ritual Summon 1 Ritual Monster from your hand, by Tributing monsters from your hand or field whose total Levels equal or exceed its Level.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.effcost)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
end
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.fusioncostfilter(c,...)
	local fusion_params={
		matfilter=function(mat)
			return mat~=c
		end
	}
	return Fusion.SummonEffTG(fusion_params)(...)
end
function s.ritualcostfilter(c,...)
	local ritual_params={
		matfilter=function(mat)
			return mat~=c
		end,filter=function(ritual)
			return ritual~=c
		end,
		lvtype=RITPROC_GREATER
	}
	return Ritual.Target(ritual_params)(...)
end
function s.effcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil)
	--● Target 1 monster in either GY; Special Summon it to your field.
	local option_1=#g>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp)
	--● Fusion Summon 1 Fusion Monster from your Extra Deck, using monsters from your hand or field.
	local option_2=g:IsExists(s.fusioncostfilter,1,nil,e,tp,eg,ep,ev,re,r,rp,0)
	--● Ritual Summon 1 Ritual Monster from your hand, by Tributing monsters from your hand or field whose total Levels equal or exceed its Level.
	local option_3=g:IsExists(s.ritualcostfilter,1,nil,e,tp,eg,ep,ev,re,r,rp,0)
	if chk==0 then return option_1 or option_2 or option_3 end
	local f=function() return option_1 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local sg=g:FilterSelect(tp,aux.OR(f,s.fusioncostfilter,s.ritualcostfilter),1,1,nil,e,tp,eg,ep,ev,re,r,rp,0)
	Duel.SendtoGrave(sg,REASON_COST)
	--● Target 1 monster in either GY; Special Summon it to your field.
	option_1=#g>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp)
	--● Fusion Summon 1 Fusion Monster from your Extra Deck, using monsters from your hand or field.
	option_2=g:IsExists(s.fusioncostfilter,1,nil,e,tp,eg,ep,ev,re,r,rp,0)
	--● Ritual Summon 1 Ritual Monster from your hand, by Tributing monsters from your hand or field whose total Levels equal or exceed its Level.
	option_3=g:IsExists(s.ritualcostfilter,1,nil,e,tp,eg,ep,ev,re,r,rp,0)
	local choice=Duel.SelectEffect(tp,
		{option_1,aux.Stringid(id,1)},
		{option_2,aux.Stringid(id,2)},
		{option_3,aux.Stringid(id,3)})
	e:GetChainData().choice=choice
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and s.spfilter(chkc,e,tp) end
	--● Target 1 monster in either GY; Special Summon it to your field.
	local option_1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp)
	--● Fusion Summon 1 Fusion Monster from your Extra Deck, using monsters from your hand or field.
	local option_2=Fusion.SummonEffTG()(e,tp,eg,ep,ev,re,r,rp,0)
	--● Ritual Summon 1 Ritual Monster from your hand, by Tributing monsters from your hand or field whose total Levels equal or exceed its Level.
	local option_3=Ritual.Target({lvtype=RITPROC_GREATER})(e,tp,eg,ep,ev,re,r,rp,0)
	if chk==0 then return option_1 or option_2 or option_3 end
	local choice=nil
	local chain_data=e:GetChainData()
	if chain_data.choice then
		choice=chain_data.choice
	else
		choice=Duel.SelectEffect(tp,
			{option_1,aux.Stringid(id,1)},
			{option_2,aux.Stringid(id,2)},
			{option_3,aux.Stringid(id,3)})
		chain_data.choice=choice
	end
	if choice==1 then
		--● Target 1 monster in either GY; Special Summon it to your field.
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,tp,0)
	elseif choice==2 then
		--● Fusion Summon 1 Fusion Monster from your Extra Deck, using monsters from your hand or field.
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
		e:SetProperty(0)
		Fusion.SummonEffTG()(e,tp,eg,ep,ev,re,r,rp,0)
	elseif choice==3 then
		--● Ritual Summon 1 Ritual Monster from your hand, by Tributing monsters from your hand or field whose total Levels equal or exceed its Level.
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_RELEASE)
		e:SetProperty(0)
		Ritual.Target({lvtype=RITPROC_GREATER})(e,tp,eg,ep,ev,re,r,rp,0)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local choice=e:GetChainData().choice
	if choice==1 then
		--● Target 1 monster in either GY; Special Summon it to your field.
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	elseif choice==2 then
		--● Fusion Summon 1 Fusion Monster from your Extra Deck, using monsters from your hand or field.
		Fusion.SummonEffOP()(e,tp,eg,ep,ev,re,r,rp)
	elseif choice==3 then
		--● Ritual Summon 1 Ritual Monster from your hand, by Tributing monsters from your hand or field whose total Levels equal or exceed its Level.
		Ritual.Operation({lvtype=RITPROC_GREATER})(e,tp,eg,ep,ev,re,r,rp)
	end
end