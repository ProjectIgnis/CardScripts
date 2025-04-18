--マジスタリー・アルケミスト
--Magistery Alchemist
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_ATKCHANGE+CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_HERO}
function s.costfilter(c,e,tp)
	return c:IsMonster() and c:IsSetCard(SET_HERO) and c:IsFaceup() and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c,true,true)
end
function s.spcheck(sg,e,tp)
	return Duel.GetMZoneCount(tp,sg)>0 and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,sg,e,tp)
end
function s.spfilter(c,e,tp)
	return c:IsMonster() and c:IsSetCard(SET_HERO) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(-1)
	local rg=Duel.GetMatchingGroup(s.costfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,nil,e,tp)
	if chk==0 then return #rg>=4 and aux.SelectUnselectGroup(rg,e,tp,4,4,s.spcheck,0) end
	local g=aux.SelectUnselectGroup(rg,e,tp,4,4,s.spcheck,1,tp,HINTMSG_REMOVE)
	if g:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_EARTH)
		and g:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_WATER)
		and g:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_FIRE)
		and g:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_WIND) then
		e:SetLabel(1)
	end
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.spfilter(chkc,e,tp) end
	if chk==0 then
		local res=(e:GetLabel()==-1 or Duel.GetLocationCount(tp,LOCATION_MZONE)>0)
			and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		e:SetLabel(0)
		return res
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,tp,LOCATION_GRAVE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	if Duel.SpecialSummonStep(tc,0,tp,tp,true,false,POS_FACEUP) and e:GetLabel()==1 then
		local c=e:GetHandler()
		--Double its original ATK
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_BASE_ATTACK)
		e1:SetValue(tc:GetBaseAttack()*2)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local ng=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_ONFIELD,nil)
		for tcn in ng:Iter() do
			--Negate its effects
			tcn:NegateEffects(c,nil,true)
		end
	end
	Duel.SpecialSummonComplete()
end