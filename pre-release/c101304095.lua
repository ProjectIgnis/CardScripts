--JP name
--GMX Lab #5
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Your opponent cannot activate cards or effects when you Normal or Special Summon a "GMX" monster(s)
	local e1a=Effect.CreateEffect(c)
	e1a:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1a:SetCode(EVENT_SUMMON_SUCCESS)
	e1a:SetRange(LOCATION_FZONE)
	e1a:SetOperation(s.limop1)
	c:RegisterEffect(e1a)
	local e1b=e1a:Clone()
	e1b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e1b)
	local e1c=e1a:Clone()
	e1c:SetCode(EVENT_CHAIN_END)
	e1c:SetOperation(s.limop2)
	c:RegisterEffect(e1c)
	--During your Main Phase: You can Set 1 "GMX" Spell/Trap from your Deck, except "GMX Lab #5", then place 1 card from your hand on top of the Deck. You can only use this effect of "GMX Lab #5" once per turn
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SET+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_GMX}
s.listed_names={id}
function s.limopfilter(c,tp)
	return c:IsSetCard(SET_GMX) and c:IsFaceup() and c:IsSummonPlayer(tp)
end
function s.limop1(e,tp,eg,ep,ev,re,r,rp)
	if eg and eg:IsExists(s.limopfilter,1,nil,tp) then
		Duel.SetChainLimitTillChainEnd(function(re,rp,tp) return tp==rp end)
	end
end
function s.limop2(e,tp,eg,ep,ev,re,r,rp)
	local _,g=Duel.CheckEvent(EVENT_SPSUMMON_SUCCESS,true)
	if g and g:IsExists(s.limopfilter,1,nil,tp) and Duel.CheckEvent(EVENT_SPSUMMON_SUCCESS) then
		Duel.SetChainLimitTillChainEnd(function(re,rp,tp) return tp==rp end)
	end
end
function s.setfilter(c)
	return c:IsSetCard(SET_GMX) and c:IsSpellTrap() and c:IsSSetable() and not c:IsCode(id)
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil)
		and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SET,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SSet(tp,g)>0 then
		Duel.ShuffleDeck(tp)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local sg=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil)
		if #sg>0 then
			Duel.BreakEffect()
			Duel.SendtoDeck(sg,nil,SEQ_DECKTOP,REASON_EFFECT)
		end
	end
end