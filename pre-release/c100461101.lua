--アルカナフォースⅧ－ＳＴＲＥＮＧＴＨ
--Arcana Force VIII - The Strength
--adapted from the anime version by Naim
local s,id=GetID()
function s.initial_effect(c)
	--If this card is in your hand and a card that has a coin tossing effect is on the field: You can Special Summon this card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcond)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--If this card is Summoned: Toss a coin.
	--● Heads: Take control of 1 monster your opponent controls.
	--● Tails: Your opponent takes control of 1 other monster you control.
	local e2a=Effect.CreateEffect(c)
	e2a:SetDescription(aux.Stringid(id,1))
	e2a:SetCategory(CATEGORY_COIN+CATEGORY_CONTROL)
	e2a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2a:SetCode(EVENT_SUMMON_SUCCESS)
	e2a:SetTarget(s.cointg)
	e2a:SetOperation(s.coinop)
	c:RegisterEffect(e2a)
	local e2b=e2a:Clone()
	e2b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2b)
	local e2c=e2a:Clone()
	e2c:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2c)
end
s.coin_toss=true
function s.spcond(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(function(c) return c.toss_coin and c:IsFaceup() end,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
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
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
end
function s.coinop(e,tp,eg,ep,ev,re,r,rp)
	local coin=nil
	local opp=1-tp
	local c=e:GetHandler()
	local exc=c:IsRelateToEffect(e) and c or nil
	if Duel.IsPlayerAffectedByEffect(tp,CARD_LIGHT_BARRIER) then
		--● Heads: Take control of 1 monster your opponent controls.
		local option_1=Duel.IsExistingMatchingCard(Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,nil)
		--● Tails: Your opponent takes control of 1 other monster you control.
		local option_2=Duel.IsExistingMatchingCard(Card.IsControlerCanBeChanged,opp,0,LOCATION_MZONE,1,exc)
		local choice=Duel.SelectEffect(tp,
			{option_1,aux.GetCoinEffectHintString(COIN_HEADS)},
			{option_2,aux.GetCoinEffectHintString(COIN_TAILS)})
		if not choice then return end
		coin=choice==1 and COIN_HEADS or COIN_TAILS
	else
		coin=Duel.TossCoin(tp,1)
	end
	if coin==COIN_HEADS then
		--● Heads: Take control of 1 monster your opponent controls.
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
		local g=Duel.SelectMatchingCard(tp,Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,1,nil)
		if #g>0 then
			Duel.HintSelection(g)
			Duel.GetControl(g,tp)
		end
	elseif coin==COIN_TAILS then
		--● Tails: Your opponent takes control of 1 other monster you control.
		Duel.Hint(HINT_SELECTMSG,opp,HINTMSG_CONTROL)
		local g=Duel.SelectMatchingCard(opp,Card.IsControlerCanBeChanged,opp,0,LOCATION_MZONE,1,1,exc)
		if #g>0 then
			Duel.HintSelection(g)
			Duel.GetControl(g,opp,0,0,nil,opp)
		end
	end
end