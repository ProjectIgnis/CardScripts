--ジョウルリ－パンクデンジャラス・ガブ
--Joruri-P.U.N.K. Dangerous Gabu
--Scripted by Rundas
local s,id=GetID()
function s.initial_effect(c)
	--Negate the effects of 1 Effect Monster your opponent controls, then, if you control a "P.U.N.K." monster, gain LP equal to that targeted monster's original ATK
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
end
s.listed_series={SET_PUNK}
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsNegatableMonster() and chkc:IsEffectMonster() end
	if chk==0 then return Duel.IsExistingTarget(aux.AND(Card.IsNegatableMonster,Card.IsEffectMonster),tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
	local tc=Duel.SelectTarget(tp,aux.AND(Card.IsNegatableMonster,Card.IsEffectMonster),tp,0,LOCATION_MZONE,1,1,nil):GetFirst()
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,tp,0)
	local atk=tc:GetBaseAttack()
	if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_PUNK),tp,LOCATION_MZONE,0,1,nil) then
		Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,atk)
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,atk)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsCanBeDisabledByEffect(e) then
		--Negate its effects until the end of this turn
		tc:NegateEffects(e:GetHandler(),RESETS_STANDARD_PHASE_END)
		if not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_PUNK),tp,LOCATION_MZONE,0,1,nil) then return end
		Duel.AdjustInstantly(tc)
		local atk=tc:GetBaseAttack()
		if tc:IsDisabled() and atk>0 then
			Duel.BreakEffect()
			Duel.Recover(tp,atk,REASON_EFFECT)
		end
	end
end