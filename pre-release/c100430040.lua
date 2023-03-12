--Ｒｅｃｅｔｔｅ ｄｅ Ｓｐéｃｉａｌｉｔé～料理長自慢のレシピ～
--Recette de Spécialité - Chef's Specialty Recipe
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Negate activation
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.negcon)
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
	c:RegisterEffect(e1)
	--Tribute as many monsters your opponent controls as possible
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_RELEASE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(aux.bfgcost)
	e2:SetCondition(s.tribtcond)
	e2:SetTarget(s.tribttg)
	e2:SetOperation(s.tribtop)
	c:RegisterEffect(e2)
end
s.listed_names={30243636}
s.listed_series={SET_NOUVELLEZ}
function s.cfilter(c)
	return c:IsRitualMonster() and c:IsSetCard(SET_NOUVELLEZ) and c:IsFaceup()
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
		and (re:IsHasType(EFFECT_TYPE_ACTIVATE) or re:IsMonsterEffect()) and Duel.IsChainNegatable(ev)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	local rc=re:GetHandler()
	if rc:IsDestructable() and rc:IsRelateToEffect(re) then
		Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,eg,1,tp,0)
	end
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re)
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsNouvellezSummoned),tp,LOCATION_MZONE,0,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.BreakEffect()
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
function s.burgerfilter(c,tp)
	return c:IsCode(30243636) and c:IsFaceup() and c:IsSummonPlayer(tp)
end
function s.tribtcond(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.burgerfilter,1,nil,tp)
end
function s.tribttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsReleasableByEffect,tp,0,LOCATION_MZONE,1,nil) end
	local g=Duel.GetMatchingGroup(Card.IsReleasableByEffect,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,g,#g,0,0)
end
function s.tribtop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsReleasableByEffect,tp,0,LOCATION_MZONE,nil)
	if #g>0 then
		Duel.Release(g,REASON_EFFECT)
	end
end