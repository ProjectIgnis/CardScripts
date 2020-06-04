--
--The Chaos Creator
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Special summon procedure
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon1)
	e1:SetTarget(s.sptg1)
	e1:SetOperation(s.spop1)
	c:RegisterEffect(e1)
	--Special summon a monster
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.spcon2)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
end
function s.rescon(sg,e,tp,mg)
	return aux.ChkfMMZ(1)(sg,e,tp,mg) and sg:IsExists(s.atchk1,1,nil,sg)
end
function s.atchk1(c,sg)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and sg:FilterCount(Card.IsAttribute,c,ATTRIBUTE_DARK)==1
end
function s.spfilter1(c,att)
	return c:IsAttribute(att) and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c,true)
end
function s.spcon1(e,c)
	if c==nil then return true end
	local tp=e:GetHandlerPlayer()
	local rg1=Duel.GetMatchingGroup(s.spfilter1,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil,ATTRIBUTE_LIGHT)
	local rg2=Duel.GetMatchingGroup(s.spfilter1,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil,ATTRIBUTE_DARK)
	local rg=rg1:Clone()
	rg:Merge(rg2)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	return ft>-2 and #rg1>0 and #rg2>0 and aux.SelectUnselectGroup(rg,e,tp,2,2,s.rescon,0)
end
function s.sptg1(e,tp,eg,ep,ev,re,r,rp,c)
	local c=e:GetHandler()
	local g=nil
	local rg=Duel.GetMatchingGroup(s.spfilter1,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil,ATTRIBUTE_LIGHT+ATTRIBUTE_DARK)
	local g=aux.SelectUnselectGroup(rg,e,tp,2,2,s.rescon,1,tp,HINTMSG_REMOVE,nil,nil,true)
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.spop1(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	g:DeleteGroup()
end
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonLocation(LOCATION_HAND)
end
function s.spchk(c,e,tp)
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.check(sg,e,tp,mg)
	return sg:IsExists(s.spchk,1,nil,e,tp) and sg:GetClassCount(Card.GetCode)==#sg
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=Duel.GetMatchingGroup(aux.FilterFaceupFunction(Card.IsType,TYPE_MONSTER),tp,LOCATION_REMOVED,LOCATION_REMOVED,nil)
	if chk==0 then return aux.SelectUnselectGroup(g,e,tp,3,3,s.check,0) end
	local sg=aux.SelectUnselectGroup(g,e,tp,3,3,s.check,1,tp,HINTMSG_TARGET)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,sg,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,sg,2,0,0)
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=g:FilterSelect(tp,s.spchk,1,1,nil,e,tp):GetFirst()
	if sg then
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		g:RemoveCard(sg)
	end
	Duel.SendtoDeck(g,tp,SEQ_DECKBOTTOM,REASON_EFFECT)
	Duel.SortDeckbottom(tp,tp,#g)
end
