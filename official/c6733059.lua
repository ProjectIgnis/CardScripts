--死霊の巣
--Skull Lair
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	c:RegisterEffect(e0)
	--Destroy 1 face-up monster on the field whose Level is equal to the number of the cards you banished
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCountLimit(1,0,EFFECT_COUNT_CODE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.cfilter(c)
	return c:IsMonster() and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c)
end
function s.rescon(fg)
	return function(sg,e,tp,mg)
		return fg:IsExists(Card.IsLevel,1,sg,#sg),not fg:IsExists(Card.IsLevelAbove,1,sg,#sg)
	end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local cg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,nil)
	local fg=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsLevelBelow,#cg),tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if chk==0 then return aux.SelectUnselectGroup(cg,e,tp,nil,nil,s.rescon(fg),0) end
	local rg=aux.SelectUnselectGroup(cg,e,tp,nil,nil,s.rescon(fg),1,tp,HINTMSG_REMOVE,s.rescon(fg))
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
	Duel.SetTargetParam(#rg)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,fg:Filter(Card.IsLevel,rg,#rg),1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local lv=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	if lv==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,aux.FaceupFilter(Card.IsLevel,lv),tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.Destroy(g,REASON_EFFECT)
	end
end