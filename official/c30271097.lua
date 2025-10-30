--Ｔｈｅ Ｆａｌｌｅｎ ＆ Ｔｈｅ Ｖｉｒｔｕｏｕｓ
--The Fallen & The Virtuous
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Activate 1 of these effects
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.effcost)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	e1:SetHintTiming(TIMING_END_PHASE,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_ALBAZ}
s.listed_series={SET_BRANDED,SET_DOGMATIKA,SET_ECCLESIA}
function s.descostfilter(c)
	return c:ListsCode(CARD_ALBAZ) and c:IsAbleToGraveAsCost()
end
function s.spconfilter(c)
	return c:IsSetCard(SET_ECCLESIA) and c:IsMonster() and c:IsFaceup()
end
function s.effcost(e,tp,eg,ep,ev,re,r,rp,chk)
	--Send 1 monster that mentions "Fallen of Albaz" from your Extra Deck to the GY, then target 1 face-up card on the field; destroy it
	local b1=Duel.IsExistingMatchingCard(s.descostfilter,tp,LOCATION_EXTRA,0,1,nil)
		and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler())
	--If you have an "Ecclesia" monster in your field or GY: Target 1 monster in either GY; Special Summon it to your field
	local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spconfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,nil)
		and Duel.IsExistingTarget(Card.IsCanBeSpecialSummoned,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,0,tp,false,false)
	if chk==0 then return b1 or b2 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)})
	e:SetLabel(op)
	if op==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g=Duel.SelectMatchingCard(tp,s.descostfilter,tp,LOCATION_EXTRA,0,1,1,nil)
		Duel.SendtoGrave(g,REASON_COST)
	end
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then
		local op=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
		if op==1 then
			return chkc:IsOnField() and chkc:IsFaceup() and chkc~=c
		elseif op==2 then
			return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsCanBeSpecialSummoned(e,0,tp,false,false)
		end
	end
	--Send 1 monster that mentions "Fallen of Albaz" from your Extra Deck to the GY, then target 1 face-up card on the field; destroy it
	local b1=Duel.IsExistingMatchingCard(s.descostfilter,tp,LOCATION_EXTRA,0,1,nil)
		and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler())
	--If you have an "Ecclesia" monster in your field or GY: Target 1 monster in either GY; Special Summon it to your field
	local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spconfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,nil)
		and Duel.IsExistingTarget(Card.IsCanBeSpecialSummoned,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,0,tp,false,false)
	if chk==0 then return b1 or b2 end
	local op=nil
	local label=e:GetLabel()
	if label~=0 then
		op=label
	else
		op=Duel.SelectEffect(tp,
			{b1,aux.Stringid(id,1)},
			{b2,aux.Stringid(id,2)})
	end
	e:SetLabel(0)
	Duel.SetTargetParam(op)
	if op==1 then
		e:SetCategory(CATEGORY_DESTROY)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,c)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,tp,0)
	elseif op==2 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectTarget(tp,Card.IsCanBeSpecialSummoned,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,0,tp,false,false)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,tp,0)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local op=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	if op==1 then
		--Send 1 monster that mentions "Fallen of Albaz" from your Extra Deck to the GY, then target 1 face-up card on the field; destroy it
		Duel.Destroy(tc,REASON_EFFECT)
	elseif op==2 then
		--If you have an "Ecclesia" monster in your field or GY: Target 1 monster in either GY; Special Summon it to your field
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end