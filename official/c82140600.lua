--約束の地－アヴァロン－
--Avalon
local s,id=GetID()
function s.initial_effect(c)
	--Target 5 "Noble Knight" monsters in your Graveyard, including at least 1 "Artorigus" monster and at least 1 "Laundsallyn" monster; banish those targets, and if you do, destroy all cards on the field
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
end
s.listed_series={SET_NOBLE_KNIGHT,SET_ARTORIGUS,SET_LAUNDSALLYN}
function s.banfilter(c)
	return c:IsSetCard(SET_NOBLE_KNIGHT) and c:IsMonster() and c:IsAbleToRemove()
end
function s.rescon(sg,e,tp,mg)
	return sg:IsExists(Card.IsSetCard,1,nil,SET_ARTORIGUS) and sg:IsExists(Card.IsSetCard,1,nil,SET_LAUNDSALLYN)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local c=e:GetHandler()
	local g=Duel.GetTargetGroup(s.banfilter,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then return #g>=5 and aux.SelectUnselectGroup(g,e,tp,5,5,s.rescon,0)
		and Duel.IsExistingMatchingCard(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c) end
	local tg=aux.SelectUnselectGroup(g,e,tp,5,5,s.rescon,1,tp,HINTMSG_REMOVE)
	Duel.SetTargetCard(tg)
	local dg=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,tg,5,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,#dg,tp,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg>0 and Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)>0 then
		local c=e:GetHandler()
		local exc=c:IsRelateToEffect(e) and c or nil
		local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,exc)
		if #g>0 then
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end