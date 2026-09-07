--雲海竜 ネモラ
--Lostream Nemora
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Equip
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.posfilter(c)
	return c:IsFaceup() and c:IsCanChangePositionRush()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.posfilter,tp,LOCATION_MZONE,0,1,nil) end
end
function s.equipfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_SEASERPENT) and c:IsAttribute(ATTRIBUTE_WIND)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.equipfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	local g=Duel.SelectMatchingCard(tp,s.posfilter,tp,LOCATION_MZONE,0,1,1,nil)
	if Duel.ChangePosition(g,POS_FACEUP_DEFENSE,0,POS_FACEUP_ATTACK,0)<1 then return end
	--Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectMatchingCard(tp,s.equipfilter,tp,LOCATION_MZONE,0,1,1,c)
	Duel.HintSelection(g)
	local tc=g:GetFirst()
	Duel.Equip(tp,c,tc,true)
	s.eqeffect(c,tc)
	local dg=Duel.GetMatchingGroup(Card.IsSpellTrap,tp,0,LOCATION_ONFIELD,nil)
	if #dg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local sg=dg:Select(tp,1,1,nil)
		if #sg==0 then return end
		Duel.HintSelection(sg)
		Duel.SendtoDeck(sg,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	end
end
function s.eqeffect(c,tc)
	--Add Equip limit
	local e1=Effect.CreateEffect(tc)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD)
	e1:SetValue(s.eqlimit)
	c:RegisterEffect(e1)
	--gain ATK
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e2:SetValue(1000)
	e2:SetReset(RESET_EVENT|RESETS_STANDARD)
	c:RegisterEffect(e2)
end
function s.eqlimit(e,c)
	return c:IsFaceup()
end