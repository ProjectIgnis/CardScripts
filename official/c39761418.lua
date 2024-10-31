--アルカナフォースⅩⅨ－ＴＨＥ ＳＵＮ
--Arcana Force XIX - The Sun
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon this card from your hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function() return Duel.IsExistingMatchingCard(function(c) return c.toss_coin and c:IsFaceup() end,0,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Toss a coin and apply the appropriate effect
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_COIN+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(s.cointg)
	e2:SetOperation(s.coinop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e4)
end
s.toss_coin=true
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.cointg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local sg=Duel.GetMatchingGroup(Card.IsSpellTrap,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,sg,#sg,tp,0)
end
function s.setfilter(c)
	return c.toss_coin and c:IsSpell() and c:IsSSetable()
end
function s.coinop(e,tp,eg,ep,ev,re,r,rp)
	local coin=nil
	if Duel.IsPlayerAffectedByEffect(tp,CARD_LIGHT_BARRIER) then
		local b1=Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil)
		local b2=Duel.IsExistingMatchingCard(Card.IsSpellTrap,tp,LOCATION_STZONE,LOCATION_STZONE,1,nil)
		local op=Duel.SelectEffect(tp,
			{b1,aux.GetCoinEffectHintString(COIN_HEADS)},
			{b2,aux.GetCoinEffectHintString(COIN_TAILS)})
		if not op then return end
		coin=op==1 and COIN_HEADS or COIN_TAILS
	else
		coin=Duel.TossCoin(tp,1)
	end
	if coin==COIN_HEADS then
		--Heads: Set 1 Spell from your Deck that has a coin tossing effect
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SSet(tp,g)
		end
	elseif coin==COIN_TAILS then
		--Tails: Destroy all cards in the Spell & Trap Zones
		local g=Duel.GetMatchingGroup(Card.IsSpellTrap,tp,LOCATION_STZONE,LOCATION_STZONE,nil)
		if #g>0 then
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end