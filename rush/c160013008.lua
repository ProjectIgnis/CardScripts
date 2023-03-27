--ヴォイドヴェルグ・クリュサオル
--Voidvelgr Chrysaor
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	-- Mill
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.mltg)
	e1:SetOperation(s.mlop)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCountRush(tp,0,LOCATION_MZONE)>1
end
function s.mltg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsLevelBelow,8),tp,0,LOCATION_MZONE,nil)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,3) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,3)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.cfilter(c)
	return c:IsLocation(LOCATION_GRAVE) and c:IsRace(RACE_GALAXY) and c:IsAttribute(ATTRIBUTE_DARK)
end
function s.mlop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Effect
	Duel.DiscardDeck(tp,3,REASON_EFFECT)
	local g=Duel.GetOperatedGroup()
	local ct=g:FilterCount(s.cfilter,nil)
	if ct>1 then
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,2))
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetValue(ct-1)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
		c:RegisterEffect(e1)
		local sg=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsLevelBelow,8),tp,0,LOCATION_MZONE,nil)
		if ct==3 and g:GetClassCount(Card.GetLevel)==1 and #sg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.Destroy(sg,REASON_EFFECT)
		end
	end
end
