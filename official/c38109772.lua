--竜の騎士
local s,id=GetID()
function s.initial_effect(c)
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	local g=Group.CreateGroup()
	g:KeepAlive()
	e1:SetLabelObject(g)
end
function s.filter(c,tp,dg)
	return c:IsControler(tp) and dg:IsContains(c)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp or not re:IsActiveType(TYPE_MONSTER) or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not tg or #tg==0 then return false end
	local ex,dg,dc=Duel.GetOperationInfo(ev,CATEGORY_DESTROY)
	if not ex or not dg then return false end
	local cg=tg:Filter(s.filter,nil,tp,dg)
	if #cg>0 then
		e:GetLabelObject():Clear()
		e:GetLabelObject():Merge(cg)
		return true
	end
	return false
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetLabelObject():FilterCount(Card.IsAbleToGraveAsCost,nil)==e:GetLabelObject():GetCount() end
	Duel.SendtoGrave(e:GetLabelObject(),REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local ct=e:GetLabelObject():FilterCount(Card.IsLocation,nil,LOCATION_MZONE)
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>-ct and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,eg,1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
