--八雲断巳剣
--Mitsurugi Tempest
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Make your opponent banish exactly 8 cards from their hand, Extra Deck, field, and/or GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e1:SetCondition(function(e,tp) return Duel.IsExistingMatchingCard(s.rmconfilter,tp,LOCATION_GRAVE,0,1,nil) end)
	e1:SetCost(s.rmcost)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
end
s.listed_names={19899073,55397172,101208092}
--"Ame no Murakumo no Mitsurugi", "Futsu no Mitama no Mitsurugi", "Ame no Habakiri no Mitsurugi"
s.listed_series={SET_MITSURUGI}
function s.rmconfilter(c)
	return c:IsSetCard(SET_MITSURUGI) and c:IsRitualSpell()
end
function s.rmcostrescon(sg)
	return sg:GetClassCount(Card.GetOriginalCodeRule)==3
end
function s.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,Card.IsOriginalCodeRule,3,false,s.rmcostrescon,nil,19899073,55397172,101208092) end
	local g=Duel.SelectReleaseGroupCost(tp,Card.IsOriginalCodeRule,3,3,false,s.rmcostrescon,nil,19899073,55397172,101208092)
	Duel.Release(g,REASON_COST)
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(1-tp,30459350)
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD|LOCATION_HAND|LOCATION_EXTRA|LOCATION_GRAVE,8,nil,1-tp) end
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local p=1-tp
	Duel.Hint(HINT_SELECTMSG,p,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(p,Card.IsAbleToRemove,p,LOCATION_ONFIELD|LOCATION_HAND|LOCATION_EXTRA|LOCATION_GRAVE,0,8,8,nil,p)
	if #g==8 then
		Duel.Remove(g,POS_FACEUP,REASON_RULE,PLAYER_NONE,p)
	end
end