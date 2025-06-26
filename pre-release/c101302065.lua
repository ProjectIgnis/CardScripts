--幸せの多重奏
--Solfachord Happiness
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Activate 1 of these effects
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	c:RegisterEffect(e1)
end
s.listed_names={id}
s.listed_series={SET_SOLFACHORD}
function s.thfilter(c)
	return c:IsSetCard(SET_SOLFACHORD) and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_SOLFACHORD) and c:IsType(TYPE_PENDULUM) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=not Duel.HasFlagEffect(tp,id+100)
		and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler(),REASON_EFFECT)
		and Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil):GetClassCount(Card.GetScale)>=2
	local b2=not Duel.HasFlagEffect(tp,id+200)
		and Pendulum.PlayerCanGainAdditionalPendulumSummon(tp,id)
	local b3=not Duel.HasFlagEffect(tp,id+300)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>=2
		and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_PZONE,0,2,nil,e,tp)
	if chk==0 then return b1 or b2 or b3 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)},
		{b3,aux.Stringid(id,3)})
	e:SetLabel(op)
	Duel.RegisterFlagEffect(tp,id+op*100,RESET_PHASE|PHASE_END,0,1)
	if op==1 then
		e:SetCategory(CATEGORY_HANDES+CATEGORY_TOHAND+CATEGORY_SEARCH)
		Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
		Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	elseif op==2 then
		e:SetCategory(0)
	elseif op==3 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_PZONE)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		--Discard 1 card, and if you do, add 2 "Solfachord" Pendulum Monsters with different Pendulum Scales from your Deck to your hand
		if Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT|REASON_DISCARD)==0 then return end
		local dg=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
		local sdg=aux.SelectUnselectGroup(dg,e,tp,2,2,aux.dpcheck(Card.GetScale),1,tp,HINTMSG_ATOHAND)
		if #sdg~=2 or Duel.SendtoHand(sdg,nil,REASON_EFFECT)~=2 then return end
		Duel.ConfirmCards(1-tp,sdg:Match(Card.IsLocation,nil,LOCATION_HAND))
		Duel.ShuffleHand(tp)
		local ct=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if ct==0 then return end
		local hg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND,0,nil,e,tp)
		if #hg==0 or not Duel.SelectYesNo(tp,aux.Stringid(id,4)) then return end
		ct=math.min(ct,Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)+1)
		if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ct=1 end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local shg=hg:Select(tp,1,ct,nil)
		if #shg>0 then
			Duel.BreakEffect()
			Duel.SpecialSummon(shg,0,tp,tp,false,false,POS_FACEUP)
		end
	elseif op==2 then
		--During your Main Phase this turn, you can conduct 1 Pendulum Summon of a "Solfachord" monster(s) in addition to your Pendulum Summon
		Pendulum.GrantAdditionalPendulumSummon(e:GetHandler(),function(c) return c:IsSetCard(SET_SOLFACHORD) end,tp,LOCATION_HAND|LOCATION_EXTRA,aux.Stringid(id,5),aux.Stringid(id,6),id)
	elseif op==3 then
		--Special Summon 2 "Solfachord" cards from your Pendulum Zone
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 or Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
		local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_PZONE,0,nil,e,tp)
		if #g==2 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end