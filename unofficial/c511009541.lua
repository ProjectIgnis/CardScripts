--Life Transformation
--fixed by MLD
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.cfilter(c)
	return not c:IsAbleToGraveAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil)
		and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>3 end
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.filter(c)
	return c:IsType(TYPE_SPELL) and c:IsSSetable()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and s.filter(chkc) end
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if e:GetHandler():IsLocation(LOCATION_HAND) then
		ft=ft-1
	end
	if chk==0 then return ft>3 and Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,4,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,4,4,nil)	
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,4,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g<=0 or Duel.GetLocationCount(tp,LOCATION_SZONE)<#g then return end
	local tc=g:GetFirst()
	while tc do
		Duel.SSet(tp,tc)
		tc=g:GetNext()
	end
end
