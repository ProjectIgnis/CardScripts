--巳剣之磐境
--Mitsurugi Sacred Boundary
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Your opponent cannot target "Mitsurugi" Ritual Monsters you control with effects of monsters that were Special Summoned from the Extra Deck
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(function(e,c) return c:IsSetCard(SET_MITSURUGI) and c:IsRitualMonster() end)
	e1:SetValue(s.cannottargetval)
	c:RegisterEffect(e1)
	--Shuffle 4 "Mitsurugi" cards in your GY, except "Mitsurugi Sacred Boundary", into the Deck, then if your opponent controls a monster, make them Tribute 1 monster they control
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end
s.listed_names={id}
s.listed_series={SET_MITSURUGI}
function s.cannottargetval(e,re,rp)
	if not (re:IsMonsterEffect() and rp==1-e:GetHandlerPlayer()) then return false end
	local trig_sum_loc,trig_eff=Duel.GetChainInfo(0,CHAININFO_TRIGGERING_SUMMON_LOCATION,CHAININFO_TRIGGERING_EFFECT)
	if trig_eff==re then
		return trig_sum_loc==LOCATION_EXTRA
	else
		return re:GetHandler():IsSummonLocation(LOCATION_EXTRA)
	end
end
function s.tdfilter(c)
	return c:IsSetCard(SET_MITSURUGI) and not c:IsCode(id) and c:IsAbleToDeck()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.tdfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE,0,4,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE,0,4,4,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,4,tp,0)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg==0 or Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)==0 or not tg:IsExists(Card.IsLocation,1,nil,LOCATION_DECK|LOCATION_EXTRA) then return end
	local g=Duel.SelectReleaseGroup(1-tp,nil,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.BreakEffect()
		Duel.Release(g,REASON_RULE,1-tp)
	end
end