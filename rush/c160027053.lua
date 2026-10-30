--マッドレア・ハート
--Mad Rare Heart
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.tdtg)
	e1:SetOperation(s.tdop)
	c:RegisterEffect(e1)
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsLevel(6)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,0,LOCATION_MZONE,1,nil)
end
function s.filter(c)
	return not c:IsMaximumModeSide()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,0,0)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,0,LOCATION_ONFIELD,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		g=g:AddMaximumCheck()
		if Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_EFFECT)<1 then return end
		if #g>1 then
			Duel.SortDeckbottom(1-tp,1-tp,#g)
		end
	end
	--Cannot Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	--Prevent non-DARK with 1100 DEF from attacking
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetProperty(EFFECT_FLAG_OATH)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.ftarget)
	e2:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e2,tp)
end
function s.ftarget(e,c)
	return not c:IsAttribute(ATTRIBUTE_DARK) or c:GetBaseDefense()~=1100
end