--方界防陣
--Cubic Defense
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--When an opponent's monster declares an attack: Negate that attack, then you can Special Summon up to 2 "Cubic" monsters from your hand and/or Deck, ignoring their Summoning conditions
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return Duel.GetAttacker():IsControler(1-tp)
	end)
	e1:SetTarget(s.negatktg)
	e1:SetOperation(s.negatkop)
	c:RegisterEffect(e1)
	--You can banish this card from your GY, then target 1 "Cubic" card you control; this turn, negate any card or effect activated by your opponent that targeted that card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.efftg)
	e2:SetOperation(s.effop)
	e2:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER)
	c:RegisterEffect(e2)
end
s.listed_series={SET_CUBIC}
function s.negatktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_DECK)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_CUBIC) and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function s.negatkop(e,tp,eg,ep,ev,re,r,rp)
	local max_sp_count=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if Duel.NegateAttack() and max_sp_count>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,nil,e,tp)
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		max_sp_count=math.min(max_sp_count,2)
		if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then max_sp_count=1 end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,max_sp_count,nil,e,tp)
		if #g>0 then
			Duel.BreakEffect()
			Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
		end
	end
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and chkc:IsSetCard(SET_CUBIC) and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(aux.FaceupFilter(Card.IsSetCard,SET_CUBIC),tp,LOCATION_ONFIELD,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,aux.FaceupFilter(Card.IsSetCard,SET_CUBIC),tp,LOCATION_ONFIELD,0,1,1,nil)
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		tc:RegisterFlagEffect(id,RESETS_STANDARD_PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,3))
		--This turn, negate any card or effect activated by your opponent that targeted that card
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAIN_SOLVING)
		e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
			if not (rp==1-tp and re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) and tc:HasFlagEffect(id)) then return false end
			local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
			return tg and tg:IsContains(tc)
		end)
		e1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
			Duel.Hint(HINT_CARD,0,id)
			Duel.NegateEffect(ev)
		end)
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end