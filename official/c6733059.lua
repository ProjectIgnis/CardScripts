--死霊の巣
--Skull Lair
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	c:RegisterEffect(e1)
	--Destroy monster
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e2:SetCost(s.descost)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
function s.cfilter(c)
	return c:IsMonster() and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c)
end
function s.rescon(fg)
	return function(sg,e,tp,mg)
		return fg:IsExists(Card.IsLevel,1,sg,#sg),not fg:IsExists(Card.IsLevelAbove,1,sg,#sg)
	end
end
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	local cg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,nil)
	local fg=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsLevelBelow,#cg),tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if chk==0 then return aux.SelectUnselectGroup(cg,e,tp,nil,nil,s.rescon(fg),0) end
	local rg=aux.SelectUnselectGroup(cg,e,tp,nil,nil,s.rescon(fg),1,tp,HINTMSG_REMOVE,s.rescon(fg))
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
	Duel.SetTargetParam(#rg)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,fg:Filter(Card.IsLevel,rg,#rg),1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local lv=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	if lv==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,aux.FaceupFilter(Card.IsLevel,lv),tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.Destroy(g,REASON_EFFECT)
end