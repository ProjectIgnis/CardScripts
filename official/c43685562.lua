--ジョウルリ－パンクデンジャラス・ガブ
--Joruri-P.U.N.K. Dangerous Gabu
--Scripted by Rundas
local s,id=GetID()
function s.initial_effect(c)
	--Negate the effects of 1 monster your opponent controls, then gain LP if you control a "P.U.N.K." monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetTarget(s.disrectg)
	e1:SetOperation(s.disrecop)
	c:RegisterEffect(e1)
end
s.listed_series={SET_PUNK}
function s.disrecfilter(c)
	return c:IsNegatableMonster() and c:IsEffectMonster()
end
function s.disrectg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.disrecfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.disrecfilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
	local g=Duel.SelectTarget(tp,s.disrecfilter,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,g:GetFirst():GetBaseAttack())
end
function s.disrecop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not (tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsCanBeDisabledByEffect(e)) then return end
	local c=e:GetHandler()
	tc:NegateEffects(c,RESETS_STANDARD_PHASE_END)
	Duel.AdjustInstantly(tc)
	if tc:IsDisabled() and tc:GetBaseAttack()>0 and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_PUNK),tp,LOCATION_MZONE,0,1,nil) then
		Duel.BreakEffect()
		Duel.Recover(tp,tc:GetBaseAttack(),REASON_EFFECT)
	end
end
