--仙人の神髄
--Essence of the Hermit
local s,id=GetID()
function s.initial_effect(c)
	--Opponent's attacking monster loses 500 ATK
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_SPECIAL_SUMMON)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttackTarget()
	return tc and tc:IsFaceup() and tc:IsControler(tp) and tc:GetAttack()==0 
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local at=Duel.GetAttacker()
	if chk==0 then return at:IsControler(1-tp) and at:IsAttackPos() and at:IsOnField() and at:IsCanChangePosition() end
	Duel.SetOperationInfo(0,CATEGORY_POSITION,at,1,0,0)
	Duel.SetChainLimit(s.chlimit)
end
function s.chlimit(e,ep,tp)
	return not e:IsHasType(EFFECT_TYPE_ACTIVATE)
end
function s.spfilter(c,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsType(TYPE_NORMAL) and c:GetAttack()==0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	
	--Effect
	local at=Duel.GetAttacker()
	if at and at:IsAttackPos() and at:IsRelateToBattle() then
		if Duel.ChangePosition(at,POS_FACEUP_DEFENSE)>0 then
			local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,nil,e,tp)
			if #g>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
				Duel.BreakEffect()
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
				local sc=g:Select(tp,1,1,nil):GetFirst()
				if sc then
					Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
				end
			end
		end
	end
end