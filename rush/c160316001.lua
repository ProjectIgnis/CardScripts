--アナライズ・フロギストン
--Analyze Phlogiston
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.costfilter(c)
	return c:IsSpellTrap() and c:IsAbleToGraveAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil) end
end
function s.oppfilter(c)
	return c:IsFaceup() and c:IsAttackPos() and c:IsLevelBelow(8) and c:IsNotMaximumModeSide()
end
function s.tdfilter(c)
	return c:IsMonster() and c:IsRace(RACE_PYRO) and c:IsAbleToDeck() and c:HasLevel()
end
function s.rescon(lvl)
	return function(sg,e,tp,mg)
		return sg:GetSum(Card.GetLevel)==lvl
	end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local og=Duel.GetMatchingGroup(s.oppfilter,tp,0,LOCATION_MZONE,nil)
	local lvl=og:GetSum(Card.GetLevel)
	local dg=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then return #dg>=3 and aux.SelectUnselectGroup(dg,e,tp,3,3,s.rescon(lvl),0) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,3,tp,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,og,#og,tp,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,nil)
	if Duel.SendtoGrave(g,REASON_COST)>0 then
		--Effect
		local og=Duel.GetMatchingGroup(s.oppfilter,tp,0,LOCATION_MZONE,nil)
		local lvl=og:GetSum(Card.GetLevel)
		local dg=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE,0,nil)
		if #dg<3 then return end
		local g=aux.SelectUnselectGroup(dg,e,tp,3,3,s.rescon(lvl),1,tp,HINTMSG_TODECK)
		Duel.HintSelection(g,true)
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		Duel.BreakEffect()
		Duel.Destroy(og,REASON_EFFECT)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,2))
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
		e1:SetTargetRange(LOCATION_MZONE,0)
		e1:SetCondition(s.atkcon)
		e1:SetTarget(s.atktg)
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EVENT_ATTACK_ANNOUNCE)
		e2:SetOperation(s.checkop)
		e2:SetReset(RESET_PHASE|PHASE_END)
		e2:SetLabelObject(e1)
		Duel.RegisterEffect(e2,tp)
	end
end
function s.atkcon(e)
	return e:GetLabel()~=0
end
function s.atktg(e,c)
	return c:GetFieldID()~=e:GetLabel()
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local fid=eg:GetFirst():GetFieldID()
	e:GetLabelObject():SetLabel(fid)
end