--秘密基地守護神ミスショット
--Secret Base Guardian Misshot
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Material check
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_MATERIAL_CHECK)
	e0:SetValue(s.valcheck)
	c:RegisterEffect(e0)
	--Make itself gain 3000 ATK
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetLabelObject(e0)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_names={160014022}
function s.valcheck(e,c)
	local g=c:GetMaterial()
	local flag=0
	if g:FilterCount(Card.IsCode,nil,160014022)>0 then flag=1 end
	e:SetLabel(flag)
end
function s.tdfilter(c)
	return c:IsLevel(3) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_REPTILE) and c:IsAbleToDeckOrExtraAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE,0,3,nil) end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_MZONE)
end
function s.desfilter(c)
	return c:IsFaceup() and c:IsLevelBelow(8)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_GRAVE,0,3,3,nil)
	Duel.HintSelection(g,true)
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
	--Effect
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_COPY_INHERIT)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE|RESET_PHASE|PHASE_END,2)
	e1:SetValue(3000)
	c:RegisterEffect(e1)
	local dg=Duel.GetMatchingGroup(aux.FilterMaximumSideFunctionEx(s.desfilter),tp,0,LOCATION_MZONE,nil)
	if c:IsStatus(STATUS_SUMMON_TURN) and e:GetLabelObject():GetLabel()~=0 and #dg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local sg=dg:Select(tp,1,3,nil)
		Duel.HintSelection(sg,true)
		sg=sg:AddMaximumCheck()
		Duel.Destroy(sg,REASON_EFFECT)
	end
end