--邪帝ガイウス
--Caius the Shadow Monarch
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Place 1 monster on the field on top of the Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DAMAGE)
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
	return c:IsNotMaximumModeSide()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local dg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if chk==0 then return #dg>0 end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local dg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if #dg>0 then
		local sg=dg:Select(tp,1,1,nil)
		local tc=sg:GetFirst()
		sg=sg:AddMaximumCheck()
		Duel.HintSelection(sg)
		if Duel.SendtoDeck(sg,nil,SEQ_DECKBOTTOM,REASON_EFFECT)<1 then return end
		if #sg>1 then
			Duel.SortDeckbottom(1-tp,1-tp,#sg)
		end
		if tc:IsPreviousPosition(POS_FACEUP) and tc:GetOriginalAttribute()==ATTRIBUTE_DARK then
			Duel.Damage(1-tp,1000,REASON_EFFECT)
		end
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,1))
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e1:SetTargetRange(1,0)
		e1:SetValue(s.aclimit)
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.aclimit(e,re,tp)
	return re:GetHandler():IsCode(9748752)
end