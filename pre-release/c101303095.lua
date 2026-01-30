--JP name
--GMX - VELOX
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion Materials: 1 "GMX" monster + 1 Dinosaur monster
	Fusion.AddProcMix(c,true,true,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_GMX),aux.FilterBoolFunctionEx(Card.IsRace,RACE_DINOSAUR))
	--Each time your opponent Normal or Special Summons a monster(s), gain 200 LP
	local e1a=Effect.CreateEffect(c)
	e1a:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1a:SetCode(EVENT_SUMMON_SUCCESS)
	e1a:SetRange(LOCATION_MZONE)
	e1a:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return eg:IsExists(Card.IsSummonPlayer,1,nil,1-tp) end)
	e1a:SetOperation(s.lpop)
	c:RegisterEffect(e1a)
	local e1b=e1a:Clone()
	e1b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e1b)
	--During your opponent's turn (Quick Effect): You can target 1 card your opponent controls; excavate the top cards of your Deck until you excavate a "GMX" monster or a Dinosaur monster, lose 400 LP for each excavated card, add that "GMX" monster or Dinosaur monster to your hand or Special Summon it, and shuffle the rest into the Deck. Also, after that, destroy the targeted card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(function(e,tp) return Duel.IsTurnPlayer(1-tp) end)
	e2:SetTarget(s.excavtg)
	e2:SetOperation(s.excavop)
	e2:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e2)
end
s.listed_series={SET_GMX}
s.material_setcode={SET_GMX}
function s.lpop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsChainSolving() then
		Duel.Recover(tp,200,REASON_EFFECT)
	else
		local c=e:GetHandler()
		--Gain 200 LP at the end of the Chain Link
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAIN_SOLVED)
		e1:SetRange(LOCATION_MZONE)
		e1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp) return Duel.Recover(tp,200,REASON_EFFECT) end)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_CHAIN)
		c:RegisterEffect(e1)
		--Reset "e1" at the end of the Chain Link
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_CHAIN_SOLVED)
		e2:SetOperation(function() e1:Reset() end)
		e2:SetReset(RESET_CHAIN)
		Duel.RegisterEffect(e2,tp)
	end
end
function s.thspfilter(c,e,tp,mmz_chk)
	return (c:IsSetCard(SET_GMX) or c:IsRace(RACE_DINOSAUR)) and c:IsMonster() and (c:IsAbleToHand()
		or (mmz_chk and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
function s.excavtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() end
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil)
		and Duel.IsExistingMatchingCard(s.thspfilter,tp,LOCATION_DECK,0,1,nil,e,tp,Duel.GetLocationCount(tp,LOCATION_MZONE)>0) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.excavop(e,tp,eg,ep,ev,re,r,rp)
	local deck_count=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	if deck_count>0 then
		local mmz_chk=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		local g=Duel.GetMatchingGroup(s.thspfilter,tp,LOCATION_DECK,0,nil,e,tp,mmz_chk)
		if #g==0 then
			Duel.ConfirmDecktop(tp,deck_count)
			Duel.SetLP(tp,Duel.GetLP(tp)-deck_count*400)
		else
			local sc=g:GetMaxGroup(Card.GetSequence):GetFirst()
			local sc_seq=sc:GetSequence()
			local excav_count=deck_count-sc_seq
			Duel.ConfirmDecktop(tp,excav_count)
			Duel.SetLP(tp,Duel.GetLP(tp)-excav_count*400)
			aux.ToHandOrElse(sc,tp,
				function()
					return mmz_chk and sc:IsCanBeSpecialSummoned(e,0,tp,false,false)
				end,
				function()
					Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
				end,
				aux.Stringid(id,1)
			)
		end
	end
	Duel.ShuffleDeck(tp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.BreakEffect()
		Duel.Destroy(tc,REASON_EFFECT)
	end
end