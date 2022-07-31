--暗黒界の隠者 パアル
--Perl, Hermit of Dark World
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon 1 "Dark World" monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
local LOCATION_HAND_GRAVE_REMOVED=LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED
s.listed_series={0x6}
s.listed_names={id}
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if rp==1-tp and c:IsPreviousControler(tp) then
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
	return c:IsPreviousLocation(LOCATION_HAND) and r&(REASON_DISCARD+REASON_EFFECT)==REASON_DISCARD+REASON_EFFECT
end
function s.spfilter1(c,e,tp)
	return c:IsSetCard(0x6) and not c:IsCode(id) and
		((Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)) or
		(Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)))
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter1(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.spfilter1,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter1,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND_GRAVE_REMOVED)
end
function s.spfilter2(c,e,tp)
	return c:IsRace(RACE_FIEND) and (c:IsFaceup() or c:IsLocation(LOCATION_HAND)) and
		((Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)) or
		(Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)))
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
	local b2=Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
	if not (b1 or b2) then return end
	local op=aux.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)})
	local target_player=op==1 and tp or 1-tp
	if Duel.SpecialSummon(tc,0,tp,target_player,false,false,POS_FACEUP)==0 then return end
	--Optional Summon of a Fiend monster
	if e:GetLabel()==1 and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_HAND_GRAVE_REMOVED,0,1,nil,e,tp)
		and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_HAND_GRAVE_REMOVED,0,1,1,nil,e,tp):GetFirst()
		if not sc then return end
		local b3=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and sc:IsCanBeSpecialSummoned(e,0,tp,false,false)
		local b4=Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and sc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
		if not (b3 or b4) then return end
		local op2=aux.SelectEffect(tp,
			{b3,aux.Stringid(id,1)},
			{b4,aux.Stringid(id,2)})
		local target_player2=op2==1 and tp or 1-tp
		Duel.BreakEffect()
		Duel.SpecialSummon(sc,0,tp,target_player2,false,false,POS_FACEUP)
	end
end