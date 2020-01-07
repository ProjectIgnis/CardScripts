--Fusion Dispersal
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON+CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	return a:IsControler(1-tp) and a:IsType(TYPE_FUSION)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local a=Duel.GetAttacker()
	if chkc then return chkc==a end
	if chk==0 then return a and a:IsOnField() and a:IsCanBeEffectTarget(e) and a:IsAbleToExtra() end
	Duel.SetTargetCard(a)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,a,1,0,0)
end
function s.mgfilter(c,e,tp,fusc)
	return c:IsControler(1-tp) and c:IsLocation(LOCATION_GRAVE)
		and c:GetReason()&0x40008==0x40008 and c:GetReasonCard()==fusc
		and c:IsCanBeSpecialSummoned(e,0,1-tp,false,false,POS_FACEUP,1-tp)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not (tc and tc:IsRelateToEffect(e) and tc:IsFaceup()) then return end
	local mg=tc:GetMaterial()
	local sumtype=tc:GetSummonType()
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft>1 and Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	if Duel.SendtoDeck(tc,nil,0,REASON_EFFECT)==0 then return end
	Duel.SkipPhase(Duel.GetTurnPlayer(),PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE,1)
	if sumtype&SUMMON_TYPE_FUSION==SUMMON_TYPE_FUSION and #mg>0
		and #mg<=ft and (not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) or #mg==1) 
		and mg:FilterCount(aux.NecroValleyFilter(s.mgfilter),nil,e,tp,tc)==#mg then
		Duel.BreakEffect()
		if Duel.SpecialSummon(mg,0,tp,1-tp,false,false,POS_FACEUP) then
			local mtg=mg:GetMaxGroup(Card.GetAttack)
			local sg=mtg:GetFirst()
			if #mtg>1 then
				Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(17874674,0))
				local stg=mtg:Select(tp,1,1,nil)
				sg=stg:GetFirst()
				Duel.HintSelection(stg)
			end
			local atk=sg:GetAttack()
			Duel.Damage(1-tp,atk,REASON_EFFECT)
		end
	end
end
