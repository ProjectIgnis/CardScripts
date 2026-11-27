--白鴉の魔女の光彩
--Splendor of the White Crow Witch
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--You can activate 1 of these effects;
	--● Special Summon 1 "White Crow" monster from your hand or GY
	--● Fusion Summon 1 "Diabell" Fusion Monster from your Extra Deck, using up to 1 "White Crow" monster each from your hand, Extra Deck, and/or field
	--● If you control a "Diabell" monster: Target 1 face-up card on the field; negate its effects until the end of this turn
	--You can only use this effect of "Splendor of the White Crow Witch" once per turn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
end
s.listed_series={SET_WHITE_CROW,SET_DIABELL}
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_WHITE_CROW) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.locationcheck(tp,sg,fc)
	return #sg<=3 and sg:GetClassCount(Card.GetLocation)==#sg
end
function s.extramaterialgroup(e,tp,mg)
	return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToGrave),tp,LOCATION_EXTRA,0,nil),s.locationcheck
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return e:GetChainData().choice==3 and chkc:IsOnField() and chkc:IsNegatable() end
	--● Special Summon 1 "White Crow" monster from your hand or GY
	local option_1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,nil,e,tp)
	--● Fusion Summon 1 "Diabell" Fusion Monster from your Extra Deck, using up to 1 "White Crow" monster each from your hand, Extra Deck, and/or field
	local fusion_params={
		handler=e:GetHandler(),
		fusfilter=function(c)
			return c:IsSetCard(SET_DIABELL)
		end,
		matfilter=function(c)
			return c:IsSetCard(SET_WHITE_CROW)
		end,
		extrafil=s.extramaterialgroup
	}
	local option_2=Fusion.SummonEffTG(fusion_params)(e,tp,eg,ep,ev,re,r,rp,0)
	--● If you control a "Diabell" monster: Target 1 face-up card on the field; negate its effects until the end of this turn
	local option_3=Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_DIABELL),tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingTarget(Card.IsNegatable,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
	if chk==0 then return option_1 or option_2 or option_3 end
	local choice=Duel.SelectEffect(tp,
		{option_1,aux.Stringid(id,1)},
		{option_2,aux.Stringid(id,2)},
		{option_3,aux.Stringid(id,3)})
	e:GetChainData().choice=choice
	if choice==1 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_GRAVE)
	elseif choice==2 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
		Fusion.SummonEffTG(fusion_params)(e,tp,eg,ep,ev,re,r,rp,1)
		Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_EXTRA)
	elseif choice==3 then
		e:SetCategory(CATEGORY_DISABLE)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
		local g=Duel.SelectTarget(tp,Card.IsNegatable,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,tp,0)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local choice=e:GetChainData().choice
	if choice==1 then
		--● Special Summon 1 "White Crow" monster from your hand or GY
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND|LOCATION_GRAVE,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	elseif choice==2 then
		--● Fusion Summon 1 "Diabell" Fusion Monster from your Extra Deck, using up to 1 "White Crow" monster each from your hand, Extra Deck, and/or field
		local fusion_params={
			handler=e:GetHandler(),
			fusfilter=function(c)
				return c:IsSetCard(SET_DIABELL)
			end,
			matfilter=function(c)
				return c:IsSetCard(SET_WHITE_CROW)
			end,
			extrafil=s.extramaterialgroup
		}
		Fusion.SummonEffOP(fusion_params)(e,tp,eg,ep,ev,re,r,rp)
	elseif choice==3 then
		--● If you control a "Diabell" monster: Target 1 face-up card on the field; negate its effects until the end of this turn
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) and tc:IsFaceup() then
			--Negate its effects until the end of this turn
			tc:NegateEffects(e:GetHandler(),RESET_PHASE|PHASE_END,true)
		end
	end
end