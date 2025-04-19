--エクスキューティー・ライディング！
--Executie Riding!
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
function s.cfilter(c,e,tp)
	return c:IsSummonPlayer(1-tp) and c:IsType(TYPE_EFFECT) and c:IsFaceup() and not c:IsMaximumModeSide()
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,c:GetAttack())
end
function s.spfilter(c,e,tp,atk)
	return c:IsAttackBelow(atk) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local cg=eg:Filter(s.cfilter,nil,e,tp)
	return #cg>0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.atkfilter(c)
	return c:IsMonster() and c:IsFaceup() and c:GetAttack()>0
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local atk=eg:Filter(s.cfilter,nil,e,tp):GetMaxGroup(Card.GetAttack):GetFirst():GetAttack()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,atk)
	if #g>0	and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_ATTACK)>0
		and Duel.IsExistingMatchingCard(aux.FilterMaximumSideFunctionEx(s.atkfilter),tp,0,LOCATION_MZONE,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATKDEF)
		local g2=Duel.SelectMatchingCard(tp,aux.FilterMaximumSideFunctionEx(s.atkfilter),tp,0,LOCATION_MZONE,1,2,nil)
		if #g2>0 then
			Duel.HintSelection(g2,true)
			for tc in g2:Iter() do
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UPDATE_ATTACK)
				e1:SetValue(-1800)
				e1:SetReset(RESETS_STANDARD_PHASE_END,1)
				tc:RegisterEffect(e1)
			end
		end
	end
end