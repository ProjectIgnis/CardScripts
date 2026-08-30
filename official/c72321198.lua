--アルカナフォースⅩⅡ－ＴＨＥ ＨＡＮＧＥＤ ＭＡＮ
--Arcana Force XII - The Hangman
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--When a card or effect is activated (Quick Effect): You can reveal this card in your hand; Special Summon 1 "Arcana Force" monster from your hand in Defense Position. You can only use this effect of "Arcana Force XII - The Hangman" once per turn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(Cost.SelfReveal)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--If this card is Summoned: Toss a coin
	local e2a=Effect.CreateEffect(c)
	e2a:SetDescription(aux.Stringid(id,1))
	e2a:SetCategory(CATEGORY_COIN+CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e2a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2a:SetCode(EVENT_SUMMON_SUCCESS)
	e2a:SetTarget(s.cointg)
	e2a:SetOperation(s.coinop)
	c:RegisterEffect(e2a)
	local e2b=e2a:Clone()
	e2b:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2b)
	local e2c=e2b:Clone()
	e2c:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2c)
end
s.listed_series={SET_ARCANA_FORCE}
s.toss_coin=true
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_ARCANA_FORCE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
function s.cointg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,LOCATION_MZONE)
	if g:GetClassCount(Card.GetControler)==2 or Duel.IsPlayerAffectedByEffect(tp,CARD_LIGHT_BARRIER) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,tp,0)
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_MZONE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_EITHER,0)
end
function s.coinop(e,tp,eg,ep,ev,re,r,rp)
	local coin=nil
	if Duel.IsPlayerAffectedByEffect(tp,CARD_LIGHT_BARRIER) then
		local b1=Duel.IsExistingMatchingCard(nil,tp,LOCATION_MZONE,0,1,nil)
		local b2=Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_MZONE,1,nil)
		local op=Duel.SelectEffect(tp,
			{b1,aux.GetCoinEffectHintString(COIN_HEADS)},
			{b2,aux.GetCoinEffectHintString(COIN_TAILS)})
		if not op then return end
		coin=op==1 and COIN_HEADS or COIN_TAILS
	else
		coin=Duel.TossCoin(tp,1)
	end
	if coin==COIN_HEADS then
		--● Heads: Destroy 1 monster you control, and if you do, take damage equal to its original ATK
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local sc=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
		if not sc then return end
		Duel.HintSelection(sc)
		if Duel.Destroy(sc,REASON_EFFECT)>0 then
			Duel.Damage(tp,sc:GetTextAttack(),REASON_EFFECT)
		end
	elseif coin==COIN_TAILS then
		--● Tails: Destroy 1 monster your opponent controls, and if you do, inflict damage to your opponent equal to its original ATK
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local sc=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_MZONE,1,1,nil):GetFirst()
		if not sc then return end
		Duel.HintSelection(sc)
		if Duel.Destroy(sc,REASON_EFFECT)>0 then
			Duel.Damage(1-tp,sc:GetTextAttack(),REASON_EFFECT)
		end
	end
end