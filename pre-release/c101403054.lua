--ハーピィ＆アマゾネス －羅刹の陣－
--Harpie & Amazoness Rakshasa Formation
--scripted by Naim
local s,id=GetID()
local CARD_EYELLURING_MIRROR_WALL=101403075
function s.initial_effect(c)
	--Target 1 "Harpie" or "Amazoness" monster in your GY or banishment; Special Summon it, then you can apply 1 of these effects based on the number of "Amazoness" monsters and "Harpie Lady" you control
	--● 1+: Place 1 "Eyelluring Mirror Wall" from your Deck face-up in your Spell & Trap Zone
	--● 2+: Take control of 1 monster your opponent controls
	--● 3+: Destroy all monsters your opponent controls
	--You can only activate 1 "Harpie & Amazoness Rakshasa Formation" per turn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_CONTROL+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(TIMING_STANDBY_PHASE,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_HARPIE_LADY,CARD_EYELLURING_MIRROR_WALL}
s.listed_series={SET_HARPIE,SET_AMAZONESS}
function s.spfilter(c,e,tp)
	return c:IsSetCard({SET_HARPIE,SET_AMAZONESS}) and c:IsFaceup() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE|LOCATION_REMOVED) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tg=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tg,1,tp,0)
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_CONTROL,g,1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,g,#g,tp,0)
end
function s.amzharpiefilter(c)
	return ((c:IsSetCard(SET_AMAZONESS) and c:IsMonster()) or c:IsCode(CARD_HARPIE_LADY)) and c:IsFaceup()
end
function s.plfilter(c,tp)
	return c:IsCode(CARD_EYELLURING_MIRROR_WALL) and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
		local amzharpie_count=Duel.GetMatchingGroupCount(s.amzharpiefilter,tp,LOCATION_ONFIELD,0,nil)
		if amzharpie_count==0 then return end
		--● 1+: Place 1 "Eyelluring Mirror Wall" from your Deck face-up in your Spell & Trap Zone
		local option_1=amzharpie_count>=1 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
			and Duel.IsExistingMatchingCard(s.plfilter,tp,LOCATION_DECK,0,1,nil,tp)
		--● 2+: Take control of 1 monster your opponent controls
		local option_2=amzharpie_count>=2
			and Duel.IsExistingMatchingCard(Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,nil)
		--● 3+: Destroy all monsters your opponent controls
		local option_3=amzharpie_count>=3 and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>0
		if not ((option_1 or option_2 or option_3) and Duel.SelectYesNo(tp,aux.Stringid(id,1))) then return end
		local choice=Duel.SelectEffect(tp,
			{option_1,aux.Stringid(id,2)},
			{option_2,aux.Stringid(id,3)},
			{option_3,aux.Stringid(id,4)})
		if choice==1 then
			--● 1+: Place 1 "Eyelluring Mirror Wall" from your Deck face-up in your Spell & Trap Zone
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
			local sc=Duel.SelectMatchingCard(tp,s.plfilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
			if sc then
				Duel.BreakEffect()
				Duel.MoveToField(sc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
			end
		elseif choice==2 then
			--● 2+: Take control of 1 monster your opponent controls
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
			local g=Duel.SelectMatchingCard(tp,Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,1,nil)
			if #g>0 then
				Duel.HintSelection(g)
				Duel.BreakEffect()
				Duel.GetControl(g,tp)
			end
		elseif choice==3 then
			--● 3+: Destroy all monsters your opponent controls
			local g=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
			if #g>0 then
				Duel.BreakEffect()
				Duel.Destroy(g,REASON_EFFECT)
			end
		end
	end
end