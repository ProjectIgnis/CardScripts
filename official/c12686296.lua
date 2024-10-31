--アルカナフォースＥＸ－ＴＨＥ ＣＨＡＯＳ ＲＵＬＥＲ
--Arcana Force EX - The Chaos Ruler
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion Materials: 3 "Arcana Force" monsters with different names
	Fusion.AddProcMixN(c,true,true,s.ffilter,3)
	Fusion.AddContactProc(c,s.contactfil,s.contactop,true)
	--Toss a coin and apply the appropriate effect
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_COIN+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(s.cointg)
	e1:SetOperation(s.coinop)
	c:RegisterEffect(e1)
	--Your opponent cannot activate monster effects on the field while "Light Barrier" is in a Field Zone
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,1)
	e2:SetCondition(function() return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_LIGHT_BARRIER),0,LOCATION_FZONE,LOCATION_FZONE,1,nil) end)
	e2:SetValue(function(e,re,tp) return re:IsMonsterEffect() and re:GetHandler():IsOnField() end)
	c:RegisterEffect(e2)
end
s.toss_coin=true
s.listed_series={SET_ARCANA_FORCE}
s.material_setcode={SET_ARCANA_FORCE}
s.listed_names={CARD_LIGHT_BARRIER}
function s.ffilter(c,fc,sumtype,tp,sub,mg,sg)
	return c:IsSetCard(SET_ARCANA_FORCE,fc,0,tp) and (not sg or not sg:IsExists(s.fusfilter,1,c,c:GetCode(fc,0,tp),fc,0,tp))
end
function s.fusfilter(c,code,fc,sumtype,tp)
	return c:IsSummonCode(fc,0,tp,code) and not c:IsHasEffect(511002961)
end
function s.contactfilter(c,tp)
	return c:IsSetCard(SET_ARCANA_FORCE) and c:IsAbleToGraveAsCost() and (c:IsControler(tp) or c:IsFaceup())
end
function s.contactfil(tp)
	return Duel.GetMatchingGroup(s.contactfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
end
function s.contactop(g,tp,c)
	Duel.SendtoGrave(g,REASON_COST|REASON_MATERIAL)
end
function s.cointg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.spfilter(c,e,tp)
	return c:IsLevel(10) and c:IsSetCard(SET_ARCANA_FORCE) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function s.thfilter(c)
	return c.toss_coin and c:IsAbleToHand()
end
function s.coinop(e,tp,eg,ep,ev,re,r,rp)
	local coin=nil
	if Duel.IsPlayerAffectedByEffect(tp,CARD_LIGHT_BARRIER) then
		local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,nil,e,tp)
		local b2=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
		local op=Duel.SelectEffect(tp,
			{b1,aux.GetCoinEffectHintString(COIN_HEADS)},
			{b2,aux.GetCoinEffectHintString(COIN_TAILS)})
		if not op then return end
		coin=op==1 and COIN_HEADS or COIN_TAILS
	else
		coin=Duel.TossCoin(tp,1)
	end
	if coin==COIN_HEADS then
		--Heads: Special Summon 1 Level 10 "Arcana Force" monster from your hand or Deck, ignoring its Summoning conditions
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
		end
	elseif coin==COIN_TAILS then
		--Tails: Add 1 card from your Deck to your hand that has a coin tossing effect
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
end