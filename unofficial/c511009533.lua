--エン・フラワーズ
--En Flowers
--fixed by MLD
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Negate effects and destroy monsters, then damage players for each destroyed monster
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(1353770,0))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.condition)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
s.listed_names={511009534,511009535,511009536}
function s.cfilter(c,code)
	return c:IsFaceup() and c:IsCode(code) and c:GetSequence()<5
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_SZONE,0,1,nil,511009534)
		and Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_SZONE,0,1,nil,511009535)
		and Duel.IsExistingMatchingCard(s.cfilter3,tp,LOCATION_SZONE,0,1,nil,511009536)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsNegatableMonster,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	local g=Duel.GetMatchingGroup(Card.IsNegatableMonster,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,0)
end
function s.damfilter(c,tp)
	return c:IsLocation(LOCATION_GRAVE) and c:IsPreviousControler(tp)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(Card.IsNegatableMonster,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	for tc in g:Iter() do
		if not tc:IsImmuneToEffect(e) then
			tc:NegateEffects(c)
		end
	end
	if Duel.Destroy(g,REASON_EFFECT)>0 then
		Duel.BreakEffect()
		local dg=Duel.GetOperatedGroup()
		local ct1=dg:FilterCount(s.damfilter,nil,tp)
		local ct2=dg:FilterCount(s.damfilter,nil,1-tp)
		Duel.Damage(tp,ct1*600,REASON_EFFECT,true)
		Duel.Damage(1-tp,ct2*600,REASON_EFFECT,true)
		Duel.RDComplete()
	end
end