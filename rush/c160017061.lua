--スパイスクロース・ブラックペッパー
--Spice Cross Black Pepper
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Shuffle up to 5 monsters from your opponent's GY to the deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.cfilter(c,tp)
	return c:GetPreviousLocation()==LOCATION_DECK and c:IsPreviousControler(tp)
end
function s.chkfilter(c)
	return c:IsRace(RACE_CYBERSE) and c:IsAttribute(ATTRIBUTE_FIRE)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.chkfilter,tp,LOCATION_GRAVE,0,nil)
	return eg:IsExists(s.cfilter,1,nil,1-tp) and g:GetClassCount(Card.GetCode)>=3
end
function s.filter(c)
	return c:IsMonster() and c:IsAbleToDeck()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,0,LOCATION_GRAVE,nil)
	if chk==0 then return aux.SelectUnselectGroup(g,e,tp,5,5,s.rescon,0) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,1-tp,LOCATION_GRAVE)
end
function s.tdfilter(c)
	return c:IsMonster() and c:IsLevelBelow(4)
end
function s.rescon(sg,e,tp,mg)
	return sg:FilterCount(s.tdfilter,nil)>=2
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,0,LOCATION_GRAVE,nil)
	local og=aux.SelectUnselectGroup(g,e,tp,5,5,s.rescon,1,tp,HINTMSG_TODECK,s.rescon)
	Duel.HintSelection(og)
	Duel.SendtoDeck(og,nil,SEQ_DECKTOP,REASON_EFFECT)
	Duel.SortDecktop(1-tp,1-tp,5)
end