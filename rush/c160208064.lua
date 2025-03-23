--風帝ライザー
--Raiza the Storm Monarch (Rush)
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Place 1 monster on the field on top of the Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_HANDES+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsStatus(STATUS_SUMMON_TURN) and c:IsSummonType(SUMMON_TYPE_TRIBUTE)
end
function s.filter(c)
	return c:IsAbleToDeck() and c:IsNotMaximumModeSide()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local dg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if chk==0 then return #dg>0 end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local dg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if #dg>0 then
		local sg=dg:Select(tp,1,1,nil)
		sg=sg:AddMaximumCheck()
		Duel.HintSelection(sg,true)
		Duel.SendtoDeck(sg,nil,SEQ_DECKTOP,REASON_EFFECT)
		if #sg>1 then
			Duel.SortDecktop(1-tp,1-tp,#sg)
		end
	end
end

