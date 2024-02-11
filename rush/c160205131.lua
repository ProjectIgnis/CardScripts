--エクスキューティー・リュミエル
--Executie Lumiere
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	--Shuffle monsters into deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end
function s.spcon(e,c)
	if c==nil then return true end
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)==0
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
function s.tdfilter1(c)
	return c:IsFaceup() and c:IsAbleToDeck() and c:IsLevel(6)
end
function s.tdfilter2(c)
	return c:IsFaceup() and c:IsAbleToDeck() and (c:IsLevel(7) or c:IsLevel(8))
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.FilterMaximumSideFunctionEx(s.tdfilter1),tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(aux.FilterMaximumSideFunctionEx(s.tdfilter2),tp,0,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_MZONE)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g1=Duel.SelectMatchingCard(tp,aux.FilterMaximumSideFunctionEx(s.tdfilter1),tp,LOCATION_MZONE,0,1,1,nil)
	if #g1==0 then return end
	g1=g1:AddMaximumCheck()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g2=Duel.SelectMatchingCard(tp,aux.FilterMaximumSideFunctionEx(s.tdfilter2),tp,0,LOCATION_MZONE,1,1,nil)
	if #g2==0 then return end
	g2=g2:AddMaximumCheck()
	g1:Merge(g2)
	Duel.HintSelection(g1,true)
	if Duel.SendtoDeck(g1,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetProperty(EFFECT_FLAG_OATH)
		e1:SetTargetRange(LOCATION_MZONE,0)
		e1:SetTarget(s.ftarget)
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.ftarget(e,c)
	return c:IsLevelAbove(7)
end