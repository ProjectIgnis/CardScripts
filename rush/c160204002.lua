--メタリオン・ヴリトラスター
--Metarion Vritrastar
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Summon
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,CARD_IMAGINARY_ACTOR,160204008)
	--Fhange the position of your opponent's monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1,0,EFFECT_COUNT_CODE_SINGLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(s.postg)
	e1:SetOperation(s.posop)
	c:RegisterEffect(e1)
	--Destroy Dragon monsters
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1,0,EFFECT_COUNT_CODE_SINGLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
--position
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsCanChangePositionRush,tp,0,LOCATION_MZONE,1,nil) end
	local g=Duel.GetMatchingGroup(Card.IsCanChangePositionRush,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	local g=Duel.SelectMatchingCard(tp,Card.IsCanChangePositionRush,tp,0,LOCATION_MZONE,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.ChangeToFaceupAttackOrFacedownDefense(g:GetFirst(),tp)
	end
end
--destroy dragon
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(aux.FilterMaximumSideFunctionEx(s.filter),tp,LOCATION_MZONE,0,nil)
	local g2=Duel.GetMatchingGroup(aux.FilterMaximumSideFunctionEx(s.filter2),tp,0,LOCATION_MZONE,nil)
	if chk==0 then return #g>0 and #g2>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g2,1,0,LOCATION_MZONE)
end
function s.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_CYBORG)
end
function s.filter2(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	local g=Duel.GetMatchingGroup(aux.FilterMaximumSideFunctionEx(s.filter),tp,LOCATION_MZONE,0,nil)
	local g2=Duel.GetMatchingGroup(aux.FilterMaximumSideFunctionEx(s.filter2),tp,0,LOCATION_MZONE,nil)
	if #g>0 and #g2>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		sg=g2:Select(tp,1,#g,nil)
		sg=sg:AddMaximumCheck()
		Duel.Destroy(sg,REASON_EFFECT)
	end
end