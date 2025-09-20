--異次元への隙間
--Crevice Into the Different Dimension
local s,id=GetID()
function s.initial_effect(c)
	--Banish 2 monsters from either GY with the declared Attribute
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
end
function s.rmfilter(c,e,opp)
	return c:IsMonster() and c:IsAbleToRemove() and c:IsCanBeEffectTarget(e) and (c:IsControler(opp) or aux.SpElimFilter(c,true))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=Duel.GetMatchingGroup(s.rmfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,LOCATION_GRAVE,nil,e,1-tp)
	if chk==0 then return #g>=2 and g:GetClassCount(Card.GetAttribute)<#g end
	local available_attributes=g:GetBitwiseOr(function(c) local attr=c:GetAttribute() return g:IsExists(Card.IsAttribute,1,c,attr) and attr or 0 end)
	local attr=Duel.AnnounceAttribute(tp,1,available_attributes)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local tg=g:FilterSelect(tp,Card.IsAttribute,2,2,nil,attr)
	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,tg,2,tp,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg>0 then
		Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)
	end
end